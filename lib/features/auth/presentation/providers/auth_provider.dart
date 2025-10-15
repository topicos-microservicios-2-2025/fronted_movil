import 'package:flutter/foundation.dart';
import '../../data/models/estudiante_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, loadingPolling, success, error }

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  EstudianteModel? _currentStudent;
  List<EstudianteModel>? _estudiantes;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  EstudianteModel? get currentStudent => _currentStudent;

  Future<void> login(String registro, String ci) async {
    if (registro.isEmpty || ci.isEmpty) {
      _setError('Por favor, ingresa tu registro y CI');
      return;
    }

    _setStatus(AuthStatus.loading);

    try {
      // Obtener lista de estudiantes
      _setStatus(AuthStatus.loadingPolling);
      _estudiantes = await _authRepository.getEstudiantes();

      // Validar credenciales
      final student = _authRepository.validateCredentials(
        _estudiantes!,
        registro,
        ci,
      );

      if (student != null) {
        _currentStudent = student;
        _setStatus(AuthStatus.success);
      } else {
        _setError('Registro o CI incorrecto. Verifica tus datos.');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _status = AuthStatus.initial;
    notifyListeners();
  }

  void logout() {
    _currentStudent = null;
    _estudiantes = null;
    _status = AuthStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}