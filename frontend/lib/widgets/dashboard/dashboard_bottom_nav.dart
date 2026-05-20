import 'package:flutter/material.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;

  const DashboardBottomNav({super.key, this.currentIndex = 0});

  static const _routes = [
    '/dashboard',
    '/solicitudes',
    '/contenido',
    '/perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (i == currentIndex) return;
        Navigator.pushNamed(context, _routes[i]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Solicitudes',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article_rounded),
          label: 'Contenido',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
