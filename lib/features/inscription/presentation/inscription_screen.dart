import 'package:flutter/material.dart';
import '../data/fake/fake_json.dart';
import '../data/repositories/inscription_repository.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({Key? key}) : super(key: key);

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  int? selectedEstudianteId;
  List<Map<String, dynamic>> estudiantes = [];
  List<dynamic> materias = [];
  Map<int, bool> selectedMaterias = {};
  bool isLoading = false;
  String resultMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEstudiantes();
  }

  void _loadEstudiantes() {
    final estudianteObj = fakeJson['result']['estudiante'];
    final estudiante = estudianteObj['estudiante'];
    estudiantes = [
      {
        'id': estudiante['id'],
        'nombre': estudiante['nombre'],
        'apellidoPaterno': estudiante['apellidoPaterno'],
        'apellidoMaterno': estudiante['apellidoMaterno'],
        'ci': estudiante['ci'],
        'registro': estudiante['registro'],
        'fechaNacimiento': estudiante['fechaNacimiento'],
        'nacionalidad': estudiante['nacionalidad'],
      }
    ];
    selectedEstudianteId = estudiantes.first['id'];
    _loadMaterias(selectedEstudianteId!);
  }

  void _loadMaterias(int estudianteId) {
    final estudianteObj = fakeJson['result']['estudiante'];
    materias = estudianteObj['materiasVencidasLista'];
    selectedMaterias = {
      for (var m in materias) m['id'] as int: false,
    };
    setState(() {});
  }

  Future<void> _inscribirMaterias() async {
    setState(() { isLoading = true; resultMessage = ''; });
    final grupoMateriasIds = selectedMaterias.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedEstudianteId == null || grupoMateriasIds.isEmpty) {
      setState(() {
        isLoading = false;
        resultMessage = 'Selecciona al menos una materia.';
      });
      return;
    }
    try {
      final repo = InscriptionRepository();
      print('Enviando inscripción...');
      final response = await repo.createInscripcionMaterias(
        estudianteId: selectedEstudianteId!,
        grupoMateriasIds: grupoMateriasIds,
        callbackUrl: 'http://192.168.0.16:5000/callback',
      );
      print('Respuesta inscripción: $response');
      setState(() {
        isLoading = false;
        resultMessage = (response['success'] == true || response['message'] == 'Inscripción realizada' || response['message'] == 'Tarea aceptada')
            ? 'Inscripción exitosa.'
            : 'Error en la inscripción.';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        resultMessage = 'Error: $e';
      });
      print('Error inscripción: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscripción de Materias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona Estudiante:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: selectedEstudianteId,
              isExpanded: true,
              items: estudiantes.map((est) {
                return DropdownMenuItem<int>(
                  value: est['id'],
                  child: Text('${est['nombre']} ${est['apellidoPaterno']} ${est['apellidoMaterno']} (ID: ${est['id']})'),
                );
              }).toList(),
              onChanged: (id) {
                setState(() {
                  selectedEstudianteId = id;
                  _loadMaterias(id!);
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Materias para inscribir:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: materias.map((materia) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        '${materia['nombre']} (${materia['sigla']})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Nivel: ${materia['nivel']}', style: const TextStyle(color: Colors.grey)),
                      trailing: Checkbox(
                        value: selectedMaterias[materia['id']] ?? false,
                        onChanged: (val) {
                          setState(() {
                            selectedMaterias[materia['id']] = val ?? false;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (resultMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(resultMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
              ),
            const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: isLoading ? null : _inscribirMaterias,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.blueAccent, // Cambié 'primary' por 'backgroundColor'
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Inscribir'),
  ),
)

          ],
        ),
      ),
    );
  }
}
