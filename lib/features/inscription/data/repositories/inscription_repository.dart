import 'dart:convert';
import 'package:http/http.dart' as http;
import '../fake/fake_json.dart';

class InscriptionRepository {
  final String baseUrl = 'http://192.168.0.16:3000/api';

  // ✅ Simular obtener materias disponibles del estudiante
  Future<Map<String, dynamic>> getMaterias() async {
    // Simula una petición futura
    await Future.delayed(const Duration(milliseconds: 500));

    return fakeJson;
  }

  Future<Map<String, dynamic>> createInscripcionMaterias({
    required int estudianteId,
    required List<int> grupoMateriasIds,
    required String callbackUrl,
  }) async {
    final url = Uri.parse('http://192.168.0.16:3000/api/inscripcion/tasks');
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
    // Manejar status 200 y 201, y cuerpo vacío
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {"success": true, "message": "Inscripción realizada"};
      }
    } else {
      throw Exception('Error en la inscripción: ${response.statusCode}');
    }
  }

  Future<bool> postInscripcion({
    required int estudianteId,
    required List<int> grupoMateriasIds,
    required String callbackUrl,
  }) async {
    final url = Uri.parse('$baseUrl/inscripcion/tasks');

    final body = {
      "task": "create_inscripcion_materias",
      "data": {
        "estudianteId": estudianteId,
        "grupoMateriasIds": grupoMateriasIds,
      },
      "callback": callbackUrl,
    };

    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("inscripcion exitosamente: ${response.statusCode}");
      return false;
    }
  }
}
