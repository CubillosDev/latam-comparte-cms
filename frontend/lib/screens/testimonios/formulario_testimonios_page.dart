import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/widgets/buttons/app_primary_button.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/forms/app_country_dropdown.dart';
import 'package:app/widgets/forms/app_form_card.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:app/widgets/forms/app_segmented_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormularioTestimoniosPage extends StatefulWidget {
  const FormularioTestimoniosPage({super.key});

  @override
  State<FormularioTestimoniosPage> createState() =>
      _FormularioTestimoniosPageState();
}

class _FormularioTestimoniosPageState
    extends State<FormularioTestimoniosPage> {
  final _imageUrlController = TextEditingController();
  final _nameController = TextEditingController();
  final _testimonioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();

  PaisModel? _selectedCountry;
  int _selectedStatus = 0;
  bool _isSocialExpanded = true;
  int _charCount = 0;
  bool _saving = false;

  static const int _maxChars = 500;
  static const _statusLabels = ['Borrador', 'Publicado', 'Despublicado'];

  @override
  void initState() {
    super.initState();
    _testimonioController.addListener(
        () => setState(() => _charCount = _testimonioController.text.length));
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _nameController.dispose();
    _testimonioController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final nombre = _nameController.text.trim();
    final testimonio = _testimonioController.text.trim();

    if (nombre.isEmpty || testimonio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre y testimonio'),
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
    final ok = await context.read<TestimoniosProvider>().crear({
      'nombre': nombre,
      'testimonio': testimonio,
      'pais': paisId,
      'estado': ['borrador', 'publicado', 'despublicado'][_selectedStatus],
      if (_imageUrlController.text.isNotEmpty)
        'foto_url': _imageUrlController.text.trim(),
      if (_instagramController.text.isNotEmpty)
        'instagram': _instagramController.text.trim(),
      if (_facebookController.text.isNotEmpty)
        'facebook': _facebookController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el testimonio'),
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
      appBar: _FormAppBar(saving: _saving, onSave: _onSave),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          children: [
            _PhotoCard(controller: _imageUrlController),
            const SizedBox(height: 14),
            AppFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Testigo',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'Nombre completo',
                    hint: 'Ej. María García',
                    prefixIcon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  const Text('País',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  if (!isAdminPais)
                    AppCountryDropdown(
                      value: _selectedCountry,
                      onChanged: (p) => setState(() => _selectedCountry = p),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.formBackground,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined,
                              color: AppColors.textHint, size: 18),
                          const SizedBox(width: 10),
                          Text(user?.paisAsignado?.nombre ?? '',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  AppFormField(
                    label: 'Testimonio',
                    hint: 'Cuéntanos tu experiencia...',
                    controller: _testimonioController,
                    maxLines: 4,
                    suffix: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$_charCount / $_maxChars',
                        style: TextStyle(
                          color: _charCount > _maxChars
                              ? AppColors.errorColor
                              : AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SocialCard(
              expanded: _isSocialExpanded,
              onToggle: () =>
                  setState(() => _isSocialExpanded = !_isSocialExpanded),
              instagramController: _instagramController,
              facebookController: _facebookController,
            ),
            const SizedBox(height: 14),
            AppFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado de publicación',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSegmentedSelector(
                    options: _statusLabels,
                    selectedIndex: _selectedStatus,
                    onSelected: (i) => setState(() => _selectedStatus = i),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: _saving ? 'Guardando...' : 'Guardar testimonio',
              onPressed: _saving ? null : _onSave,
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
  final VoidCallback onSave;
  const _FormAppBar({required this.saving, required this.onSave});

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
                  'Nuevo testimonio',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: saving ? null : onSave,
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
                        'Guardar',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
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

// ─── Photo Card ───────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final TextEditingController controller;
  const _PhotoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppFormCard(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPurple,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    color: AppColors.primaryPurple, size: 28),
                SizedBox(height: 4),
                Text(
                  'Toca para\nagregar foto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'URL de la imagen',
            hint: 'https://ejemplo.com/foto.jpg',
            prefixIcon: Icons.link_rounded,
            controller: controller,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}

// ─── Social Card ──────────────────────────────────────────────────────────────

class _SocialCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController instagramController;
  final TextEditingController facebookController;

  const _SocialCard({
    required this.expanded,
    required this.onToggle,
    required this.instagramController,
    required this.facebookController,
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
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.share_outlined,
                      color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Redes Sociales',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  AppFormField(
                    hint: 'Instagram Username',
                    prefixIcon: Icons.alternate_email_rounded,
                    controller: instagramController,
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    hint: 'Facebook Profile URL',
                    prefixIcon: Icons.people_outline_rounded,
                    controller: facebookController,
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity, height: 0),
            crossFadeState:
                expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
