import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:app/provider/solicitudes_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/common/status_badge.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/dashboard/dashboard_card.dart';
import 'package:app/widgets/dashboard/list_item_row.dart';
import 'package:app/widgets/dashboard/metric_box.dart';
import 'package:app/widgets/dashboard/outline_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardAdminPaisPage extends StatefulWidget {
  const DashboardAdminPaisPage({super.key});

  @override
  State<DashboardAdminPaisPage> createState() => _DashboardAdminPaisPageState();
}

class _DashboardAdminPaisPageState extends State<DashboardAdminPaisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaisesProvider>().cargarDashboardPais();
      context.read<SolicitudesProvider>().cargar();
      context.read<TestimoniosProvider>().cargar();
      context.read<NoticiasProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _DashboardAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _WelcomeHeader(),
            SizedBox(height: 20),
            _MetricsSection(),
            SizedBox(height: 16),
            _SolicitudesSection(),
            SizedBox(height: 16),
            _TestimoniosSection(),
            SizedBox(height: 16),
            _NoticiasSection(),
            SizedBox(height: 8),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 0),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pais = user?.paisAsignado;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu_rounded, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mi Panel',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (pais != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pais.nombre,
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
      ),
    );
  }
}

// ─── Welcome ──────────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pais = user?.paisAsignado?.nombre ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${user?.nombre ?? ''}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Administrador · $pais',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

// ─── Metrics ──────────────────────────────────────────────────────────────────

class _MetricsSection extends StatelessWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<PaisesProvider>().dashboardPais;
    final user = context.watch<AuthProvider>().user;
    final codigo = user?.paisAsignado?.codigo ?? '';

    return DashboardCard(
      title: 'Métricas del día',
      subtitle: user?.paisAsignado?.nombre ?? '',
      badge: codigo.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.metricDraftBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  color: AppColors.metricDraftText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          MetricBox(
            value: '${dashboard?.solicitudesPendientes ?? 0}',
            label: 'PENDIENTES',
            valueColor: AppColors.metricPendingText,
            backgroundColor: AppColors.metricPendingBg,
          ),
          const SizedBox(width: 8),
          MetricBox(
            value: '${dashboard?.noticiasActivas ?? 0}',
            label: 'NOTICIAS',
            valueColor: AppColors.metricDraftText,
            backgroundColor: AppColors.metricDraftBg,
          ),
          const SizedBox(width: 8),
          MetricBox(
            value: '${dashboard?.testimoniosPublicados ?? 0}',
            label: 'TESTIMONIOS',
            valueColor: AppColors.metricInactiveText,
            backgroundColor: AppColors.metricInactiveBg,
          ),
        ],
      ),
    );
  }
}

// ─── Solicitudes ──────────────────────────────────────────────────────────────

class _SolicitudesSection extends StatelessWidget {
  const _SolicitudesSection();

  @override
  Widget build(BuildContext context) {
    final items = context.watch<SolicitudesProvider>().solicitudes.take(3).toList();
    return DashboardCard(
      title: 'Últimas solicitudes',
      actionLabel: 'Ver todas',
      onAction: () => Navigator.pushNamed(context, '/solicitudes'),
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text('Sin solicitudes recientes',
                    style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              ),
            )
          : Column(
              children: List.generate(items.length, (i) {
                final s = items[i];
                return ListItemRow(
                  title: s.nombre,
                  subtitle: s.pais.nombre,
                  leading: AvatarLeading(initials: s.initials),
                  trailing: const StatusBadge(status: BadgeStatus.pending),
                  showDivider: i < items.length - 1,
                );
              }),
            ),
    );
  }
}

// ─── Testimonios ──────────────────────────────────────────────────────────────

class _TestimoniosSection extends StatelessWidget {
  const _TestimoniosSection();

  @override
  Widget build(BuildContext context) {
    final items = context.watch<TestimoniosProvider>().testimonios.take(3).toList();
    return DashboardCard(
      title: 'Mis testimonios',
      child: Column(
        children: [
          ...List.generate(items.length, (i) {
            final t = items[i];
            return ListItemRow(
              title: t.nombre,
              subtitle: t.pais.nombre,
              leading: AvatarLeading(initials: t.initials, color: t.avatarColor),
              trailing: StatusBadge(status: t.status),
              showDivider: i < items.length - 1,
            );
          }),
          const SizedBox(height: 12),
          OutlineActionButton(
            label: 'Nuevo testimonio +',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => Navigator.pushNamed(context, '/testimonios/nuevo'),
          ),
        ],
      ),
    );
  }
}

// ─── Noticias ─────────────────────────────────────────────────────────────────

class _NoticiasSection extends StatelessWidget {
  const _NoticiasSection();

  @override
  Widget build(BuildContext context) {
    final items = context.watch<NoticiasProvider>().noticias.take(3).toList();
    return DashboardCard(
      title: 'Mis noticias',
      child: Column(
        children: [
          ...List.generate(items.length, (i) {
            final n = items[i];
            return ListItemRow(
              title: n.titulo,
              subtitle: n.pais.nombre,
              leading: ImageLeading(color: n.thumbnailColor, icon: n.thumbnailIcon),
              trailing: StatusBadge(status: n.status),
              showDivider: i < items.length - 1,
            );
          }),
          const SizedBox(height: 12),
          OutlineActionButton(
            label: 'Nueva noticia +',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => Navigator.pushNamed(context, '/noticias/nuevo'),
          ),
        ],
      ),
    );
  }
}
