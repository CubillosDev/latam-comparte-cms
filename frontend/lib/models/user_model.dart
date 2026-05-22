class LoginResponse {
  final bool ok;
  final String message;
  final String token;
  final User user;

  LoginResponse({required this.ok, required this.message, required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        ok: json['ok'] as bool,
        message: json['message'] as String,
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class User {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final PaisBasico? paisAsignado;

  User({required this.id, required this.nombre, required this.correo, required this.rol, this.paisAsignado});

  bool get isSuperAdmin => rol == 'superadmin';
  bool get isAdminPais => rol == 'admin_pais';
  bool get isEditor => rol == 'editor';
  bool get canDelete => rol == 'superadmin' || rol == 'admin_pais';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        rol: json['rol'] as String,
        paisAsignado: json['pais_asignado'] != null && json['pais_asignado'] is Map
            ? PaisBasico.fromJson(json['pais_asignado'] as Map<String, dynamic>)
            : null,
      );
}

class PaisBasico {
  final String id;
  final String nombre;
  final String codigo;

  PaisBasico({required this.id, required this.nombre, required this.codigo});

  factory PaisBasico.fromJson(Map<String, dynamic> json) => PaisBasico(
        id: json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        codigo: json['codigo'] as String,
      );
}
