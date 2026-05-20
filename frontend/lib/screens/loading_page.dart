import 'package:app/core/app/app_colors.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  bool _checking = true;
  late final AnimationController _ctrl;

  // Fase 1 — 3 blobs entran desde 3 direcciones distintas
  late final Animation<Offset> _blobRight;
  late final Animation<Offset> _blobLeft;
  late final Animation<Offset> _blobTop;
  late final Animation<double> _blobsFade;

  // Fase 2 — título sube antes que el logo
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _subtitleOpacity;

  // Fase 3 — glow se expande y luego el logo explota con elasticOut
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Final — botón y disclaimer
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ── Fase 1: blobs ────────────────────────────────────────────────────
    _blobRight = Tween<Offset>(
      begin: const Offset(2.2, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.48, curve: Curves.easeOutCubic),
    ));

    _blobLeft = Tween<Offset>(
      begin: const Offset(-2.2, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.04, 0.52, curve: Curves.easeOutCubic),
    ));

    _blobTop = Tween<Offset>(
      begin: const Offset(0.0, -2.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.54, curve: Curves.easeOutCubic),
    ));

    _blobsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.12, 0.50, curve: Curves.easeIn),
      ),
    );

    // ── Fase 2: título ───────────────────────────────────────────────────
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.34, 0.60, curve: Curves.easeOutCubic),
    ));

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.34, 0.58, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.46, 0.64, curve: Curves.easeOut),
      ),
    );

    // ── Fase 3: glow + logo ──────────────────────────────────────────────
    _glowScale = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.54, 0.76, curve: Curves.easeOutCubic),
      ),
    );

    _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.54, 0.72, curve: Curves.easeOut),
      ),
    );

    // Logo aparece AL FINAL con rebote elástico — la gran llegada
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.64, 1.0, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.64, 0.82, curve: Curves.easeOut),
      ),
    );

    // ── Final: botón ─────────────────────────────────────────────────────
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.84, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFF5C1E9A),
      body: Stack(
        children: [
          // ── Fondo degradado morado ───────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B5FD4), Color(0xFF4A1580)],
                ),
              ),
            ),
          ),

          // ── Blob derecha — entra diagonal desde arriba-derecha ───────────
          Positioned(
            top: -110,
            right: -65,
            child: SlideTransition(
              position: _blobRight,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ── Blob izquierda — entra diagonal desde abajo-izquierda ────────
          Positioned(
            bottom: -100,
            left: -70,
            child: SlideTransition(
              position: _blobLeft,
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ── Blob superior — entra desde arriba (centro) ──────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: SlideTransition(
                position: _blobTop,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // ── Blobs secundarios — fade in ──────────────────────────────────
          Positioned(
            top: 210,
            left: -50,
            child: FadeTransition(
              opacity: _blobsFade,
              child: Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.065),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 400,
            right: -35,
            child: FadeTransition(
              opacity: _blobsFade,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 55,
            child: FadeTransition(
              opacity: _blobsFade,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 55,
            child: FadeTransition(
              opacity: _blobsFade,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ── Contenido principal ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Versión
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: FadeTransition(
                        opacity: _buttonOpacity,
                        child: Text(
                          'v1.0',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Fase 2: título aparece ANTES que el logo ─────────────
                  ClipRect(
                    child: SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: const Text(
                          'Latinoamérica\nComparte',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: Text(
                      'Panel Administrativo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // ── Fase 3: glow abre → logo explota ────────────────────
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow radial — anticipación
                      ScaleTransition(
                        scale: _glowScale,
                        child: FadeTransition(
                          opacity: _glowOpacity,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Logo — gran finale con elasticOut
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 152,
                            height: 152,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(38),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A1580)
                                      .withValues(alpha: 0.55),
                                  blurRadius: 48,
                                  offset: const Offset(0, 18),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(38),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/logos/latam.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, e, st) => const Icon(
                                    Icons.public_rounded,
                                    size: 62,
                                    color: Color(0xFF7C3AC7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Botón / indicador
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: _checking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                            child: const Text('Iniciar sesión →'),
                          ),
                  ),

                  const SizedBox(height: 14),

                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: Text(
                      'Solo para administradores de la plataforma',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
