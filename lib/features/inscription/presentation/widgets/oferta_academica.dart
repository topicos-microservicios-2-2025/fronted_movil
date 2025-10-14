import 'package:flutter/material.dart';

class OfertaAcademica extends StatelessWidget {
  final Map<String, dynamic> estudianteData;
  const OfertaAcademica({required this.estudianteData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estudiante: ${estudianteData['nombre']} ${estudianteData['apellidoPaterno']} ${estudianteData['apellidoMaterno']}', style: const TextStyle(fontSize: 16)),
        Text('CI: ${estudianteData['ci']}'),
        Text('Carrera: ${estudianteData['registro']}'),
        Text('Plan de estudios: ${estudianteData['fechaNacimiento']}'),
      ],
    );
  }
}
