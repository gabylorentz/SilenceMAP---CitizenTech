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
    return MaterialApp(
      title: 'SilenceMAP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.gate,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
