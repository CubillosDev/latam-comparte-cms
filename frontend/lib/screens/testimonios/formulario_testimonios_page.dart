import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:app/models/testimonio_model.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/widgets/buttons/app_primary_button.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/forms/app_country_dropdown.dart';
import 'package:app/widgets/forms/app_form_card.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:app/widgets/forms/app_segmented_selector.dart';
import 'package:app/widgets/forms/image_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormularioTestimoniosPage extends StatefulWidget {
  final TestimonioModel? testimonio; // null = crear, non-null = editar
  const FormularioTestimoniosPage({super.key, this.testimonio});

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

  bool get _isEditing => widget.testimonio != null;

  @override
  void initState() {
    super.initState();
    _testimonioController.addListener(
        () => setState(() => _charCount = _testimonioController.text.length));
    if (_isEditing) {
      final t = widget.testimonio!;
      _imageUrlController.text = t.fotoUrl;
      _nameController.text = t.nombre;
      _testimonioController.text = t.testimonio;
      _instagramController.text = t.instagramUrl ?? '';
      _facebookController.text = t.facebookUrl ?? '';
      _selectedCountry = t.pais;
      _selectedStatus = switch (t.estado) {
        'publicado' => 1,
        'despublicado' => 2,
        _ => 0,
      };
    }
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
    final paisId = _selectedCountry?.id ?? widget.testimonio?.pais.id ?? user?.paisAsignado?.id ?? '';

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

    final data = {
      'nombre': nombre,
      'testimonio': testimonio,
      'pais': paisId,
      'estado': ['borrador', 'publicado', 'despublicado'][_selectedStatus],
      if (_imageUrlController.text.isNotEmpty)
        'foto_url': _imageUrlController.text.trim(),
      if (_instagramController.text.isNotEmpty)
        'instagram_url': _instagramController.text.trim(),
      if (_facebookController.text.isNotEmpty)
        'facebook_url': _facebookController.text.trim(),
    };

    final provider = context.read<TestimoniosProvider>();
    final bool ok;
    if (_isEditing) {
      ok = await provider.actualizar(widget.testimonio!.id, data);
    } else {
      ok = await provider.crear(data);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Error al actualizar el testimonio' : 'Error al guardar el testimonio'),
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
      appBar: _FormAppBar(
        saving: _saving,
        onSave: _onSave,
        title: _isEditing ? 'Editar testimonio' : 'Nuevo testimonio',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          children: [
            AppFormCard(
              child: ImagePickerField(
                controller: _imageUrlController,
                shape: ImagePickerShape.circle,
              ),
            ),
            const SizedBox(height: 14),
            AppFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Testigo',
                    style: TextStyle(
                      color: AppColors.primary,
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
                          Text(
                            user?.paisAsignado?.nombre ?? widget.testimonio?.pais.nombre ?? '',
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
                      color: AppColors.primary,
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
              label: _saving
                  ? 'Guardando...'
                  : (_isEditing ? 'Guardar cambios' : 'Guardar testimonio'),
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
  final String title;
  const _FormAppBar({required this.saving, required this.onSave, required this.title});

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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton(
              onPressed: saving ? null : onSave,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.metricDraftBg,
                foregroundColor: AppColors.primaryPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPurple, strokeWidth: 2),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
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
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Redes Sociales',
                      style: TextStyle(
                        color: AppColors.primary,
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
