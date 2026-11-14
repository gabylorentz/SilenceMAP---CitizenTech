import 'package:flutter/material.dart';

import '../../ui/screens/alert_detail_screen.dart';
import '../../ui/screens/occurrence_screen.dart';
import '../../ui/screens/settings_screen.dart';
import '../../ui/screens/start_gate.dart';
import '../../ui/widgets/state_views.dart';

class AppRoutes {
  AppRoutes._();

  static const gate = '/';
  static const alertDetail = '/alert';
  static const occurrence = '/occurrence';
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case gate:
        return _page(const StartGate(), settings);
      case alertDetail:
        final regionId = settings.arguments;
        if (regionId is! String) return _notFound(settings);
        return _page(AlertDetailScreen(regionId: regionId), settings);
      case occurrence:
        return _page(const OccurrenceScreen(), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      default:
        return _notFound(settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget tela, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => tela, settings: s);

  static MaterialPageRoute<dynamic> _notFound(RouteSettings s) => _page(
        Scaffold(
          appBar: AppBar(title: const Text('SilenceMAP')),
          body: const EmptyView(message: 'Página não encontrada.'),
        ),
        s,
      );
}