import 'package:flutter/material.dart';

class ResumenInscripcion extends StatelessWidget {
  final Map<String, dynamic>? inscripcionResult;
  final bool isLoading;
  final String errorMessage;

  const ResumenInscripcion({
    required this.inscripcionResult,
    required this.isLoading,
    required this.errorMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      );
    }
    if (inscripcionResult == null) {
      return const SizedBox.shrink();
    }

    final success = inscripcionResult?['success'] == true;
    final materias = inscripcionResult?['materias'] as List<dynamic>? ?? [];

    return Card(
      color: success ? Colors.green[50] : Colors.red[50],
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              success ? '¡Inscripción exitosa!' : 'Error en la inscripción',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...materias.map<Widget>((m) {
              final nombre = m['nombre'] ?? '-';
              final sigla = m['sigla'] ?? '-';

              final grupo = m['grupo'] as Map<String, dynamic>? ?? {};
              final grupoSigla = grupo['sigla'] ?? '-';

              final docente = grupo['docente'] as Map<String, dynamic>? ?? {};
              final docenteNombre = docente['nombre'] ?? '-';

              return ListTile(
                title: Text('$nombre ($sigla)'),
                subtitle: Text('Grupo: $grupoSigla - Docente: $docenteNombre'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
