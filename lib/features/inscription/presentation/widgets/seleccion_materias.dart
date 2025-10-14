import 'package:flutter/material.dart';

class SeleccionMaterias extends StatelessWidget {
  final List<dynamic> materiasDisponibles;
  final Map<int, int?> selectedGrupos;  // Permitir null para grupo no seleccionado
  final Set<int> materiasSeleccionadas;
  final Function(int materiaId, bool selected) onMateriaSelect;
  final Function(int materiaId, int grupoId) onGrupoSelect;

  const SeleccionMaterias({
    required this.materiasDisponibles,
    required this.selectedGrupos,
    required this.materiasSeleccionadas,
    required this.onMateriaSelect,
    required this.onGrupoSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materias disponibles para inscribir:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...materiasDisponibles.map((materia) {
          final grupos = materia['grupos'] ?? [];
          final materiaId = materia['id'] as int;

          // Para depurar:
          // print('MateriaId: $materiaId, Grupo seleccionado: ${selectedGrupos[materiaId]}');

          return Card(
            color: Colors.blue[50],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: materiasSeleccionadas.contains(materiaId),
                        onChanged: (val) => onMateriaSelect(materiaId, val ?? false),
                      ),
                      Text(
                        '${materia['nombre']} (${materia['sigla']})',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  Text('Nivel: ${materia['nivel']}'),
                  if (grupos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Grupos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...grupos.map<Widget>((grupo) {
                      final grupoId = grupo['id'] as int;
                      final docente = grupo['docente'];
                      final horarios = grupo['horarios'] ?? [];

                      return RadioListTile<int>(
                        value: grupoId,
                        groupValue: selectedGrupos[materiaId],
                        onChanged: (val) {
                          if (val != null) {
                            onGrupoSelect(materiaId, val);
                          }
                        },
                        title:
                            Text('Grupo ${grupo['sigla']} - Cupo: ${grupo['cupo'] ?? '-'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Docente: ${docente?['nombre'] ?? '-'} ${docente?['apellidoPaterno'] ?? ''}'),
                            ...horarios.map<Widget>((h) {
                              return Text(
                                  'Horario: ${h['dia'] ?? '-'} ${h['horaInicio'] ?? '-'}-${h['horaFin'] ?? '-'} Aula: ${h['aula'] ?? '-'}');
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
