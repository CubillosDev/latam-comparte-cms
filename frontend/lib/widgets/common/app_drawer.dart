import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin =
        context.watch<AuthProvider>().user?.isSuperAdmin == true;

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
                _SectionLabel('ADMINISTRACIÓN'),
                _DrawerItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reportes',
                  route: '/reportes',
                ),
                if (isSuperAdmin)
                  _DrawerItem(
                    icon: Icons.group_outlined,
                    label: 'Usuarios',
                    route: '/usuarios',
                  ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _SectionLabel('CUENTA'),
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Mi Perfil',
                  route: '/perfil',
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  route: '/configuracion',
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

    final nombre = user?.nombre ?? '';
    final parts = nombre.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : nombre.isNotEmpty
            ? nombre[0].toUpperCase()
            : 'U';

    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9B5FD4), Color(0xFF4A1580)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Figuras abstractas ──────────────────────────────────────
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -45,
              left: 30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 100,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 20,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ── Contenido ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre.isNotEmpty ? nombre : 'Panel Administrativo',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rolLabel,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                        if (user?.correo != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.correo,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.40),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
