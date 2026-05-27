import 'package:app/core/app/app_colors.dart';
import 'package:app/services/upload_service.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ImagePickerShape { circle, rectangle }

class ImagePickerField extends StatefulWidget {
  final TextEditingController controller;
  final ImagePickerShape shape;

  const ImagePickerField({
    super.key,
    required this.controller,
    this.shape = ImagePickerShape.rectangle,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final _urlFocus = FocusNode();
  bool _uploading = false;

  @override
  void dispose() {
    _urlFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext sheetCtx, ImageSource source) async {
    Navigator.pop(sheetCtx);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      if (mounted) setState(() => _uploading = true);
      final url = await UploadService().subirImagen(file);
      if (mounted) widget.controller.text = url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Agregar imagen',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _PickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Desde galería',
              onTap: () => _pickImage(sheetCtx, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Tomar foto',
              onTap: () => _pickImage(sheetCtx, ImageSource.camera),
            ),
            if (widget.controller.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PickerOption(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar imagen',
                iconColor: AppColors.errorColor,
                textColor: AppColors.errorColor,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  widget.controller.clear();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final url = value.text.trim();
        final hasUrl = url.isNotEmpty;

        return Column(
          children: [
            GestureDetector(
              onTap: _uploading ? null : _showPickerSheet,
              child: widget.shape == ImagePickerShape.circle
                  ? _CirclePreview(url: url, uploading: _uploading)
                  : _RectPreview(url: url, uploading: _uploading),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'URL de la imagen ${widget.shape == ImagePickerShape.rectangle ? "(opcional)" : ""}',
                    hint: 'https://ejemplo.com/imagen.jpg',
                    prefixIcon: Icons.link_rounded,
                    controller: widget.controller,
                    focusNode: _urlFocus,
                    keyboardType: TextInputType.url,
                  ),
                ),
                if (hasUrl) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.controller.clear(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.errorColor, size: 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─── Previews ─────────────────────────────────────────────────────────────────

class _CirclePreview extends StatelessWidget {
  final String url;
  final bool uploading;
  const _CirclePreview({required this.url, required this.uploading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.metricDraftBg,
            border: Border.all(
              color: url.isNotEmpty
                  ? AppColors.primaryPurple
                  : AppColors.inputBorder,
              width: 2,
            ),
          ),
          child: uploading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : url.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        url,
                        key: ValueKey(url),
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: AppColors.primaryPurple, strokeWidth: 2.5),
                                ),
                              ),
                        errorBuilder: (_, _, _) =>
                            const _Placeholder(icon: Icons.broken_image_outlined, label: 'Sin imagen', isError: true),
                      ),
                    )
                  : const _Placeholder(icon: Icons.add_a_photo_outlined, label: 'Agregar\nfoto'),
        ),
        if (!uploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded, color: AppColors.white, size: 12),
            ),
          ),
      ],
    );
  }
}

class _RectPreview extends StatelessWidget {
  final String url;
  final bool uploading;
  const _RectPreview({required this.url, required this.uploading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.metricDraftBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: url.isNotEmpty
              ? AppColors.primaryPurple.withValues(alpha: 0.4)
              : AppColors.inputBorder,
          width: 1.5,
        ),
      ),
      child: uploading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 10),
                  Text('Subiendo imagen...',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            )
          : url.isNotEmpty
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        key: ValueKey(url),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primaryPurple, strokeWidth: 2.5),
                              ),
                        errorBuilder: (_, _, _) => const _Placeholder(
                          icon: Icons.broken_image_outlined,
                          label: 'No se pudo cargar la imagen',
                          isError: true,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                )
              : const _Placeholder(
                  icon: Icons.add_photo_alternate_outlined,
                  label: 'Toca para agregar imagen',
                  sublabel: 'Desde galería, cámara o URL',
                ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final bool isError;

  const _Placeholder({
    required this.icon,
    required this.label,
    this.sublabel,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.errorColor : AppColors.primaryPurple;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError ? AppColors.errorColor : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 4),
          Text(
            sublabel!,
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primaryPurple,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.formBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
