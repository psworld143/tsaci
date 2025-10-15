import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_router.dart';

void main() {
  runApp(const TSACIApp());
}

class TSACIApp extends StatelessWidget {
  const TSACIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSACI - Plant Monitoring System',
      debugShowCheckedModeBanner: false,

      // Use TSACI custom theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Initial screen based on auth state
      home: FutureBuilder<Widget>(
        future: AppRouter.getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }
}
