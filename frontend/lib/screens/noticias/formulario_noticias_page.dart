import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/forms/app_country_dropdown.dart';
import 'package:app/widgets/forms/app_form_card.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:app/widgets/forms/app_segmented_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormularioNoticiasPage extends StatefulWidget {
  const FormularioNoticiasPage({super.key});

  @override
  State<FormularioNoticiasPage> createState() => _FormularioNoticiasPageState();
}

class _FormularioNoticiasPageState extends State<FormularioNoticiasPage> {
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _resumenController = TextEditingController();
  final _contenidoController = TextEditingController();

  PaisModel? _selectedCountry;
  int _selectedStatus = 0; // 0=Borrador, 1=Publicado
  int _contenidoChars = 0;
  bool _saving = false;
  static const int _maxContenido = 2500;

  @override
  void initState() {
    super.initState();
    _contenidoController.addListener(() {
      setState(() => _contenidoChars = _contenidoController.text.length);
    });
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _resumenController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _onPublish() async {
    final titulo = _titleController.text.trim();
    final resumen = _resumenController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty || resumen.isEmpty || contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa título, resumen y contenido'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    final paisId = _selectedCountry?.id ?? user?.paisAsignado?.id ?? '';

    if (paisId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un país'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final ok = await context.read<NoticiasProvider>().crear({
      'titulo': titulo,
      'resumen': resumen,
      'contenido': contenido,
      'autor': user?.nombre ?? 'Admin',
      'pais': paisId,
      'estado': ['borrador', 'publicado'][_selectedStatus],
      if (_imageUrlController.text.isNotEmpty)
        'imagen_url': _imageUrlController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la noticia'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdminPais = user?.isAdminPais == true || user?.isEditor == true;

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _FormAppBar(saving: _saving, onPublish: _onPublish),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          children: [
            _CoverCard(controller: _imageUrlController),
            const SizedBox(height: 14),
            _ContentCard(
              titleController: _titleController,
              resumenController: _resumenController,
              contenidoController: _contenidoController,
              charCount: _contenidoChars,
              maxChars: _maxContenido,
            ),
            const SizedBox(height: 14),
            _MetadataCard(
              authorName: user?.nombre ?? 'Admin',
              selectedCountry: isAdminPais ? null : _selectedCountry,
              showCountryPicker: !isAdminPais,
              fixedCountry: user?.paisAsignado?.nombre,
              onCountryChanged: (p) => setState(() => _selectedCountry = p),
            ),
            const SizedBox(height: 14),
            _StatusCard(
              selectedIndex: _selectedStatus,
              onSelected: (i) => setState(() => _selectedStatus = i),
              saving: _saving,
              onSaveDraft: () {
                setState(() => _selectedStatus = 0);
                _onPublish();
              },
              onPublish: () {
                setState(() => _selectedStatus = 1);
                _onPublish();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 2),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool saving;
  final VoidCallback onPublish;
  const _FormAppBar({required this.saving, required this.onPublish});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Nueva noticia',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: saving ? null : onPublish,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Publicar',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cover Card ───────────────────────────────────────────────────────────────

class _CoverCard extends StatelessWidget {
  final TextEditingController controller;
  const _CoverCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.metricDraftBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    color: AppColors.primaryPurple, size: 40),
                SizedBox(height: 8),
                Text('Imagen de portada (opcional)',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Formatos recomendados: JPG, PNG (16:9)',
                    style:
                        TextStyle(color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'URL de la imagen',
            hint: 'https://ejemplo.com/imagen.jpg',
            prefixIcon: Icons.link_rounded,
            controller: controller,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}

// ─── Content Card ─────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController resumenController;
  final TextEditingController contenidoController;
  final int charCount;
  final int maxChars;

  const _ContentCard({
    required this.titleController,
    required this.resumenController,
    required this.contenidoController,
    required this.charCount,
    required this.maxChars,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Título',
            hint: 'Escribe un titular impactante...',
            controller: titleController,
            fontSize: 17,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'Resumen',
            hint: 'Breve descripción para el listado de noticias...',
            controller: resumenController,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'Contenido completo',
            hint: 'Desarrolla la noticia aquí...',
            controller: contenidoController,
            maxLines: 6,
            suffix: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charCount / $maxChars',
                style: TextStyle(
                  color: charCount > maxChars
                      ? AppColors.errorColor
                      : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metadata Card ────────────────────────────────────────────────────────────

class _MetadataCard extends StatelessWidget {
  final String authorName;
  final PaisModel? selectedCountry;
  final bool showCountryPicker;
  final String? fixedCountry;
  final ValueChanged<PaisModel?> onCountryChanged;

  const _MetadataCard({
    required this.authorName,
    required this.selectedCountry,
    required this.showCountryPicker,
    required this.fixedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Autor',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.formBackground,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    color: AppColors.textHint, size: 18),
                const SizedBox(width: 10),
                Text(authorName,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('País',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (showCountryPicker)
            AppCountryDropdown(
              value: selectedCountry,
              onChanged: onCountryChanged,
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.formBackground,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      color: AppColors.textHint, size: 18),
                  const SizedBox(width: 10),
                  Text(fixedCountry ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Status Card ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool saving;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  const _StatusCard({
    required this.selectedIndex,
    required this.onSelected,
    required this.saving,
    required this.onSaveDraft,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de la publicación',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AppSegmentedSelector(
            options: const ['Borrador', 'Publicado'],
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: saving ? null : onSaveDraft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder, width: 1.5),
              ),
              child: const Text(
                'Guardar borrador',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: saving ? null : onPublish,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Publicar noticia',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
