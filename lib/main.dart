import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'screens/history/villasis_history_screen.dart';
import 'theme/app_theme.dart';
import 'screens/modes/standard_quiz_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'History of Villasis',
      theme: AppTheme.lightTheme,
      initialRoute: HomeScreen.routeName,
      routes: <String, WidgetBuilder>{
        HomeScreen.routeName: (_) => const HomeScreen(),
        VillasisHistoryScreen.routeName: (_) => const VillasisHistoryScreen(),
        CasualModeScreen.routeName: (_) => const CasualModeScreen(),
        SurvivalModeScreen.routeName: (_) => const SurvivalModeScreen(),
      },
    );
  }
}
