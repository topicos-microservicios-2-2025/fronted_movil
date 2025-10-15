
import 'dart:convert';
import 'package:http/http.dart' as http;

class InscriptionRepository {
  final String baseUrl = 'http://192.168.0.14:3000/api';

  /// Paso 1: Buscar estudiante y oferta académica (con polling)
  Future<Map<String, dynamic>> getEstudianteWithOferta({required int registro, required String callbackUrl}) async {
    final url = Uri.parse('$baseUrl/inscripcion/tasks');
    final payload = {
      "task": "get_estudiante_with_maestro_oferta",
      "data": {"registro": registro},
      "callback": callbackUrl,
    };
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 202) {
      throw Exception('Error creando tarea: ${response.statusCode}');
    }
    final respJson = jsonDecode(response.body);
    final shortId = respJson['shortId']?.toString();
    if (shortId == null) throw Exception('No se recibió shortId');
    // Polling hasta que el job esté completed
    return await _pollJob(shortId);
  }

  /// Paso 2: Crear inscripción de materias (con polling)
  Future<Map<String, dynamic>> createInscripcionMaterias({
    required int estudianteId,
    required List<int> grupoMateriasIds,
    required String callbackUrl,
  }) async {
    final url = Uri.parse('$baseUrl/inscripcion/tasks');
    final payload = {
      "task": "create_inscripcion_materias",
      "data": {
        "estudianteId": estudianteId,
        "grupoMateriasIds": grupoMateriasIds,
      },
      "callback": callbackUrl,
    };
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 202) {
      throw Exception('Error creando inscripción: ${response.statusCode}');
    }
    final respJson = jsonDecode(response.body);
    final shortId = respJson['shortId']?.toString();
    if (shortId == null) throw Exception('No se recibió shortId');
    // Polling hasta que el job esté completed
    return await _pollJob(shortId);
  }

  /// Polling de job hasta que esté completed
  Future<Map<String, dynamic>> _pollJob(String shortId) async {
    final pollUrl = Uri.parse('$baseUrl/inscripcion/tasks/gettask/$shortId');
    const maxAttempts = 30;
    const delay = Duration(seconds: 2);
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await http.get(pollUrl);
      if (response.statusCode == 200) {
        final jobJson = jsonDecode(response.body);
        final job = jobJson['job'];
        if (job != null && job['state'] == 'completed') {
          return job;
        } else if (job != null && job['state'] == 'failed') {
          throw Exception('Job falló: ${job['failedReason'] ?? 'Error desconocido'}');
        }
      }
      await Future.delayed(delay);
    }
    throw Exception('Timeout esperando job $shortId');
  }
}
