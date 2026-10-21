import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper over SharedPreferences so providers don't depend on the plugin directly.
/// (For a production app, keep the auth token in flutter_secure_storage instead.)
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  String? read(String key) => _prefs.getString(key);

  Future<void> write(String key, String value) => _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
