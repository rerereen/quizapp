import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'screens/history/villasis_history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'screens/modes/standard_quiz_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'History of Villasis',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: SettingsService.instance.darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(SettingsService.instance.textSize.scaleFactor),
            ),
            child: child!,
          ),
          initialRoute: HomeScreen.routeName,
          routes: <String, WidgetBuilder>{
            HomeScreen.routeName: (_) => const HomeScreen(),
            VillasisHistoryScreen.routeName: (_) => const VillasisHistoryScreen(),
            CasualModeScreen.routeName: (_) => const CasualModeScreen(),
            SurvivalModeScreen.routeName: (_) => const SurvivalModeScreen(),
            SettingsScreen.routeName: (_) => const SettingsScreen(),
            StatsScreen.routeName: (_) => const StatsScreen(),
          },
        );
      },
    );
  }
}
