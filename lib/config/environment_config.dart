import 'package:flutter/foundation.dart';

/// 環境設定クラス
class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: kDebugMode ? 'development' : 'production',
  );

  /// 現在の環境
  static Environment get currentEnvironment {
    switch (_environment.toLowerCase()) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'staging':
      case 'stg':
        return Environment.staging;
      case 'production':
      case 'prod':
        return Environment.production;
      default:
        return kDebugMode ? Environment.development : Environment.production;
    }
  }

  /// 開発環境かどうか
  static bool get isDevelopment => currentEnvironment == Environment.development;

  /// ステージング環境かどうか
  static bool get isStaging => currentEnvironment == Environment.staging;

  /// 本番環境かどうか
  static bool get isProduction => currentEnvironment == Environment.production;

  /// API設定
  static ApiConfig get apiConfig {
    switch (currentEnvironment) {
      case Environment.development:
        return const ApiConfig(
          baseUrl: 'https://api-dev.motimate.com',
          timeout: Duration(seconds: 30),
          enableLogging: true,
        );
      case Environment.staging:
        return const ApiConfig(
          baseUrl: 'https://api-staging.motimate.com',
          timeout: Duration(seconds: 20),
          enableLogging: true,
        );
      case Environment.production:
        return const ApiConfig(
          baseUrl: 'https://api.motimate.com',
          timeout: Duration(seconds: 15),
          enableLogging: false,
        );
    }
  }

  /// Firebase設定
  static FirebaseConfig get firebaseConfig {
    switch (currentEnvironment) {
      case Environment.development:
        return const FirebaseConfig(
          projectId: 'motimate-dev',
          enableEmulator: true,
          enableAnalytics: false,
          enableCrashlytics: false,
        );
      case Environment.staging:
        return const FirebaseConfig(
          projectId: 'motimate-staging',
          enableEmulator: false,
          enableAnalytics: true,
          enableCrashlytics: true,
        );
      case Environment.production:
        return const FirebaseConfig(
          projectId: 'motimate-prod',
          enableEmulator: false,
          enableAnalytics: true,
          enableCrashlytics: true,
        );
    }
  }

  /// ログ設定
  static LogConfig get logConfig {
    switch (currentEnvironment) {
      case Environment.development:
        return const LogConfig(
          enableConsoleLog: true,
          enableFileLog: true,
          logLevel: LogLevel.debug,
          enableNetworkLog: true,
        );
      case Environment.staging:
        return const LogConfig(
          enableConsoleLog: true,
          enableFileLog: true,
          logLevel: LogLevel.info,
          enableNetworkLog: true,
        );
      case Environment.production:
        return const LogConfig(
          enableConsoleLog: false,
          enableFileLog: true,
          logLevel: LogLevel.warning,
          enableNetworkLog: false,
        );
    }
  }

  /// 機能フラグ設定
  static FeatureFlags get featureFlags {
    switch (currentEnvironment) {
      case Environment.development:
        return const FeatureFlags(
          enableDebugMode: true,
          enableBetaFeatures: true,
          enablePerformanceOverlay: true,
          enableInspector: true,
        );
      case Environment.staging:
        return const FeatureFlags(
          enableDebugMode: false,
          enableBetaFeatures: true,
          enablePerformanceOverlay: false,
          enableInspector: false,
        );
      case Environment.production:
        return const FeatureFlags(
          enableDebugMode: false,
          enableBetaFeatures: false,
          enablePerformanceOverlay: false,
          enableInspector: false,
        );
    }
  }

  /// アプリ設定
  static AppConfig get appConfig {
    return AppConfig(
      appName: _getAppName(),
      version: _getAppVersion(),
      buildNumber: _getBuildNumber(),
      bundleId: _getBundleId(),
    );
  }

  static String _getAppName() {
    switch (currentEnvironment) {
      case Environment.development:
        return 'MotiMate Dev';
      case Environment.staging:
        return 'MotiMate Staging';
      case Environment.production:
        return 'MotiMate';
    }
  }

  static String _getAppVersion() {
    return const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  }

  static String _getBuildNumber() {
    return const String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  }

  static String _getBundleId() {
    switch (currentEnvironment) {
      case Environment.development:
        return 'com.motimate.app.dev';
      case Environment.staging:
        return 'com.motimate.app.staging';
      case Environment.production:
        return 'com.motimate.app';
    }
  }
}

/// 環境列挙型
enum Environment {
  development,
  staging,
  production,
}

/// API設定
class ApiConfig {
  final String baseUrl;
  final Duration timeout;
  final bool enableLogging;

  const ApiConfig({
    required this.baseUrl,
    required this.timeout,
    required this.enableLogging,
  });
}

/// Firebase設定
class FirebaseConfig {
  final String projectId;
  final bool enableEmulator;
  final bool enableAnalytics;
  final bool enableCrashlytics;

  const FirebaseConfig({
    required this.projectId,
    required this.enableEmulator,
    required this.enableAnalytics,
    required this.enableCrashlytics,
  });
}

/// ログ設定
class LogConfig {
  final bool enableConsoleLog;
  final bool enableFileLog;
  final LogLevel logLevel;
  final bool enableNetworkLog;

  const LogConfig({
    required this.enableConsoleLog,
    required this.enableFileLog,
    required this.logLevel,
    required this.enableNetworkLog,
  });
}

/// ログレベル
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 機能フラグ
class FeatureFlags {
  final bool enableDebugMode;
  final bool enableBetaFeatures;
  final bool enablePerformanceOverlay;
  final bool enableInspector;

  const FeatureFlags({
    required this.enableDebugMode,
    required this.enableBetaFeatures,
    required this.enablePerformanceOverlay,
    required this.enableInspector,
  });
}

/// アプリ設定
class AppConfig {
  final String appName;
  final String version;
  final String buildNumber;
  final String bundleId;

  const AppConfig({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.bundleId,
  });
}