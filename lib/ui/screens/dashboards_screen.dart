import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/noise_provider.dart';
import '../widgets/state_views.dart';
import 'impact_dashboard.dart';
import 'levels_dashboard.dart';
import 'sources_dashboard.dart';

class DashboardsScreen extends StatelessWidget {
  const DashboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();

    if (p.status == LoadStatus.loading) return const LoadingView();
    if (p.status == LoadStatus.error) {
      return ErrorView(
        message: p.errorMessage ?? 'Erro desconhecido.',
        onRetry: p.refresh,
      );
    }

    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Níveis'),
              Tab(text: 'Fontes'),
              Tab(text: 'Impacto'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                LevelsDashboard(),
                SourcesDashboard(),
                ImpactDashboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}