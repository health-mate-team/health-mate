import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/features/action/presentation/walk_action_page.dart';
import 'package:health_mate/features/action/presentation/water_action_page.dart';
import 'package:health_mate/features/evolution/presentation/evolution_page.dart';
import 'package:health_mate/features/evening_ritual/presentation/evening_ritual_page.dart';
import 'package:health_mate/features/home/presentation/home_character_page.dart';
import 'package:health_mate/features/morning_ritual/presentation/morning_mood_page.dart';
import 'package:health_mate/features/morning_ritual/presentation/morning_promise_page.dart';
import 'package:health_mate/features/onboarding/presentation/onboarding_goal_page.dart';
import 'package:health_mate/features/onboarding/presentation/onboarding_meet_moa_page.dart';
import 'package:health_mate/features/onboarding/presentation/onboarding_name_page.dart';
import 'package:health_mate/features/onboarding/presentation/onboarding_welcome_page.dart';
import 'package:health_mate/features/splash/presentation/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const OnboardingWelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/name',
        builder: (context, state) => const OnboardingNamePage(),
      ),
      GoRoute(
        path: '/onboarding/goal',
        builder: (context, state) => const OnboardingGoalPage(),
      ),
      GoRoute(
        path: '/onboarding/meet-moa',
        builder: (context, state) => const OnboardingMeetMoaPage(),
      ),
      GoRoute(
        path: '/morning/mood',
        builder: (context, state) => const MorningMoodPage(),
      ),
      GoRoute(
        path: '/morning/promise',
        builder: (context, state) => const MorningPromisePage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeCharacterPage(),
      ),
      GoRoute(
        path: '/action/water',
        builder: (context, state) => const WaterActionPage(),
      ),
      GoRoute(
        path: '/action/walk',
        builder: (context, state) => const WalkActionPage(),
      ),
      GoRoute(
        path: '/evening/ritual',
        builder: (context, state) => const EveningRitualPage(),
      ),
      GoRoute(
        path: '/moment/evolution',
        builder: (context, state) => const EvolutionPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login — TODO')),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) => '/home',
      ),
    ],
  );
});
