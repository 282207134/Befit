import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:befit/app.dart';
import 'package:befit/core/app_controller.dart';
import 'package:befit/data/local_store.dart';

void main() {
  testWidgets('detail pages lay out and release their session clocks', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = AppController(MemoryStore())..onboarded = true;
    addTearDown(app.dispose);
    for (final route in [
      '/profile',
      '/member',
      '/map',
      '/activity',
      '/workout',
      '/settings',
      '/edit-profile',
    ]) {
      await tester.pumpWidget(BefitApp(controller: app, initialRoute: route));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  testWidgets('main pages render on small and normal phones without overflow', (
    tester,
  ) async {
    final app = AppController(MemoryStore())..onboarded = true;
    addTearDown(app.dispose);
    for (final size in [
      const Size(375, 812),
      const Size(320, 640),
      const Size(430, 932),
    ]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      await tester.pumpWidget(BefitApp(controller: app));
      await tester.pumpAndSettle();
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byKey(ValueKey('tab-$i')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size page $i');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
  testWidgets(
    'registration validates the name and saves the completed profile',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = AppController(MemoryStore());
      addTearDown(app.dispose);
      await tester.pumpWidget(
        BefitApp(controller: app, initialRoute: '/register'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('register-name')),
        'Alex Chen',
      );
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Let’s Go'));
      await tester.pumpAndSettle();
      expect(app.onboarded, isTrue);
      expect(app.name, 'Alex Chen');
      expect(find.text('Some Activity!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
