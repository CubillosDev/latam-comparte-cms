import 'package:app/core/app/app_colors.dart';
import 'package:app/models/pais_model.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppCountryDropdown extends StatefulWidget {
  final PaisModel? value;
  final ValueChanged<PaisModel?> onChanged;
  final String hint;

  const AppCountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = 'Selecciona un país',
  });

  @override
  State<AppCountryDropdown> createState() => _AppCountryDropdownState();
}

class _AppCountryDropdownState extends State<AppCountryDropdown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PaisesProvider>();
      if (provider.paises.isEmpty) {
        provider.cargarPaises();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paises = context.watch<PaisesProvider>().paises;

    final matches = paises.where((p) => p.id == widget.value?.id);
    final resolvedValue = matches.isEmpty ? null : matches.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PaisModel>(
          value: resolvedValue,
          isExpanded: true,
          hint: Text(
            widget.hint,
            style: const TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
          items: paises.map((p) {
            return DropdownMenuItem<PaisModel>(
              value: p,
              child: Row(
                children: [
                  Text(p.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    p.nombre,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.textHint, size: 20),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
