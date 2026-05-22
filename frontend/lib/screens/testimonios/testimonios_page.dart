import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/models/testimonio_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/common/app_filter_bar.dart';
import 'package:app/widgets/common/app_gradient_fab.dart';
import 'package:app/widgets/common/status_badge.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestimoniosPage extends StatefulWidget {
  const TestimoniosPage({super.key});

  @override
  State<TestimoniosPage> createState() => _TestimoniosPageState();
}

class _TestimoniosPageState extends State<TestimoniosPage> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestimoniosProvider>().cargar();
    });
  }

  List<TestimonioModel> _filtered(List<TestimonioModel> all) {
    if (_selectedFilter == 0) return all;
    final estado = ['', 'publicado', 'borrador', 'despublicado'][_selectedFilter];
    return all.where((t) => t.estado == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TestimoniosProvider>();
    final user = context.watch<AuthProvider>().user;
    final items = _filtered(provider.testimonios);

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _TestimoniosAppBar(user: user),
      body: Column(
        children: [
          AppFilterBar(
            filters: const ['Todos', 'Publicados', 'Borradores', 'Despublicados'],
            selectedIndex: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
          ),
          Expanded(
            child: provider.state == TestimoniosLoadState.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin testimonios en esta categoría',
                          style:
                              TextStyle(color: AppColors.textHint, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final t = items[i];
                          return _TestimonioCard(
                            testimonio: t,
                            canChangeState: user?.canDelete ?? false,
                            onToggleVisibility: (visible) {
                              final nuevoEstado =
                                  visible ? 'publicado' : 'despublicado';
                              context
                                  .read<TestimoniosProvider>()
                                  .cambiarEstado(t.id, nuevoEstado);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: AppGradientFab(
        onPressed: () =>
            Navigator.pushNamed(context, '/testimonios/nuevo'),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 2),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _TestimoniosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic user;
  const _TestimoniosAppBar({this.user});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final pais = user?.paisAsignado?.nombre ?? 'Global';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu_rounded,
                    color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Testimonios',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pais,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded,
                    color: AppColors.white, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Testimonio Card ──────────────────────────────────────────────────────────

class _TestimonioCard extends StatelessWidget {
  final TestimonioModel testimonio;
  final bool canChangeState;
  final ValueChanged<bool> onToggleVisibility;

  const _TestimonioCard({
    required this.testimonio,
    required this.canChangeState,
    required this.onToggleVisibility,
  });

  Color get _borderColor => switch (testimonio.status) {
        BadgeStatus.published => AppColors.borderPublished,
        BadgeStatus.draft => AppColors.borderDraft,
        BadgeStatus.unpublished => AppColors.borderUnpublished,
        _ => AppColors.borderDraft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(testimonio: testimonio),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonio.nombre,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                testimonio.pais.nombre,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: testimonio.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      testimonio.testimonio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          testimonio.date,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                        if (canChangeState)
                          Row(
                            children: [
                              const Text(
                                'VISIBILIDAD',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: testimonio.isVisible,
                                  onChanged: onToggleVisibility,
                                  activeThumbColor: AppColors.primaryPurple,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final TestimonioModel testimonio;
  const _Avatar({required this.testimonio});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: testimonio.avatarColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          testimonio.initials,
          style: TextStyle(
            color: testimonio.avatarColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
