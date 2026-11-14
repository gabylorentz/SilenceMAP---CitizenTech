import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _consentKey = 'silencemap_consent_v1';
  static const _themeKey = 'silencemap_theme_v1';
  static const _contrastKey = 'silencemap_contrast_v1';
  static const _textScaleKey = 'silencemap_text_scale_v1';

  static const List<double> textScales = [1.0, 1.15, 1.3];

  bool _loaded = false;
  bool _consentGiven = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;
  double _textScale = 1.0;

  bool get loaded => _loaded;
  bool get consentGiven => _consentGiven;
  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  double get textScale => _textScale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _consentGiven = prefs.getBool(_consentKey) ?? false;

    final nomeTema = prefs.getString(_themeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == nomeTema,
      orElse: () => ThemeMode.system,
    );

    _highContrast = prefs.getBool(_contrastKey) ?? false;

    final escala = prefs.getDouble(_textScaleKey);
    _textScale =
        (escala != null && textScales.contains(escala)) ? escala : 1.0;

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

  Future<void> setThemeMode(ThemeMode modo) async {
    _themeMode = modo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, modo.name);
  }

  Future<void> setHighContrast(bool valor) async {
    _highContrast = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contrastKey, valor);
  }

  Future<void> setTextScale(double escala) async {
    _textScale = escala;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, escala);
  }
}