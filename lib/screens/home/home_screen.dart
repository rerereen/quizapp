import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';

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
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HISTORY OF VILLASIS',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A chat-guided journey through Villasis, Pangasinan.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
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
