/// Environment configuration for the app
enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  /// Get current environment
  static Environment get environment => _environment;

  /// Set environment (should be called from main_dev.dart or main_prod.dart)
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Check if running in development
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if running in production
  static bool get isProduction => _environment == Environment.production;

  /// API Base URL based on environment
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.kadam.com';
      case Environment.production:
        return 'https://api.kadam.com';
    }
  }

  /// Enable debug logging
  static bool get enableDebugLogging => isDevelopment;

  /// Enable mock health data
  static bool get enableMockHealthData => isDevelopment;

  /// App name with environment suffix
  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'Kadam (Dev)';
      case Environment.production:
        return 'Kadam';
    }
  }

  /// Firebase timeout duration
  static Duration get firebaseTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.production:
        return const Duration(seconds: 10);
    }
  }

  /// Maximum retry attempts
  static int get maxRetryAttempts => isDevelopment ? 5 : 3;

  /// Show performance overlay
  static bool get showPerformanceOverlay => isDevelopment;

  /// Enable analytics
  static bool get enableAnalytics => isProduction;

  /// Verbose error messages
  static bool get verboseErrors => isDevelopment;
}
