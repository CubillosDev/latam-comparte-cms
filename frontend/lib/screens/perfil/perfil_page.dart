import 'package:app/core/app/app_colors.dart';
import 'package:app/models/user_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final rolLabel = switch (user?.rol) {
      'superadmin' => 'Super Administrador',
      'admin_pais' => 'Administrador de País',
      'editor' => 'Editor de Contenido',
      _ => 'Usuario',
    };
    final paisLabel = user?.paisAsignado?.nombre ?? 'Global (todos los países)';
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      drawer: const AppDrawer(),
      appBar: _PerfilAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _AvatarCard(user: user, nombre: user?.nombre ?? '', rolLabel: rolLabel),
          const SizedBox(height: 20),
          _InfoSection(
            title: 'Información de la cuenta',
            items: [
              _InfoItem(
                icon: Icons.person_outline_rounded,
                label: 'Nombre',
                value: user?.nombre ?? '—',
              ),
              _InfoItem(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: user?.correo ?? '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Rol y permisos',
            items: [
              _InfoItem(
                icon: Icons.shield_outlined,
                label: 'Rol',
                value: rolLabel,
                valueColor: AppColors.primaryPurple,
              ),
              _InfoItem(
                icon: Icons.public_rounded,
                label: 'País asignado',
                value: paisLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PermissionsCard(rol: user?.rol ?? ''),
          const SizedBox(height: 32),
          _LogoutButton(),
        ],
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 3),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _PerfilAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: AppColors.primary, size: 24),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const Expanded(
              child: Text(
                'Mi perfil',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Card ──────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final User? user;
  final String nombre;
  final String rolLabel;

  const _AvatarCard({
    required this.user,
    required this.nombre,
    required this.rolLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x28000000), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Base
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9B5FD4), Color(0xFF4A1580)],
                  ),
                ),
              ),
            ),
            // Figuras abstractas
            Positioned(
              top: -65,
              left: -45,
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
              bottom: -50,
              right: -35,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -15,
              right: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 50,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: -10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        user?.logoAsset ?? 'assets/logos/latam.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      rolLabel,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Info Section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  items[i],
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.metricDraftBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Permissions Card ─────────────────────────────────────────────────────────

class _PermissionsCard extends StatelessWidget {
  final String rol;
  const _PermissionsCard({required this.rol});

  @override
  Widget build(BuildContext context) {
    final permisos = switch (rol) {
      'superadmin' => [
          (Icons.public_rounded, 'Acceso a todos los países', true),
          (Icons.newspaper_outlined, 'Gestionar noticias (todos los países)', true),
          (Icons.record_voice_over_outlined, 'Gestionar testimonios', true),
          (Icons.assignment_outlined, 'Gestionar solicitudes', true),
          (Icons.delete_outline_rounded, 'Eliminar contenido', true),
          (Icons.group_outlined, 'Gestionar usuarios', true),
        ],
      'admin_pais' => [
          (Icons.public_rounded, 'Acceso solo a su país', true),
          (Icons.newspaper_outlined, 'Gestionar noticias (su país)', true),
          (Icons.record_voice_over_outlined, 'Gestionar testimonios (su país)', true),
          (Icons.assignment_outlined, 'Gestionar solicitudes (su país)', true),
          (Icons.delete_outline_rounded, 'Eliminar contenido', true),
          (Icons.group_outlined, 'Gestionar usuarios', false),
        ],
      _ => [
          (Icons.public_rounded, 'Acceso solo a su país', true),
          (Icons.newspaper_outlined, 'Crear y editar noticias', true),
          (Icons.record_voice_over_outlined, 'Crear y editar testimonios', true),
          (Icons.assignment_outlined, 'Ver solicitudes', false),
          (Icons.delete_outline_rounded, 'Eliminar contenido', false),
          (Icons.group_outlined, 'Gestionar usuarios', false),
        ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'PERMISOS DEL ROL',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: permisos.map((p) {
              final (icon, label, allowed) = p;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(icon,
                        color: allowed ? AppColors.primaryPurple : AppColors.textHint,
                        size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: allowed ? AppColors.textPrimary : AppColors.textHint,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      allowed ? Icons.check_circle_rounded : Icons.cancel_outlined,
                      color: allowed ? AppColors.statusPublishedText : AppColors.textHint,
                      size: 18,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas salir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.errorColor, size: 20),
            SizedBox(width: 10),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
