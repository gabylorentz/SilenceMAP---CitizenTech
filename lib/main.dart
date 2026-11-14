
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/noise_repository.dart';
import 'data/services/mock_noise_api_service.dart';
import 'providers/noise_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(
          create: (_) =>
              NoiseProvider(NoiseRepository(MockNoiseApiService()))..init(),
        ),
      ],
      child: const SilenceMapApp(),
    ),
  );
}

class SilenceMapApp extends StatelessWidget {
  const SilenceMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'SilenceMAP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: s.highContrast),
      darkTheme: AppTheme.dark(highContrast: s.highContrast),
      // Também liga sozinho se o sistema operacional pedir alto contraste.
      highContrastTheme: AppTheme.light(highContrast: true),
      highContrastDarkTheme: AppTheme.dark(highContrast: true),
      themeMode: s.themeMode,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler:
                TextScaler.linear(mq.textScaler.scale(1.0) * s.textScale),
          ),
          child: child!,
        );
      },
      initialRoute: AppRoutes.gate,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}