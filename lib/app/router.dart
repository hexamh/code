import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/screens/editor_screen.dart';
import 'package:myapp/presentation/screens/settings_screen.dart';
import 'package:myapp/presentation/screens/splash_screen.dart';

/// App-wide GoRouter configuration with splash screen as initial route.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(
        onComplete: () => context.go('/'),
      ),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const EditorScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
