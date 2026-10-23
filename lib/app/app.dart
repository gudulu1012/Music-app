import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import '../services/auth/auth_service.dart';
import '../features/auth/auth_gate.dart';
import '../shared/theme/theme_provider.dart';

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
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Sonora',
      debugShowCheckedModeBanner: false,

      // Dynamic theme from ThemeProvider
      theme: AppTheme.buildDarkTheme(
        themeProvider.accentColor,
        themeType: themeProvider.currentTheme,
      ),
      darkTheme: AppTheme.buildDarkTheme(
        themeProvider.accentColor,
        themeType: themeProvider.currentTheme,
      ),
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
    final accent = Theme.of(context).colorScheme.primary;

    switch (auth.state) {
      case AuthState.initial:
      case AuthState.loading:
        // Show a splash / loading screen while checking auth state
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: accent,
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
