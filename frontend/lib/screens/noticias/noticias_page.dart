import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/models/noticia_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/screens/noticias/formulario_noticias_page.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/common/app_filter_bar.dart';
import 'package:app/widgets/common/app_gradient_fab.dart';
import 'package:app/widgets/common/status_badge.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _SortOption { newest, oldest, az }

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  int _selectedFilter = 0;
  bool _showSearch = false;
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.newest;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticiasProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NoticiaModel> _filtered(List<NoticiaModel> all) {
    var list = all;

    if (_selectedFilter != 0) {
      final estado = ['', 'publicado', 'borrador', 'despublicado'][_selectedFilter];
      list = list.where((n) => n.estado == estado).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.titulo.toLowerCase().contains(q) ||
              n.autor.toLowerCase().contains(q) ||
              n.resumen.toLowerCase().contains(q))
          .toList();
    }

    list = List.of(list);
    switch (_sortOption) {
      case _SortOption.newest:
        list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      case _SortOption.oldest:
        list.sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));
      case _SortOption.az:
        list.sort((a, b) => a.titulo.compareTo(b.titulo));
    }

    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SortSheet(
        current: _sortOption,
        onSelected: (opt) {
          setState(() => _sortOption = opt);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticiasProvider>();
    final user = context.watch<AuthProvider>().user;
    final items = _filtered(provider.noticias);

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _NoticiasAppBar(
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
      drawer: const AppDrawer(),
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
            filters: const ['Todas', 'Publicadas', 'Borradores', 'Despublicadas'],
            selectedIndex: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
            trailing: GestureDetector(
              onTap: _showSortSheet,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _sortOption != _SortOption.newest
                      ? AppColors.metricDraftBg
                      : AppColors.metricInactiveBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.sort_rounded,
                  color: _sortOption != _SortOption.newest
                      ? AppColors.primaryPurple
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.state == NoticiasLoadState.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.newspaper_outlined,
                              color: AppColors.textHint,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Sin resultados para "$_searchQuery"'
                                  : 'Sin noticias en esta categoría',
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
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) {
                          final noticia = items[i];
                          return _NoticiaCard(
                            noticia: noticia,
                            canChangeState: user?.canDelete ?? false,
                            onToggle: (visible) {
                              final nuevoEstado =
                                  visible ? 'publicado' : 'borrador';
                              context
                                  .read<NoticiasProvider>()
                                  .cambiarEstado(noticia.id, nuevoEstado);
                            },
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormularioNoticiasPage(noticia: noticia),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: AppGradientFab(
        onPressed: () => Navigator.pushNamed(context, '/noticias/nuevo'),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 2),
    );
  }
}

// ─── Sort Sheet ───────────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelected;

  const _SortSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final options = [
      (_SortOption.newest, Icons.arrow_downward_rounded, 'Más recientes primero'),
      (_SortOption.oldest, Icons.arrow_upward_rounded, 'Más antiguas primero'),
      (_SortOption.az, Icons.sort_by_alpha_rounded, 'Alfabético (A → Z)'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ordenar por',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((opt) {
            final (val, icon, label) = opt;
            final isSelected = val == current;
            return GestureDetector(
              onTap: () => onSelected(val),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.metricDraftBg
                      : AppColors.formBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.textSecondary,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primaryPurple, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _NoticiasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic user;
  final bool showSearch;
  final VoidCallback onToggleSearch;

  const _NoticiasAppBar({
    this.user,
    required this.showSearch,
    required this.onToggleSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final pais = (user?.paisAsignado != null)
        ? '${user!.paisAsignado!.nombre}'
        : 'Global';

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
            const Text(
              'Noticias',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            const Spacer(),
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
              color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por título, autor, resumen...',
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

// ─── Noticia Card ─────────────────────────────────────────────────────────────

class _NoticiaCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _NoticiaCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return noticia.hasImage
        ? _ImageCard(
            noticia: noticia,
            canChangeState: canChangeState,
            onToggle: onToggle,
            onEdit: onEdit)
        : _BorderCard(
            noticia: noticia,
            canChangeState: canChangeState,
            onToggle: onToggle,
            onEdit: onEdit);
  }
}

// ─── Card con imagen ──────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _ImageCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: noticia.thumbnailColor,
                  child: Center(
                    child: Icon(noticia.thumbnailIcon,
                        color: Colors.white.withValues(alpha: 0.3), size: 64),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _CategoryChip(
                    label: noticia.category,
                    bg: noticia.categoryColor.withValues(alpha: 0.9),
                    textColor: AppColors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noticia.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AuthorRow(noticia: noticia),
                  const SizedBox(height: 8),
                  Text(
                    noticia.resumen,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.inputBorder),
                  const SizedBox(height: 10),
                  _CardFooter(
                    status: noticia.status,
                    isVisible: noticia.isVisible,
                    canChangeState: canChangeState,
                    onToggle: onToggle,
                    onEdit: onEdit,
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

// ─── Card con borde lateral ───────────────────────────────────────────────────

class _BorderCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _BorderCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: noticia.borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryChip(
                      label: noticia.category,
                      bg: AppColors.metricInactiveBg,
                      textColor: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      noticia.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AuthorRow(noticia: noticia),
                    const SizedBox(height: 8),
                    Text(
                      noticia.resumen,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    const SizedBox(height: 10),
                    _CardFooter(
                      status: noticia.status,
                      isVisible: noticia.isVisible,
                      canChangeState: canChangeState,
                      onToggle: onToggle,
                      onEdit: onEdit,
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

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _CategoryChip({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final NoticiaModel noticia;
  const _AuthorRow({required this.noticia});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: noticia.authorColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              noticia.authorInitials,
              style: TextStyle(
                color: noticia.authorColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${noticia.autor} · ${noticia.date}',
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  final BadgeStatus status;
  final bool isVisible;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _CardFooter({
    required this.status,
    required this.isVisible,
    required this.canChangeState,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusBadge(status: status),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.metricDraftBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.primaryPurple, size: 13),
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
              Text(
                isVisible ? 'VISIBLE' : 'OCULTO',
                style: const TextStyle(
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
                  value: isVisible,
                  onChanged: onToggle,
                  activeThumbColor: AppColors.primaryPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
