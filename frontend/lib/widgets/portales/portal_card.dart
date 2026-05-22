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
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: portal.pais.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PortalHeader(portal: portal),
                    const SizedBox(height: 12),
                    _PortalStats(portal: portal),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _VerContenidoButton(onTap: onVerContenido),
                    ),
                  ],
                ),
              ),
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
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.metricDraftBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(portal.pais.flag, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: 12),
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.formBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      portal.pais.codigo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusPublishedText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${portal.pais.nombre.toLowerCase().replaceAll(' ', '')}comparte.org',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          _StatItem(value: '${portal.noticiasActivas}', label: 'NOTICIAS'),
          Container(width: 1, height: 32, color: AppColors.inputBorder),
          _StatItem(value: '${portal.testimoniosPublicados}', label: 'TESTIMONIOS'),
          Container(width: 1, height: 32, color: AppColors.inputBorder),
          _StatItem(value: '${portal.solicitudesPendientes}', label: 'SOLICITUDES'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryPurple),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Ver contenido',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
