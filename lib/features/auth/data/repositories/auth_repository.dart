import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estudiante_model.dart';

class AuthRepository {
  static const String baseUrl = 'http://localhost:3000/api/inscripcion/tasks';
  static const int maxRetries = 15;
  static const Duration pollingInterval = Duration(seconds: 2);

  Future<List<EstudianteModel>> getEstudiantes() async {
    // Paso 1: POST inicial para crear tarea
    final postResponse = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'task': 'get_estudiante',
        'data': {},
        'callback': 'http://localhost:5000/callback'
      }),
    );

    if (postResponse.statusCode != 200) {
      throw Exception('Error en servidor: ${postResponse.statusCode}');
    }

    final postData = jsonDecode(postResponse.body);
    final shortId = postData['shortId'];

    // Paso 2: Polling para obtener resultado
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      await Future.delayed(pollingInterval);
      
      try {
        final getResponse = await http.get(
          Uri.parse('$baseUrl/gettask/$shortId'),
        );

        if (getResponse.statusCode == 200) {
          final data = jsonDecode(getResponse.body);
          final job = data['job'];
          
          if (job != null && job['state'] == 'completed') {
            final returnValue = job['returnvalue'];
            if (returnValue['success'] == true) {
              final estudiantesJson = returnValue['estudiantes'] as List;
              return estudiantesJson
                  .map((json) => EstudianteModel.fromJson(json))
                  .toList();
            } else {
              throw Exception('Error en la respuesta del servidor');
            }
          }
        }
        // Si es error 500 o no está completo, continúa el polling
      } catch (e) {
        // Ignora errores temporales y continúa el polling
        if (attempt == maxRetries - 1) {
          throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
        }
      }
    }

    throw Exception('No se pudo obtener la información. Intenta nuevamente.');
  }

  EstudianteModel? validateCredentials(
    List<EstudianteModel> estudiantes,
    String registro,
    String ci,
  ) {
    for (var estudiante in estudiantes) {
      if (estudiante.registro.toString() == registro && estudiante.ci == ci) {
        return estudiante;
      }
    }
    return null;
  }
}