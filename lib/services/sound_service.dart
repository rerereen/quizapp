import 'settings_service.dart';

/// Sound effect hooks used across the quiz screens.
enum SoundEffect { correctAnswer, incorrectAnswer, chapterComplete, buttonTap, gameOver }

/// Placeholder audio player.
///
/// To wire up real sound effects later:
/// 1. Add an audio package to pubspec.yaml (e.g. `audioplayers` or `just_audio`).
/// 2. Drop sound files under assets/sounds/ (e.g. assets/sounds/correct.mp3)
///    and list them under `flutter: assets:` in pubspec.yaml.
/// 3. Implement `play()` below to load/play the asset for each [SoundEffect]
///    at `SettingsService.instance.soundVolume`.
/// Call sites (villasis_history_screen.dart, standard_quiz_screens.dart)
/// already call `SoundService.instance.play(...)` next to the haptic feedback
/// calls, so no other wiring is needed once this class plays real audio.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  Future<void> play(SoundEffect effect) async {
    if (!SettingsService.instance.soundEnabled) return;
    // TODO(sound): play the asset mapped to `effect` at
    // SettingsService.instance.soundVolume once audio assets are added.
  }
}
