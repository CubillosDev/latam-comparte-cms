import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:app/provider/solicitudes_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/screens/noticias/formulario_noticias_page.dart';
import 'package:app/screens/testimonios/formulario_testimonios_page.dart';
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
    final pais = context.watch<AuthProvider>().user?.paisAsignado;

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Mi Panel'),
        actions: [
          if (pais != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pais.nombre,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
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
                color: AppColors.white,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/solicitudes/detalle',
                    arguments: s,
                  ),
                  child: ListItemRow(
                    title: s.nombre,
                    subtitle: s.pais.nombre,
                    leading: AvatarLeading(initials: s.initials),
                    trailing: const StatusBadge(status: BadgeStatus.pending),
                    showDivider: i < items.length - 1,
                  ),
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
      actionLabel: 'Ver todos',
      onAction: () => Navigator.pushNamed(context, '/contenido'),
      child: Column(
        children: [
          ...List.generate(items.length, (i) {
            final t = items[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioTestimoniosPage(testimonio: t),
                ),
              ),
              child: ListItemRow(
                title: t.nombre,
                subtitle: t.pais.nombre,
                leading: AvatarLeading(initials: t.initials, color: t.avatarColor),
                trailing: StatusBadge(status: t.status),
                showDivider: i < items.length - 1,
              ),
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
      actionLabel: 'Ver todas',
      onAction: () => Navigator.pushNamed(context, '/noticias'),
      child: Column(
        children: [
          ...List.generate(items.length, (i) {
            final n = items[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioNoticiasPage(noticia: n),
                ),
              ),
              child: ListItemRow(
                title: n.titulo,
                subtitle: n.pais.nombre,
                leading: ImageLeading(color: n.thumbnailColor, icon: n.thumbnailIcon),
                trailing: StatusBadge(status: n.status),
                showDivider: i < items.length - 1,
              ),
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
