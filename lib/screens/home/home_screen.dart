import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    tooltip: 'Stats',
                    onPressed: () => Navigator.of(context).pushNamed(StatsScreen.routeName),
                    icon: const Icon(Icons.bar_chart_rounded),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => Navigator.of(context).pushNamed(SettingsScreen.routeName),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.bolt_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 42,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HISTORY OF VILLASIS',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A chat-guided journey through Villasis, Pangasinan.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'START HISTORY',
                icon: Icons.auto_stories_rounded,
                onPressed: () =>
                    Navigator.of(context).pushNamed('/villasis-history'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'CASUAL MODE',
                icon: Icons.menu_book_rounded,
                onPressed: () => Navigator.of(context).pushNamed('/casual'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'SURVIVAL MODE',
                icon: Icons.shield_rounded,
                onPressed: () => Navigator.of(context).pushNamed('/survival'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
