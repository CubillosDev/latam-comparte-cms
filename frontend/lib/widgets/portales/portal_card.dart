import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:flutter/material.dart';

class PortalCard extends StatelessWidget {
  final DashboardMetricaPais portal;
  final VoidCallback? onVerContenido;

  const PortalCard({
    super.key,
    required this.portal,
    this.onVerContenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PortalHeader(portal: portal),
            const SizedBox(height: 16),
            _PortalStats(portal: portal),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _VerContenidoButton(onTap: onVerContenido),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalHeader extends StatelessWidget {
  final DashboardMetricaPais portal;
  const _PortalHeader({required this.portal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.formBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              portal.pais.logoAsset,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => Center(
                child: Text(
                  portal.pais.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    portal.pais.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.metricDraftBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      portal.pais.codigo,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: portal.pais.activo
                          ? AppColors.statusPublishedText
                          : AppColors.textHint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    portal.pais.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: portal.pais.activo
                          ? AppColors.statusPublishedText
                          : AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortalStats extends StatelessWidget {
  final DashboardMetricaPais portal;
  const _PortalStats({required this.portal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
              value: '${portal.noticiasActivas}',
              label: 'NOTICIAS',
              color: AppColors.metricDraftText),
          Container(width: 1, height: 28, color: AppColors.inputBorder),
          _StatItem(
              value: '${portal.testimoniosPublicados}',
              label: 'TESTIMONIOS',
              color: AppColors.statusPublishedText),
          Container(width: 1, height: 28, color: AppColors.inputBorder),
          _StatItem(
              value: '${portal.solicitudesPendientes}',
              label: 'SOLICITUDES',
              color: AppColors.metricPendingText),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerContenidoButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _VerContenidoButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ver contenido',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded,
                color: AppColors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
