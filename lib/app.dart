import 'package:flutter/material.dart';

import 'core/app_controller.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/club/club_screen.dart';
import 'features/club/map_screen.dart';
import 'features/club/story_screen.dart';
import 'features/activity/activity_screen.dart';
import 'features/activity/workout_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class BefitApp extends StatelessWidget {
  const BefitApp({
    super.key,
    required this.controller,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.initialRoute,
  });
  final AppController controller;
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: MaterialApp(
      title: 'Befit',
      debugShowCheckedModeBanner: false,
      theme: befitTheme(),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      initialRoute:
          initialRoute ?? (controller.onboarded ? '/' : '/onboarding'),
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => const MainShell(),
          '/onboarding' => const OnboardingScreen(),
          '/register' => const RegistrationScreen(),
          '/menu' => const MenuScreen(),
          '/profile' => const ProfileScreen(),
          '/member' => const ProfileScreen(other: true),
          '/edit-profile' => const EditProfileScreen(),
          '/settings' => const SettingsScreen(),
          '/favorites' => const FavoritesScreen(),
          '/notifications' => const NotificationsScreen(),
          '/stories' => const StoryScreen(),
          '/map' => const ClubMapScreen(),
          '/activity' => ActivityScreen(kind: settings.arguments),
          '/workout' => WorkoutScreen(
            challengeId: settings.arguments as String?,
          ),
          '/congratulations' => const CongratulationsScreen(),
          '/result' => const ActivityResultScreen(),
          _ => const MainShell(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => page,
        );
      },
    ),
  );
}
