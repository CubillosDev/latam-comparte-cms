import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      drawer: const AppDrawer(),
      appBar: _ConfigAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: const [
          _NombreSection(),
          SizedBox(height: 20),
          _PasswordSection(),
        ],
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 3),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _ConfigAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.inputBorder, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: AppColors.primary, size: 24),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const Expanded(
              child: Text(
                'Configuración',
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

// ─── Nombre Section ───────────────────────────────────────────────────────────

class _NombreSection extends StatefulWidget {
  const _NombreSection();

  @override
  State<_NombreSection> createState() => _NombreSectionState();
}

class _NombreSectionState extends State<_NombreSection> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: context.read<AuthProvider>().user?.nombre ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nombre = _ctrl.text.trim();
    if (nombre.isEmpty) return;

    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().actualizarPerfil(nombre);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Nombre actualizado' : 'Error al actualizar el nombre'),
      backgroundColor: ok ? AppColors.statusPublishedText : AppColors.errorColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Datos personales',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Nombre',
            hint: 'Tu nombre completo',
            prefixIcon: Icons.badge_outlined,
            controller: _ctrl,
          ),
          const SizedBox(height: 16),
          _SaveButton(
            label: 'Guardar nombre',
            saving: _saving,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

// ─── Password Section ─────────────────────────────────────────────────────────

class _PasswordSection extends StatefulWidget {
  const _PasswordSection();

  @override
  State<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<_PasswordSection> {
  final _actualCtrl = TextEditingController();
  final _nuevoCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _obscureActual = true;
  bool _obscureNuevo = true;
  bool _obscureConfirmar = true;
  bool _saving = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevoCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final actual = _actualCtrl.text;
    final nuevo = _nuevoCtrl.text;
    final confirmar = _confirmarCtrl.text;

    if (actual.isEmpty || nuevo.isEmpty || confirmar.isEmpty) {
      _snack('Completa todos los campos', error: true);
      return;
    }
    if (nuevo.length < 6) {
      _snack('La nueva contraseña debe tener al menos 6 caracteres',
          error: true);
      return;
    }
    if (nuevo != confirmar) {
      _snack('Las contraseñas no coinciden', error: true);
      return;
    }

    setState(() => _saving = true);
    final ok =
        await context.read<AuthProvider>().cambiarPassword(actual, nuevo);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      _actualCtrl.clear();
      _nuevoCtrl.clear();
      _confirmarCtrl.clear();
      _snack('Contraseña actualizada correctamente');
    } else {
      _snack('Contraseña actual incorrecta o error del servidor', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? AppColors.errorColor : AppColors.statusPublishedText,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Seguridad',
      icon: Icons.lock_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ObscureField(
            label: 'Contraseña actual',
            hint: 'Tu contraseña actual',
            controller: _actualCtrl,
            obscure: _obscureActual,
            onToggle: () => setState(() => _obscureActual = !_obscureActual),
          ),
          const SizedBox(height: 12),
          _ObscureField(
            label: 'Nueva contraseña',
            hint: 'Mínimo 6 caracteres',
            controller: _nuevoCtrl,
            obscure: _obscureNuevo,
            onToggle: () => setState(() => _obscureNuevo = !_obscureNuevo),
          ),
          const SizedBox(height: 12),
          _ObscureField(
            label: 'Confirmar nueva contraseña',
            hint: 'Repite la nueva contraseña',
            controller: _confirmarCtrl,
            obscure: _obscureConfirmar,
            onToggle: () =>
                setState(() => _obscureConfirmar = !_obscureConfirmar),
          ),
          const SizedBox(height: 16),
          _SaveButton(
            label: 'Cambiar contraseña',
            saving: _saving,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

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
              offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ObscureField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _ObscureField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.formBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool saving;
  final VoidCallback onTap;
  const _SaveButton(
      {required this.label, required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  )),
        ),
      ),
    );
  }
}
