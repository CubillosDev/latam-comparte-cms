import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF8FF), Color(0xFFF4F0FA)],
          ),
        ),
        child: Stack(
          children: [
            // Decoración sutil — círculo grande en esquina superior
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B5FD4).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B5FD4).withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Contenido
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BrandSection(),
                      const SizedBox(height: 36),
                      _FormCard(
                        correoController: _correoController,
                        passwordController: _passwordController,
                        isLoading: isLoading,
                        onLogin: _handleLogin,
                      ),
                      const SizedBox(height: 28),
                      _SecurityDisclaimer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Brand Section ────────────────────────────────────────────────────────────

class _BrandSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo box — blanco para máximo contraste con la imagen
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AC7).withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/logos/latam.png',
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) => const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF7C3AC7),
                  size: 42,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Latinoamérica Comparte',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Panel Administrativo · CMS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Form Card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final TextEditingController correoController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const _FormCard({
    required this.correoController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iniciar sesión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa tus credenciales para continuar',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'Correo electrónico',
            hint: 'admin@latamcomparte.org',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: correoController,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Contraseña',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: passwordController,
          ),
          const SizedBox(height: 28),
          AppPrimaryButton(
            label: isLoading ? 'Iniciando sesión...' : 'Continuar →',
            onPressed: isLoading ? null : onLogin,
          ),
        ],
      ),
    );
  }
}

// ─── Security Disclaimer ──────────────────────────────────────────────────────

class _SecurityDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.inputBorder)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.lock_outline_rounded,
                  color: AppColors.textHint, size: 13),
            ),
            Expanded(child: Container(height: 1, color: AppColors.inputBorder)),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Acceso restringido únicamente a personal\nautorizado de Latinoamérica Comparte.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
