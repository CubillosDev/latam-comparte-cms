import 'package:app/models/user_model.dart';

class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final PaisBasico? paisAsignado;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.paisAsignado,
  });

  String get rolLabel => switch (rol) {
        'superadmin' => 'Super Admin',
        'admin_pais' => 'Admin País',
        'editor' => 'Editor',
        _ => rol,
      };

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        rol: json['rol'] as String,
        paisAsignado:
            json['pais_asignado'] != null && json['pais_asignado'] is Map
                ? PaisBasico.fromJson(
                    json['pais_asignado'] as Map<String, dynamic>)
                : null,
      );
}
