import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _consentKey = 'silencemap_consent_v1';

  bool _loaded = false;
  bool _consentGiven = false;

  bool get loaded => _loaded;
  bool get consentGiven => _consentGiven;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _consentGiven = prefs.getBool(_consentKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    _consentGiven = true;
    notifyListeners();
  }

  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, false);
    _consentGiven = false;
    notifyListeners();
  }
}