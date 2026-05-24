import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:app/models/usuario_model.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:app/provider/usuarios_provider.dart';
import 'package:app/widgets/common/app_drawer.dart';
import 'package:app/widgets/dashboard/dashboard_bottom_nav.dart';
import 'package:app/widgets/forms/app_country_dropdown.dart';
import 'package:app/widgets/forms/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuariosProvider>().cargar();
      if (context.read<PaisesProvider>().paises.isEmpty) {
        context.read<PaisesProvider>().cargarPaises();
      }
    });
  }

  void _openForm({UsuarioModel? usuario}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _UserFormSheet(usuario: usuario),
    );
  }

  Future<void> _confirmDelete(UsuarioModel u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a "${u.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<UsuariosProvider>().eliminar(u.id);
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al eliminar el usuario'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuariosProvider>();

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      drawer: const AppDrawer(),
      appBar: _UsuariosAppBar(count: provider.usuarios.length),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: AppColors.white),
      ),
      body: switch (provider.state) {
        UsuariosLoadState.loading || UsuariosLoadState.idle => const Center(
            child:
                CircularProgressIndicator(color: AppColors.primaryPurple)),
        UsuariosLoadState.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.errorColor, size: 48),
                const SizedBox(height: 12),
                Text(provider.error ?? 'Error',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UsuariosProvider>().cargar(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        UsuariosLoadState.loaded => provider.usuarios.isEmpty
            ? const Center(
                child: Text('No hay usuarios registrados',
                    style: TextStyle(
                        color: AppColors.textHint, fontSize: 14)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: provider.usuarios.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _UsuarioCard(
                  usuario: provider.usuarios[i],
                  onEdit: () => _openForm(usuario: provider.usuarios[i]),
                  onDelete: () => _confirmDelete(provider.usuarios[i]),
                ),
              ),
      },
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 0),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _UsuariosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  const _UsuariosAppBar({required this.count});

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
                'Usuarios',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.metricDraftBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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

// ─── User Card ────────────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UsuarioCard({
    required this.usuario,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _rolColor => switch (usuario.rol) {
        'superadmin' => const Color(0xFF7C3AED),
        'admin_pais' => const Color(0xFF0369A1),
        _ => const Color(0xFF047857),
      };

  Color get _rolBg => switch (usuario.rol) {
        'superadmin' => const Color(0xFFEDE9FE),
        'admin_pais' => const Color(0xFFE0F2FE),
        _ => const Color(0xFFD1FAE5),
      };

  String get _initials {
    final parts = usuario.nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U';
  }

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
              offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: _rolBg,
          radius: 22,
          child: Text(_initials,
              style: TextStyle(
                  color: _rolColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ),
        title: Text(
          usuario.nombre,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(usuario.correo,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                _Badge(
                    label: usuario.rolLabel,
                    color: _rolColor,
                    bgColor: _rolBg),
                if (usuario.paisAsignado != null) ...[
                  const SizedBox(width: 6),
                  _Badge(
                    label: usuario.paisAsignado!.nombre,
                    color: AppColors.textSecondary,
                    bgColor: AppColors.metricDraftBg,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.errorColor, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  const _Badge(
      {required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── User Form Sheet ──────────────────────────────────────────────────────────

class _UserFormSheet extends StatefulWidget {
  final UsuarioModel? usuario;
  const _UserFormSheet({this.usuario});

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _rol = 'admin_pais';
  PaisModel? _pais;
  bool _obscure = true;
  bool _saving = false;

  bool get _isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final u = widget.usuario!;
      _nombreCtrl.text = u.nombre;
      _correoCtrl.text = u.correo;
      _rol = u.rol;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nombre = _nombreCtrl.text.trim();
    final correo = _correoCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (nombre.isEmpty || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nombre y correo son obligatorios'),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_isEditing && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La contraseña es obligatoria'),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_rol != 'superadmin' && _pais == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona un país para este rol'),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);

    final data = <String, dynamic>{
      'nombre': nombre,
      'correo': correo,
      'rol': _rol,
      if (_pais != null) 'pais_asignado': _pais!.id,
      if (_rol == 'superadmin') 'pais_asignado': null,
      if (!_isEditing) 'password': password,
    };

    final provider = context.read<UsuariosProvider>();
    final bool ok;
    if (_isEditing) {
      ok = await provider.actualizar(widget.usuario!.id, data);
    } else {
      ok = await provider.crear(data);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing
            ? 'Error al actualizar el usuario'
            : 'Error al crear el usuario'),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsPais = _rol == 'admin_pais' || _rol == 'editor';

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
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
          Text(
            _isEditing ? 'Editar usuario' : 'Nuevo usuario',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          AppFormField(
            label: 'Nombre completo',
            hint: 'Ej. Ana García',
            prefixIcon: Icons.person_outline_rounded,
            controller: _nombreCtrl,
          ),
          const SizedBox(height: 12),
          AppFormField(
            label: 'Correo electrónico',
            hint: 'correo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            controller: _correoCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 12),
            _PasswordField(
              controller: _passwordCtrl,
              obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
          ],
          const SizedBox(height: 12),
          _RolDropdown(
            value: _rol,
            onChanged: (v) => setState(() => _rol = v),
          ),
          if (needsPais) ...[
            const SizedBox(height: 12),
            AppCountryDropdown(
              value: _pais,
              onChanged: (p) => setState(() => _pais = p),
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5))
                    : Text(
                        _isEditing ? 'Guardar cambios' : 'Crear usuario',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textHint,
                  size: 20),
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

class _RolDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RolDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const roles = [
      ('superadmin', 'Super Administrador'),
      ('admin_pais', 'Admin País'),
      ('editor', 'Editor'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rol',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.formBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppColors.textHint, size: 20),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              onChanged: (v) => onChanged(v!),
              items: roles
                  .map((r) => DropdownMenuItem(
                        value: r.$1,
                        child: Text(r.$2),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
