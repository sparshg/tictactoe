import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;
  static const String _kresource = 'resource';
  static Future init() async => _prefs = await SharedPreferences.getInstance();

  static Future setResource(bool newVal) async =>
      await _prefs.setBool(_kresource, newVal);

  static bool? getResource() => _prefs.getBool(_kresource);
}
