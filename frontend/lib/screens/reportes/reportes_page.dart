import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/reportes_provider.dart';
import 'package:app/services/reportes_service.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportesProvider>().cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final isSuperAdmin =
        context.watch<AuthProvider>().user?.isSuperAdmin == true;

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      drawer: const AppDrawer(),
      appBar: _ReportesAppBar(
        onRefresh: () => context.read<ReportesProvider>().cargar(),
      ),
      body: switch (provider.state) {
        ReportesLoadState.loading ||
        ReportesLoadState.idle =>
          const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple)),
        ReportesLoadState.error => _ErrorView(
            message: provider.error ?? 'Error al cargar reportes',
            onRetry: () => context.read<ReportesProvider>().cargar(),
          ),
        ReportesLoadState.loaded => _ReportesBody(
            data: provider.data!,
            isSuperAdmin: isSuperAdmin,
          ),
      },
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 0),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _ReportesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  const _ReportesAppBar({required this.onRefresh});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.inputBorder, width: 1)),
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
                'Reportes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.textSecondary, size: 22),
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ReportesBody extends StatelessWidget {
  final ReporteData data;
  final bool isSuperAdmin;
  const _ReportesBody({required this.data, required this.isSuperAdmin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _StatSection(
          title: 'Solicitudes',
          icon: Icons.assignment_outlined,
          stats: [
            _StatItem('Pendientes', data.solicitudes['pendiente'] ?? 0,
                AppColors.statusPendingText, AppColors.statusPendingBg),
            _StatItem('Gestionadas', data.solicitudes['gestionada'] ?? 0,
                AppColors.statusManagedText, AppColors.statusManagedBg),
            _StatItem('Respondidas', data.solicitudes['respondida'] ?? 0,
                AppColors.statusPublishedText, AppColors.statusPublishedBg),
          ],
        ),
        const SizedBox(height: 16),
        _StatSection(
          title: 'Noticias',
          icon: Icons.newspaper_outlined,
          stats: [
            _StatItem('Borradores', data.noticias['borrador'] ?? 0,
                AppColors.statusDraftText, AppColors.statusDraftBg),
            _StatItem('Publicadas', data.noticias['publicado'] ?? 0,
                AppColors.statusPublishedText, AppColors.statusPublishedBg),
          ],
        ),
        const SizedBox(height: 16),
        _StatSection(
          title: 'Testimonios',
          icon: Icons.record_voice_over_outlined,
          stats: [
            _StatItem('Borradores', data.testimonios['borrador'] ?? 0,
                AppColors.statusDraftText, AppColors.statusDraftBg),
            _StatItem('Publicados', data.testimonios['publicado'] ?? 0,
                AppColors.statusPublishedText, AppColors.statusPublishedBg),
            _StatItem(
                'Despublicados',
                data.testimonios['despublicado'] ?? 0,
                AppColors.statusUnpublishedText,
                AppColors.statusUnpublishedBg),
          ],
        ),
        if (isSuperAdmin &&
            data.porPais != null &&
            data.porPais!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _PorPaisSection(porPais: data.porPais!),
        ],
      ],
    );
  }
}

// ─── Stat Section ─────────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final int count;
  final Color textColor;
  final Color bgColor;
  const _StatItem(this.label, this.count, this.textColor, this.bgColor);
}

class _StatSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_StatItem> stats;
  const _StatSection(
      {required this.title, required this.icon, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: stats
                .map((s) => Expanded(child: _StatCard(item: s)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${item.count}',
            style: TextStyle(
              color: item.textColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: item.textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Por País ─────────────────────────────────────────────────────────────────

class _PorPaisSection extends StatelessWidget {
  final List<Map<String, dynamic>> porPais;
  const _PorPaisSection({required this.porPais});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Por País',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('País',
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Sol.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Not.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Tes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.inputBorder),
          ...porPais.map((p) => _PaisRow(data: p)),
        ],
      ),
    );
  }
}

class _PaisRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PaisRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              data['pais'] as String,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text('${data['solicitudes']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text('${data['noticias']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text('${data['testimonios']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.errorColor, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
