import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/portales/portal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllPortalsPage extends StatefulWidget {
  const AllPortalsPage({super.key});

  @override
  State<AllPortalsPage> createState() => _AllPortalsPageState();
}

class _AllPortalsPageState extends State<AllPortalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaisesProvider>().cargarDashboardSuperAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaisesProvider>();
    final portales = provider.metricasGlobal;

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: const _PortalesAppBar(),
      body: provider.state == PaisesLoadState.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PortalesSubHeader(count: portales.length),
                  const SizedBox(height: 16),
                  ...List.generate(
                    portales.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PortalCard(
                        portal: portales[i],
                        onVerContenido: () => Navigator.pushNamed(context, '/noticias'),
                      ),
                    ),
                  ),
                  const _PortalesFooter(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 3),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _PortalesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PortalesAppBar();

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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.primary, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Portales activos',
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

// ─── Sub-header ───────────────────────────────────────────────────────────────

class _PortalesSubHeader extends StatelessWidget {
  final int count;
  const _PortalesSubHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$count portales registrados',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.inputBorder,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Acceso administrativo global',
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _PortalesFooter extends StatelessWidget {
  const _PortalesFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metricDraftBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.primaryPurple, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los portales se administran de forma independiente. Como Superadmin, tienes acceso total a la moderación de contenido y gestión de solicitudes para todas las regiones.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
