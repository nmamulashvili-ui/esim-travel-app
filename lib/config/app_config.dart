/// Central configuration for the app.
/// Swap values here when moving from mock → real API.
class AppConfig {
  AppConfig._();

  // ── API ───────────────────────────────────────────────
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const Duration apiTimeout = Duration(seconds: 15);

  // ── Feature flags ─────────────────────────────────────
  static const bool useMockData = true; // flip to false when API is ready

  // ── App metadata ──────────────────────────────────────
  static const String appName = 'eSIM Market';
  static const String appVersion = '1.0.0';
}
