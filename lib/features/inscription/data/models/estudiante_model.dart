class Estudiante {
  final int id;
  final String nombre;
  final String apellido;
  final List<Materia> maestroOferta;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.maestroOferta,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      maestroOferta: (json['maestroOferta'] as List)
          .map((e) => Materia.fromJson(e))
          .toList(),
    );
  }
}

class Materia {
  final int id;
  final String nombre;
  final String sigla;
  final List<GrupoMateria> grupoMateria;

  Materia({
    required this.id,
    required this.nombre,
    required this.sigla,
    required this.grupoMateria,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nombre: json['nombre'],
      sigla: json['sigla'],
      grupoMateria: (json['Grupo_Materia'] as List)
          .map((e) => GrupoMateria.fromJson(e))
          .toList(),
    );
  }
}

class GrupoMateria {
  final int id;
  final String sigla;
  final Docente docente;

  GrupoMateria({
    required this.id,
    required this.sigla,
    required this.docente,
  });

  factory GrupoMateria.fromJson(Map<String, dynamic> json) {
    return GrupoMateria(
      id: json['id'],
      sigla: json['sigla'],
      docente: Docente.fromJson(json['Docente']),
    );
  }
}

class Docente {
  final int id;
  final String nombre;
  final String apellidoPaterno;

  Docente({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
  });

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      id: json['id'],
      nombre: json['nombre'],
      apellidoPaterno: json['apellidoPaterno'],
    );
  }
}
