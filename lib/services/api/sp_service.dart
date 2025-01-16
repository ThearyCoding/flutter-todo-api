import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  SharedPreferences? _prefs;

  Future<void> setToken(String token) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs!.setString("token", token);
  }

  Future<String?> getToken() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs?.getString("token");
  }

  Future<void> removeToken() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs?.remove("token");
  }
}
