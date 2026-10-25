import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:befit/app.dart';
import 'package:befit/core/app_controller.dart';
import 'package:befit/data/local_store.dart';
import 'package:befit/data/models.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('complete user journeys and capture every screen', (
    tester,
  ) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A1735),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    final store = MemoryStore();
    final app = AppController(store, now: () => DateTime(2026, 10, 25, 9, 41));
    await app.load();
    final nav = GlobalKey<NavigatorState>();
    final messenger = GlobalKey<ScaffoldMessengerState>();
    const preview = String.fromEnvironment('PREVIEW_ROUTE');
    final previousError = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint(details.toString());
      previousError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousError);
    await tester.pumpWidget(
      BefitApp(
        controller: app,
        navigatorKey: nav,
        scaffoldMessengerKey: messenger,
        initialRoute: preview.isEmpty ? null : preview,
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    Future<void> shot(String name) async {
      messenger.currentState?.removeCurrentSnackBar();
      messenger.currentState?.clearSnackBars();
      await tester.pump(const Duration(milliseconds: 600));
      await binding.takeScreenshot(name);
      expect(tester.takeException(), isNull, reason: name);
    }

    Future<void> route(String name, {Object? arguments}) async {
      nav.currentState!.pushNamedAndRemoveUntil(
        name,
        (_) => false,
        arguments: arguments,
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapText(String label) async {
      if (find.text(label).evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          find.text(label),
          180,
          scrollable: find.byType(Scrollable).last,
        );
      }
      await tester.ensureVisible(find.text(label).last);
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    if (preview.isNotEmpty) {
      await shot('preview');
      return;
    }

    for (int i = 0; i < 5; i++) {
      await shot('01_onboarding_${i + 1}');
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
    }
    await shot('02_register_name');
    await tester.enterText(
      find.byKey(const ValueKey('register-name')),
      'Thomas Meyer',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapText('Next');
    await shot('03_register_birthday');
    await tapText('Next');
    await shot('04_register_height');
    await tapText('Next');
    await shot('05_register_weight');
    await tapText('Let’s Go');
    expect(app.onboarded, isTrue);
    await app.setWeight(87.6);
    await tester.pumpAndSettle();
    await shot('06_home');
    await tester.tap(find.byTooltip('Add favorite').first);
    await tester.pumpAndSettle();
    expect(app.favorites, isNotEmpty);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await shot('07_menu');
    await tapText('My Favorite');
    await shot('08_favorites');
    await route('/');
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    await shot('09_club');
    await tester.tap(find.byTooltip('Save event reminder').first);
    await tester.pumpAndSettle();
    expect(app.eventReminders, contains(0));
    await route('/notifications');
    await shot('10_notifications');
    await route('/stories');
    await shot('11_stories');
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await route('/map');
    await shot('12_club_map');
    await tester.tap(find.bySemanticsLabel('View member 1'));
    await tester.pumpAndSettle();
    await shot('13_map_member');
    await tapText('View Profile');
    await shot('14_member_profile');
    await route('/');
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    await shot('15_challenges');
    await tapText('Battle Rope');
    await tapText('I’ve completed this today');
    await tapText('Done');
    expect(app.completed, contains('rope'));
    await shot('16_challenges_done');
    await tester.tap(find.byKey(const ValueKey('tab-3')));
    await tester.pumpAndSettle();
    await shot('17_daily');
    await tapText('Drink');
    expect(app.water, 4);
    await tapText('Change');
    await tester.enterText(find.byType(TextFormField), '82.5');
    await tapText('Save');
    expect(app.weight, 82.5);
    await tapText('All Days');
    await shot('18_daily_all');
    await route('/workout');
    await tester.pump(const Duration(seconds: 1));
    await shot('19_workout');
    await tester.tap(find.byKey(const ValueKey('workout-toggle')));
    await tester.pumpAndSettle();
    await shot('20_workout_paused');
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('next-exercise')));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await shot('21_workout_complete');
    expect(app.completed, contains('build-abs'));
    await route('/activity', arguments: ActivityKind.cycling);
    await shot('22_cycling_start');
    await tester.tap(find.byKey(const ValueKey('activity-toggle')));
    await tester.pump(const Duration(seconds: 2));
    await shot('23_cycling_active');
    await tester.tap(find.byKey(const ValueKey('activity-toggle')));
    await tester.pumpAndSettle();
    await shot('24_cycling_paused');
    await tester.tap(find.bySemanticsLabel('Finish activity'));
    await tester.pumpAndSettle();
    await shot('25_finish_confirmation');
    await tester.tap(find.byKey(const ValueKey('confirm-finish')));
    await tester.pumpAndSettle();
    expect(app.history.length, 1);
    await shot('26_congratulations');
    await tapText('View Results');
    await shot('27_cycling_result');
    await tapText('Go to Home');
    expect(find.text('Some Activity!'), findsOneWidget);
    await route('/activity', arguments: ActivityKind.walking);
    await shot('28_walking_start');
    await route('/activity', arguments: ActivityKind.running);
    await shot('29_running_start');
    await route('/profile');
    await shot('30_profile');
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    await shot('31_profile_stats');
    await route('/edit-profile');
    await shot('32_edit_profile');
    await tester.enterText(find.byType(TextFormField).first, 'Thomas M.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapText('Save Changes');
    expect(app.name, 'Thomas M.');
    await route('/settings');
    await shot('33_settings');
    final restored = AppController(store, now: () => DateTime(2026, 10, 25));
    await restored.load();
    expect(restored.onboarded, isTrue);
    expect(restored.water, 4);
    expect(restored.weight, 82.5);
    expect(restored.name, 'Thomas M.');
    expect(restored.history.length, 1);
    expect(restored.completed, contains('build-abs'));
    restored.dispose();
    await route('/');
  });
  testWidgets('Android preferences survive a new controller instance', (
    tester,
  ) async {
    final store = PreferencesStore();
    final previous = await store.read();
    try {
      final app = AppController(store);
      await app.load();
      await app.updateProfile(
        name: 'Storage Test',
        birthday: DateTime(1996, 3, 7),
        height: 180,
        weight: 75,
      );
      await app.finishOnboarding();
      final restored = AppController(PreferencesStore());
      await restored.load();
      expect(restored.name, 'Storage Test');
      expect(restored.onboarded, isTrue);
      expect(restored.weight, 75);
      restored.dispose();
      app.dispose();
    } finally {
      await store.write(previous ?? '{}');
    }
  });
}
