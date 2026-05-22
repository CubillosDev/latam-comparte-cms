import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    setState(() => _checking = false);
    if (auth.isAuthenticated) {
      final route = auth.user!.isSuperAdmin ? '/dashboard' : '/dashboard/pais';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'v1.0',
                      style: TextStyle(
                        color: AppColors.whiteTransparent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.public,
                    size: 48,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Latinoamérica Comparte',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Panel Administrativo',
                  style: TextStyle(
                    color: AppColors.whiteTransparent,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (_checking)
                  const CircularProgressIndicator(color: AppColors.white)
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Iniciar sesión →'),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Solo para administradores de la plataforma',
                  style: TextStyle(
                    color: AppColors.whiteTransparent,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
