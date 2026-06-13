import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const SmartShareHubApp());
}

class SmartShareHubApp extends StatelessWidget {
  const SmartShareHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider()..initialize(),
      child: Consumer<SessionProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Smart Share Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
