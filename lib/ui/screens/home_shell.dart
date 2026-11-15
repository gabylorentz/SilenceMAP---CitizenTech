import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/glass_style.dart';
import 'dashboards_screen.dart';
import 'overview_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;
  static const _titulos = ['Visão geral', 'Dashboards'];

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).extension<GlassStyle>();
    final raio = BorderRadius.circular(32);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _indice,
        children: const [OverviewScreen(), DashboardsScreen()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.occurrence),
        icon: const Icon(Icons.edit_location_alt),
        label: const Text('Registrar ruído'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: estilo?.card,
            borderRadius: raio,
            border: Border.all(color: estilo?.cardBorder ?? Colors.transparent),
          ),
          child: ClipRRect(
            borderRadius: raio,
            child: NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (i) => setState(() => _indice = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Visão geral',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Dashboards',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}