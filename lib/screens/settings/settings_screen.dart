import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/history_progress_service.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  Future<bool> _confirm(BuildContext context, String title, String message) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('CONFIRM')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _resetHistoryProgress(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      'Reset History Progress?',
      'This clears your saved chapter and restarts the history quiz from the introduction.',
    );
    if (!confirmed) return;
    await HistoryProgress.clear(kVillasisHistoryStoryId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History progress reset.')),
      );
    }
  }

  Future<void> _clearAppData(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      'Clear App Data?',
      'This erases all saved progress, stats and settings, and cannot be undone.',
    );
    if (!confirmed) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SettingsService.instance.resetToDefaults();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All app data cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: SettingsService.instance,
        builder: (BuildContext context, Widget? child) {
          final SettingsService settings = SettingsService.instance;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              const _SectionHeader('Appearance'),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  value: settings.darkMode,
                  onChanged: settings.setDarkMode,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        children: <Widget>[
                          Icon(Icons.text_fields_rounded),
                          SizedBox(width: 12),
                          Text('Text Size'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<AppTextSize>(
                        segments: AppTextSize.values
                            .map((AppTextSize size) => ButtonSegment<AppTextSize>(
                                  value: size,
                                  label: Text(size.label),
                                ))
                            .toList(growable: false),
                        selected: <AppTextSize>{settings.textSize},
                        onSelectionChanged: (Set<AppTextSize> selection) =>
                            settings.setTextSize(selection.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionHeader('Sound'),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text('Sound Effects'),
                  value: settings.soundEnabled,
                  onChanged: settings.setSoundEnabled,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.volume_down_rounded),
                      Expanded(
                        child: Slider(
                          value: settings.soundVolume,
                          onChanged: settings.soundEnabled ? settings.setSoundVolume : null,
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionHeader('Data'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: const Text('Reset History Progress'),
                  subtitle: const Text('Restart the Villasis history quiz from the beginning'),
                  onTap: () => _resetHistoryProgress(context),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                  title: const Text('Clear App Data'),
                  subtitle: const Text('Erase all progress, stats and settings'),
                  onTap: () => _clearAppData(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
