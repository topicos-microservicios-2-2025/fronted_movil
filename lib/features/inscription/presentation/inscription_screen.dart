import 'package:flutter/material.dart';
import '../data/repositories/inscription_repository.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({Key? key}) : super(key: key);

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final TextEditingController registroController = TextEditingController();
  bool isLoading = false;
  final InscriptionRepository repo = InscriptionRepository();

  Map<String, dynamic>? estudianteData;
  List<dynamic> maestroOferta = [];
  List<dynamic> materiasVencidasLista = [];

  bool isInscribing = false;
  String errorMessage = '';
  Map<String, dynamic>? inscripcionResult;

  Set<int> materiasOfertaSeleccionadas = {};
  Map<int, int> gruposOfertaSeleccionados = {};

  int? estudianteId;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    widgets.add(
      TextField(
        controller: registroController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Registro de estudiante',
          border: OutlineInputBorder(),
        ),
      ),
    );

    widgets.add(const SizedBox(height: 12));

    widgets.add(
      ElevatedButton.icon(
        icon: const Icon(Icons.search),
        label: const Text('Buscar estudiante y oferta'),
        onPressed: isLoading
            ? null
            : () async {
                final registro = int.tryParse(registroController.text);
                if (registro == null) {
                  setState(() {
                    errorMessage = 'Ingrese un registro válido.';
                  });
                  return;
                }

                setState(() {
                  isLoading = true;
                  errorMessage = '';
                  estudianteData = null;
                  maestroOferta = [];
                  materiasVencidasLista = [];
                  inscripcionResult = null;
                  materiasOfertaSeleccionadas.clear();
                  gruposOfertaSeleccionados.clear();
                  estudianteId = null;
                });

                try {
                  final job = await repo.getEstudianteWithOferta(
                    registro: registro,
                    callbackUrl: 'http://192.168.0.14:5000/callback',
                  );
                  final returnValue = job['returnvalue'] as Map<String, dynamic>?;

                  final estudianteWrapper = returnValue?['estudiante'];
                  final estudiante = estudianteWrapper?['estudiante'];
                  if (estudiante == null) {
                    throw Exception('No hay datos de estudiante en respuesta.');
                  }

                  final id = estudiante['id'];
                  if (id == null) {
                    throw Exception('El estudiante no tiene id');
                  }

                  setState(() {
                    estudianteData = estudiante;
                    maestroOferta = estudianteWrapper['maestroOferta'] ?? [];
                    materiasVencidasLista = estudianteWrapper['materiasVencidasLista'] ?? [];
                    estudianteId = id is int ? id : int.tryParse(id.toString());
                  });
                } catch (e) {
                  setState(() {
                    errorMessage = 'Error al buscar: $e';
                  });
                }

                setState(() {
                  isLoading = false;
                });
              },
      ),
    );

    if (isLoading) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (estudianteData != null) {
      widgets.add(const SizedBox(height: 24));
      widgets.add(
        Card(
          color: Colors.indigo[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 ${estudianteData?['nombre']} ${estudianteData?['apellidoPaterno']} ${estudianteData?['apellidoMaterno']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Registro: ${estudianteData?['registro']}'),
              ],
            ),
          ),
        ),
      );

      widgets.add(const SizedBox(height: 24));
      widgets.add(
        const Text(
          '📚 Oferta académica disponible:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );

      if (maestroOferta.isEmpty) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No hay oferta académica disponible.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      } else {
        for (var materia in maestroOferta) {
          final materiaId = materia['id'] as int;
          final grupos = materia['Grupo_Materia'] as List<dynamic>? ?? [];

          widgets.add(
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: materiasOfertaSeleccionadas.contains(materiaId),
                          onChanged: grupos.isEmpty
                              ? null
                              : (val) {
                                  setState(() {
                                    if (val == true) {
                                      materiasOfertaSeleccionadas.add(materiaId);
                                      if (!gruposOfertaSeleccionados.containsKey(materiaId) && grupos.isNotEmpty) {
                                        gruposOfertaSeleccionados[materiaId] = grupos[0]['id'] as int;
                                      }
                                    } else {
                                      materiasOfertaSeleccionadas.remove(materiaId);
                                      gruposOfertaSeleccionados.remove(materiaId);
                                    }
                                  });
                                },
                        ),
                        Expanded(
                          child: Text(
                            '${materia['nombre']} (${materia['sigla'] ?? ''})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Nivel: ${materia['nivel']}', style: TextStyle(color: Colors.grey[700])),

                    if (grupos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Grupos disponibles:', style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var grupo in grupos) ...[
                        RadioListTile<int>(
                          value: grupo['id'] as int,
                          groupValue: gruposOfertaSeleccionados[materiaId],
                          onChanged: materiasOfertaSeleccionadas.contains(materiaId)
                              ? (val) {
                                  setState(() {
                                    gruposOfertaSeleccionados[materiaId] = val!;
                                  });
                                }
                              : null,
                          title: Text('Grupo ${grupo['sigla']} - Cupo: ${grupo['cupo'] ?? '-'}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '👨‍🏫 Docente: ${grupo['Docente']?['nombre']} '
                                '${grupo['Docente']?['apellidoPaterno']} '
                                '${grupo['Docente']?['apellidoMaterno']}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                              if ((grupo['AulaHorarios'] as List<dynamic>? ?? []).isEmpty)
                                const Text('Sin horarios asignados', style: TextStyle(color: Colors.red)),
                              for (var h in (grupo['AulaHorarios'] as List<dynamic>? ?? []))
                                Text(
                                  '🕐 ${h['Horario']?['dia']} ${h['Horario']?['inicio']}-${h['Horario']?['final']} - Aula ${h['Aula']?['numero']} (${h['Aula']?['Modulo']?['nombre']})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ] else
                      const Text('Sin grupos disponibles', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          );
        }

        if (materiasOfertaSeleccionadas.isNotEmpty) {
          widgets.add(const SizedBox(height: 16));
          widgets.add(
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Inscribir materias', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: isInscribing
                    ? null
                    : () async {
                        setState(() {
                          isInscribing = true;
                          errorMessage = '';
                        });

                        final List<int> grupoMateriasIds = [];
                        for (final materiaId in materiasOfertaSeleccionadas) {
                          final grupoId = gruposOfertaSeleccionados[materiaId];
                          if (grupoId == null) {
                            setState(() {
                              errorMessage = 'Selecciona un grupo para la materia con id $materiaId.';
                              isInscribing = false;
                            });
                            return;
                          }
                          grupoMateriasIds.add(grupoId);
                        }

                        if (estudianteId == null) {
                          setState(() {
                            errorMessage = 'No se pudo obtener el ID del estudiante.';
                            isInscribing = false;
                          });
                          return;
                        }

                        try {
                          final job = await repo.createInscripcionMaterias(
                            estudianteId: estudianteId!,
                            grupoMateriasIds: grupoMateriasIds,
                            callbackUrl: 'http://192.168.0.14:5000/callback',
                          );
                          final returnValue = job['returnvalue'] as Map<String, dynamic>?;

                          setState(() {
                            inscripcionResult = returnValue;
                            materiasOfertaSeleccionadas.clear();
                            gruposOfertaSeleccionados.clear();
                          });
                        } catch (e) {
                          setState(() {
                            errorMessage = 'Error al inscribir: $e';
                          });
                        }

                        setState(() {
                          isInscribing = false;
                        });
                      },
              ),
            ),
          );
        }
      }

      if (inscripcionResult != null) {
        widgets.add(const SizedBox(height: 16));
        final success = inscripcionResult?['success'] == true;
        widgets.add(
          Text(
            success ? '✅ Inscripción exitosa' : '❌ Inscripción fallida',
            style: TextStyle(
              color: success ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscripción', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widgets,
        ),
      ),
    );
  }
}
