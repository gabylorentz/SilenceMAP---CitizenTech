import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../widgets/state_views.dart';
import 'consent_screen.dart';
import 'home_shell.dart';
import 'justification_screen.dart';

class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  bool _introVista = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.loaded) {
      return const Scaffold(body: LoadingView(message: 'Iniciando...'));
    }
    if (!_introVista) {
      return JustificationScreen(
        onContinue: () => setState(() => _introVista = true),
      );
    }
    return settings.consentGiven ? const HomeShell() : const ConsentScreen();
  }
}