class EstudianteModel {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String ci;
  final int registro;
  final String carrera;
  final String planEstudios;
  final String estado;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.ci,
    required this.registro,
    required this.carrera,
    required this.planEstudios,
    required this.estado,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'] ?? '',
      ci: json['ci'] ?? '',
      registro: json['registro'] ?? 0,
      carrera: json['carrera'] ?? '',
      planEstudios: json['planEstudios'] ?? '',
      estado: json['estado'] ?? '',
    );
  }

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}