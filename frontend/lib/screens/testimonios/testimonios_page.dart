import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/models/testimonio_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/screens/testimonios/formulario_testimonios_page.dart';
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
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestimoniosProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TestimonioModel> _filtered(List<TestimonioModel> all) {
    var list = all;

    if (_selectedFilter != 0) {
      final estado =
          ['', 'publicado', 'borrador', 'despublicado'][_selectedFilter];
      list = list.where((t) => t.estado == estado).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((t) =>
              t.nombre.toLowerCase().contains(q) ||
              t.testimonio.toLowerCase().contains(q) ||
              t.pais.nombre.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TestimoniosProvider>();
    final user = context.watch<AuthProvider>().user;
    final items = _filtered(provider.testimonios);

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _TestimoniosAppBar(
        user: user,
        showSearch: _showSearch,
        onToggleSearch: () {
          setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) {
              _searchQuery = '';
              _searchController.clear();
            }
          });
        },
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
            ),
          AppFilterBar(
            filters: const [
              'Todos',
              'Publicados',
              'Borradores',
              'Despublicados'
            ],
            selectedIndex: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
          ),
          Expanded(
            child: provider.state == TestimoniosLoadState.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.record_voice_over_outlined,
                              color: AppColors.textHint,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Sin resultados para "$_searchQuery"'
                                  : 'Sin testimonios en esta categoría',
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 14),
                            ),
                          ],
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
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormularioTestimoniosPage(testimonio: t),
                              ),
                            ),
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
  final bool showSearch;
  final VoidCallback onToggleSearch;

  const _TestimoniosAppBar({
    this.user,
    required this.showSearch,
    required this.onToggleSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final pais = user?.paisAsignado?.nombre ?? 'Global';

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
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: AppColors.primary, size: 24),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const Text(
                    'Testimonios',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.metricDraftBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pais.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              onPressed: onToggleSearch,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

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
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, testimonio, país...',
          hintStyle:
              const TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textHint, size: 20),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
  final VoidCallback onEdit;

  const _TestimonioCard({
    required this.testimonio,
    required this.canChangeState,
    required this.onToggleVisibility,
    required this.onEdit,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onEdit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.metricDraftBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: AppColors.primaryPurple,
                                        size: 13),
                                    SizedBox(width: 4),
                                    Text(
                                      'Editar',
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (canChangeState) ...[
                              const SizedBox(width: 8),
                              const Text(
                                'VISIBILIDAD',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
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
