import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import '../services/auth/auth_service.dart';
import '../features/auth/auth_gate.dart';

/// Root widget for the Music App.
///
/// Configures theming, routing, and the top-level MaterialApp.
/// Gates the entire app on authentication state:
/// - Unauthenticated → AuthGate (login/signup)
/// - Authenticated → AppShell (main app)
class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonora',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark

      // Auth-aware home
      home: const _AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// Listens to [AuthService] and shows the appropriate root widget.
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    switch (auth.state) {
      case AuthState.initial:
      case AuthState.loading:
        // Show a splash / loading screen while checking auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryPurple,
            ),
          ),
        );
      case AuthState.authenticated:
        return const AppShell();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const AuthGate();
    }
  }
}
