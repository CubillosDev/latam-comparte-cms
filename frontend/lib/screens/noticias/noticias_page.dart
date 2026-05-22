import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/models/noticia_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/common/app_filter_bar.dart';
import 'package:app/widgets/common/app_gradient_fab.dart';
import 'package:app/widgets/common/status_badge.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticiasProvider>().cargar();
    });
  }

  List<NoticiaModel> _filtered(List<NoticiaModel> all) {
    if (_selectedFilter == 0) return all;
    final estado = ['', 'publicado', 'borrador'][_selectedFilter];
    return all.where((n) => n.estado == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticiasProvider>();
    final user = context.watch<AuthProvider>().user;
    final items = _filtered(provider.noticias);

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _NoticiasAppBar(user: user),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppFilterBar(
            filters: const ['Todas', 'Publicadas', 'Borradores'],
            selectedIndex: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
            trailing: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.metricInactiveBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sort_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
          Expanded(
            child: provider.state == NoticiasLoadState.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin noticias en esta categoría',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 14),
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

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _NoticiasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic user;
  const _NoticiasAppBar({this.user});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final pais = (user?.paisAsignado != null)
        ? '${user!.paisAsignado!.nombre}'
        : 'Global';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu_rounded,
                    color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 10),
              const Text(
                'Noticias',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  pais.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
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

// ─── Noticia Card ─────────────────────────────────────────────────────────────

class _NoticiaCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;

  const _NoticiaCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return noticia.hasImage
        ? _ImageCard(
            noticia: noticia,
            canChangeState: canChangeState,
            onToggle: onToggle)
        : _BorderCard(
            noticia: noticia,
            canChangeState: canChangeState,
            onToggle: onToggle);
  }
}

// ─── Card con imagen ──────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool canChangeState;
  final ValueChanged<bool> onToggle;

  const _ImageCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
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

  const _BorderCard({
    required this.noticia,
    required this.canChangeState,
    required this.onToggle,
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

  const _CardFooter({
    required this.status,
    required this.isVisible,
    required this.canChangeState,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusBadge(status: status),
        if (canChangeState)
          Row(
            children: [
              Text(
                isVisible ? 'VISIBLE' : 'OCULTO',
                style: const TextStyle(
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
                  value: isVisible,
                  onChanged: onToggle,
                  activeThumbColor: AppColors.primaryPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
