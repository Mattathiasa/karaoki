/// Runtime app configuration flags shared across services and screens.
///
/// Firebase is only considered configured when firebase_options.dart holds
/// real credentials instead of the `YOUR_*` placeholders that ship with a
/// fresh flutterfire configure run.
class AppConfig {
  /// Whether Firebase was initialized with real (non-placeholder) credentials.
  ///
  /// Screens and services use this to fall back to stub/local behavior so the
  /// app stays fully testable before real Firebase credentials are added.
  static bool isFirebaseConfigured = false;
}
