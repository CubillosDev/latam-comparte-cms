import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SectionLabel('NAVEGACIÓN'),
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard Global',
                  route: '/dashboard',
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Panel por País',
                  route: '/dashboard/pais',
                ),
                _DrawerItem(
                  icon: Icons.public_rounded,
                  label: 'Portales',
                  route: '/portales',
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _SectionLabel('CONTENIDO'),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  label: 'Solicitudes',
                  route: '/solicitudes',
                ),
                _DrawerItem(
                  icon: Icons.article_outlined,
                  label: 'Testimonios',
                  route: '/contenido',
                ),
                _DrawerItem(
                  icon: Icons.newspaper_outlined,
                  label: 'Noticias',
                  route: '/noticias',
                ),
                _DrawerItem(
                  icon: Icons.contact_mail_outlined,
                  label: 'Contacto Público',
                  route: '/contacto',
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _SectionLabel('PRÓXIMAMENTE'),
                _DrawerItemDisabled(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reportes',
                ),
                _DrawerItemDisabled(
                  icon: Icons.group_outlined,
                  label: 'Usuarios',
                ),
                _DrawerItemDisabled(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _LogoutItem(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final rolLabel = switch (user?.rol) {
      'superadmin' => 'Super Administrador',
      'admin_pais' => 'Admin · ${user?.paisAsignado?.nombre ?? ''}',
      'editor' => 'Editor · ${user?.paisAsignado?.nombre ?? ''}',
      _ => 'Usuario',
    };

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.public_rounded,
                color: AppColors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            user?.nombre ?? 'Panel Administrativo',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rolLabel,
            style: const TextStyle(
              color: AppColors.whiteTransparent,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final isActive = current == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.metricDraftBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primaryPurple : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryPurple : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          if (current != route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}

// ─── Disabled Item ────────────────────────────────────────────────────────────

class _DrawerItemDisabled extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DrawerItemDisabled({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textHint, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.metricInactiveBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Pronto',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        dense: true,
        enabled: false,
      ),
    );
  }
}

// ─── Logout ───────────────────────────────────────────────────────────────────

class _LogoutItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded,
            color: AppColors.errorColor, size: 22),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: AppColors.errorColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
      ),
    );
  }
}
