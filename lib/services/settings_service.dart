import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTextSize { small, medium, large, extraLarge }

extension AppTextSizeInfo on AppTextSize {
  double get scaleFactor => switch (this) {
    AppTextSize.small => 0.85,
    AppTextSize.medium => 1.0,
    AppTextSize.large => 1.15,
    AppTextSize.extraLarge => 1.3,
  };

  String get label => switch (this) {
    AppTextSize.small => 'Small',
    AppTextSize.medium => 'Medium',
    AppTextSize.large => 'Large',
    AppTextSize.extraLarge => 'Extra Large',
  };
}

/// App-wide user preferences (theme, text size, sound), backed by
/// SharedPreferences and observable so widgets can rebuild on change.
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const String _kDarkMode = 'settings_darkMode';
  static const String _kTextSize = 'settings_textSize';
  static const String _kSoundEnabled = 'settings_soundEnabled';
  static const String _kSoundVolume = 'settings_soundVolume';

  bool _darkMode = false;
  AppTextSize _textSize = AppTextSize.medium;
  bool _soundEnabled = true;
  double _soundVolume = 0.8;

  bool get darkMode => _darkMode;
  AppTextSize get textSize => _textSize;
  bool get soundEnabled => _soundEnabled;
  double get soundVolume => _soundVolume;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_kDarkMode) ?? false;
    final int textSizeIndex = prefs.getInt(_kTextSize) ?? AppTextSize.medium.index;
    _textSize = AppTextSize.values[textSizeIndex.clamp(0, AppTextSize.values.length - 1)];
    _soundEnabled = prefs.getBool(_kSoundEnabled) ?? true;
    _soundVolume = prefs.getDouble(_kSoundVolume) ?? 0.8;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> setTextSize(AppTextSize value) async {
    _textSize = value;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTextSize, value.index);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEnabled, value);
  }

  Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSoundVolume, value);
  }

  /// Realigns in-memory state with defaults after a full "Clear App Data" wipe.
  void resetToDefaults() {
    _darkMode = false;
    _textSize = AppTextSize.medium;
    _soundEnabled = true;
    _soundVolume = 0.8;
    notifyListeners();
  }
}
