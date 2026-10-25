/// Build-time configuration. Override with `--dart-define=API_BASE_URL=https://api.example.kz`.
abstract final class AppConfig {
  /// Default targets the Android emulator's host loopback; use your LAN IP for a physical device.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');
  static const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '0.1.0');
  static const apiPrefix = '/api/v1';
}
