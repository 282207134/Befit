import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../data/models.dart';

class AppController extends ChangeNotifier {
  AppController(this.store, {DateTime Function()? now})
    : now = now ?? DateTime.now;

  final LocalStore store;
  final DateTime Function() now;
  String name = 'Thomas Meyer';
  DateTime birthday = DateTime(1996, 3, 7);
  double height = 180;
  double weight = 87.6;
  int water = 3;
  bool onboarded = false;
  bool reminders = true;
  bool metric = true;
  String? storageError;
  final Set<String> completed = {'fat-burning'};
  final Set<String> favorites = {};
  final Set<int> eventReminders = {};
  final List<ActivityRecord> history = [];
  String _waterDay = '';
  Future<void> _writes = Future.value();

  Future<void> load() async {
    try {
      final raw = await store.read();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        name = data['name'] as String? ?? name;
        birthday =
            DateTime.tryParse(data['birthday'] as String? ?? '') ?? birthday;
        height = (data['height'] as num?)?.toDouble() ?? height;
        weight = (data['weight'] as num?)?.toDouble() ?? weight;
        water = (data['water'] as int? ?? water).clamp(0, 8);
        onboarded = data['onboarded'] as bool? ?? false;
        reminders = data['reminders'] as bool? ?? true;
        metric = data['metric'] as bool? ?? true;
        _waterDay = data['waterDay'] as String? ?? '';
        completed
          ..clear()
          ..addAll(List<String>.from(data['completed'] ?? ['fat-burning']));
        favorites.addAll(List<String>.from(data['favorites'] ?? []));
        eventReminders.addAll(List<int>.from(data['events'] ?? []));
        for (final item in data['history'] as List? ?? []) {
          try {
            history.add(
              ActivityRecord.fromJson(Map<String, dynamic>.from(item as Map)),
            );
          } on Object {
            // A damaged history entry must not prevent the app from opening.
          }
        }
      }
      _resetDay();
    } on Object {
      storageError =
          'Your saved data could not be loaded. You can keep using Befit.';
    }
  }

  void _resetDay() {
    final day = now().toIso8601String().substring(0, 10);
    if (_waterDay.isNotEmpty && day != _waterDay) water = 0;
    _waterDay = day;
  }

  Future<void> _save() {
    notifyListeners();
    final value = jsonEncode({
      'name': name,
      'birthday': birthday.toIso8601String(),
      'height': height,
      'weight': weight,
      'water': water,
      'waterDay': _waterDay,
      'onboarded': onboarded,
      'reminders': reminders,
      'metric': metric,
      'completed': completed.toList(),
      'favorites': favorites.toList(),
      'events': eventReminders.toList(),
      'history': history.map((record) => record.toJson()).toList(),
    });
    _writes = _writes.then((_) async {
      try {
        await store.write(value);
        if (storageError != null) {
          storageError = null;
          notifyListeners();
        }
      } on Object {
        storageError =
            'Changes are available this session, but could not be saved.';
        notifyListeners();
      }
    });
    return _writes;
  }

  Future<void> drink() async {
    _resetDay();
    if (water < 8) water++;
    await _save();
  }

  Future<void> updateProfile({
    required String name,
    required DateTime birthday,
    required double height,
    required double weight,
  }) async {
    if (name.trim().isEmpty ||
        !height.isFinite ||
        !weight.isFinite ||
        height < 100 ||
        height > 230 ||
        weight < 30 ||
        weight > 200) {
      throw ArgumentError('Profile values are outside the supported range.');
    }
    this.name = name.trim();
    this.birthday = birthday;
    this.height = height;
    this.weight = weight;
    await _save();
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await _save();
  }

  Future<void> setWeight(double value) async {
    if (!value.isFinite) throw ArgumentError.value(value, 'weight');
    weight = value.clamp(30, 200);
    await _save();
  }

  Future<void> retrySave() => _save();

  Future<void> toggleFavorite(String id) async {
    if (!favorites.add(id)) favorites.remove(id);
    await _save();
  }

  Future<void> complete(String id) async {
    completed.add(id);
    await _save();
  }

  Future<void> toggleEvent(int id) async {
    if (!eventReminders.add(id)) eventReminders.remove(id);
    await _save();
  }

  Future<void> setReminders(bool value) async {
    reminders = value;
    await _save();
  }

  Future<void> setMetric(bool value) async {
    metric = value;
    await _save();
  }

  Future<void> addActivity(ActivityRecord record) async {
    history.insert(0, record);
    await _save();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
