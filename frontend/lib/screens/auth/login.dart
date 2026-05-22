import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/auth/auth_header.dart';
import 'package:app/widgets/buttons/app_primary_button.dart';
import 'package:app/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      correo: _correoController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = auth.user!;
      final route = user.isSuperAdmin ? '/dashboard' : '/dashboard/pais';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (auth) => auth.status == AuthStatus.loading,
    );

    return Scaffold(
      backgroundColor: AppColors.formBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'Bienvenido',
              subtitle: 'Inicia sesión para continuar',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Correo electrónico',
                    hint: 'admin@latamcomparte.org',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _correoController,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    label: isLoading ? 'Iniciando sesión...' : 'Iniciar sesión →',
                    onPressed: isLoading ? null : _handleLogin,
                  ),
                  const SizedBox(height: 32),
                  const _SecurityDisclaimer(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityDisclaimer extends StatelessWidget {
  const _SecurityDisclaimer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Acceso restringido únicamente a personal autorizado de\nLatinoamérica Comparte.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            height: 1.6,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, color: AppColors.textHint, size: 14),
            SizedBox(width: 4),
            Text(
              'SECURE CONNECT',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
