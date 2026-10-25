import 'package:flutter_test/flutter_test.dart';
import 'package:befit/core/app_controller.dart';
import 'package:befit/data/local_store.dart';
import 'package:befit/data/models.dart';

void main() {
  test('profile, habits, reminders and sessions survive a restart', () async {
    final store = MemoryStore();
    final app = AppController(store, now: () => DateTime(2026, 10, 25));
    await app.load();
    await app.updateProfile(
      name: '  Alex Chen  ',
      birthday: DateTime(1995, 4, 2),
      height: 175,
      weight: 70.5,
    );
    await app.drink();
    await app.toggleFavorite('workout-0-0');
    await app.complete('yoga');
    await app.toggleEvent(0);
    await app.finishOnboarding();
    await app.addActivity(
      ActivityRecord(
        kind: ActivityKind.running,
        seconds: 120,
        distance: .3,
        date: DateTime(2026, 10, 25),
      ),
    );
    final restored = AppController(store, now: () => DateTime(2026, 10, 25));
    await restored.load();
    expect(restored.name, 'Alex Chen');
    expect(restored.water, 4);
    expect(restored.height, 175);
    expect(restored.weight, 70.5);
    expect(restored.completed, contains('yoga'));
    expect(restored.favorites, contains('workout-0-0'));
    expect(restored.eventReminders, contains(0));
    expect(restored.onboarded, isTrue);
    expect(restored.history.single.distance, .3);
    app.dispose();
    restored.dispose();
  });
  test(
    'water caps at the daily goal and resets at the next local day',
    () async {
      var day = DateTime(2026, 10, 25);
      final store = MemoryStore();
      final app = AppController(store, now: () => day);
      await app.load();
      for (int i = 0; i < 10; i++) {
        await app.drink();
      }
      expect(app.water, 8);
      day = DateTime(2026, 10, 26);
      await app.drink();
      expect(app.water, 1);
      final restored = AppController(store, now: () => DateTime(2026, 10, 27));
      await restored.load();
      expect(restored.water, 0);
      app.dispose();
      restored.dispose();
    },
  );
  test('rapid writes retain the most recent state', () async {
    final store = MemoryStore();
    final app = AppController(store);
    await app.load();
    await Future.wait([
      app.drink(),
      app.drink(),
      app.drink(),
      app.toggleFavorite('workout-1-0'),
    ]);
    final restored = AppController(store);
    await restored.load();
    expect(restored.water, 6);
    expect(restored.favorites, contains('workout-1-0'));
    app.dispose();
    restored.dispose();
  });
  test('bad storage recovers and reports a useful error', () async {
    final store = MemoryStore()..value = '{damaged';
    final app = AppController(store);
    await app.load();
    expect(app.storageError, isNotNull);
    expect(app.name, isNotEmpty);
    await app.drink();
    expect(app.storageError, isNull);
    app.dispose();
  });
  test('duration formatter supports long sessions', () {
    expect(clockText(65), '01:05');
    expect(clockText(3661, hours: true), '01:01:01');
  });
}
