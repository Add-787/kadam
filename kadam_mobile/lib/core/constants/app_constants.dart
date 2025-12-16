/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Kadam';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';

  // Routes
  static const String homeRoute = '/';
  static const String settingsRoute = '/settings';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
}
