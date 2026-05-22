import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:app/models/solicitud_model.dart';
import 'package:app/provider/solicitudes_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/common/app_filter_bar.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _filters = [
    'Todos',
    'Pendiente',
    'Gestionada',
    'Respondida',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudesProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SolicitudModel> _filtered(List<SolicitudModel> all) {
    var list = all;

    if (_selectedFilter != 0) {
      final label = _filters[_selectedFilter].toLowerCase();
      list = list.where((s) {
        if (label == 'pendiente') return s.status == SolicitudStatus.pendiente;
        if (label == 'gestionada') return s.status == SolicitudStatus.gestionada;
        if (label == 'respondida') return s.status == SolicitudStatus.respondida;
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.nombre.toLowerCase().contains(q) ||
        s.correo.toLowerCase().contains(q) ||
        s.finalidad.toLowerCase().contains(q) ||
        s.pais.nombre.toLowerCase().contains(q),
      ).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudesProvider>();
    final items = _filtered(provider.solicitudes);

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _SolicitudesAppBar(pendingCount: provider.solicitudes
          .where((s) => s.isPendiente).length),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                _SearchBar(
                  controller: _searchController,
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
                const SizedBox(height: 12),
                AppFilterBar(
                  filters: _filters,
                  selectedIndex: _selectedFilter,
                  onSelected: (i) => setState(() => _selectedFilter = i),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Expanded(
            child: provider.state == SolicitudesLoadState.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                color: AppColors.textHint, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Sin resultados para "$_searchQuery"'
                                  : 'Sin solicitudes en esta categoría',
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) => _SolicitudCard(
                          solicitud: items[i],
                          query: _searchQuery,
                          onVerDetalle: () => Navigator.pushNamed(
                            context,
                            '/solicitudes/detalle',
                            arguments: items[i],
                          ),
                        ),
                      ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 1),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _SolicitudesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int pendingCount;
  const _SolicitudesAppBar({required this.pendingCount});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu_rounded,
                    color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Solicitudes de contacto',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (pendingCount > 0)
                Stack(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.white, size: 24),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 4),
            ],
          ),
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
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, email, finalidad...',
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

// ─── Solicitud Card ───────────────────────────────────────────────────────────

class _SolicitudCard extends StatelessWidget {
  final SolicitudModel solicitud;
  final VoidCallback onVerDetalle;
  final String query;

  const _SolicitudCard({
    required this.solicitud,
    required this.onVerDetalle,
    this.query = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientAvatar(
                  initials: solicitud.initials,
                  start: solicitud.avatarStart,
                  end: solicitud.avatarEnd,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HighlightText(
                        text: solicitud.nombre,
                        query: query,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _CountryCodeBadge(
                            code: solicitud.countryCode,
                            textColor: solicitud.codeTextColor,
                            bgColor: solicitud.codeBgColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${solicitud.receivedTime}',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _SolicitudStatusChip(status: solicitud.status),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.email_outlined,
                text: solicitud.correo,
                query: query),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.phone_outlined, text: solicitud.telefono),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.inputBorder, width: 2),
                ),
              ),
              child: _HighlightText(
                text: solicitud.finalidad,
                query: query,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.inputBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HighlightText(
                  text: 'País: ${solicitud.pais.nombre}',
                  query: query,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: onVerDetalle,
                  child: const Row(
                    children: [
                      Text(
                        'Ver detalle',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.primaryPurple, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  final String initials;
  final Color start;
  final Color end;

  const _GradientAvatar({
    required this.initials,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CountryCodeBadge extends StatelessWidget {
  final String code;
  final Color textColor;
  final Color bgColor;

  const _CountryCodeBadge({
    required this.code,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SolicitudStatusChip extends StatelessWidget {
  final SolicitudStatus status;

  const _SolicitudStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, text) = switch (status) {
      SolicitudStatus.pendiente => (
          'Pendiente',
          AppColors.errorContainer,
          AppColors.errorColor,
        ),
      SolicitudStatus.gestionada => (
          'Gestionada',
          AppColors.statusRespondedBg,
          AppColors.statusRespondedText,
        ),
      SolicitudStatus.respondida => (
          'Respondida',
          AppColors.statusPublishedBg,
          AppColors.statusPublishedText,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String query;

  const _InfoRow({required this.icon, required this.text, this.query = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: _HighlightText(
            text: text,
            query: query,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Highlight Text ───────────────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: const Color(0xFFFFE082),
          color: const Color(0xFF4A1A7A),
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.normal,
        ),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
