import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../inscription/presentation/inscription_screen.dart';

class EstudianteModel {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String ci;
  final int registro;
  final String carrera;
  final String planEstudios;
  final String estado;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.ci,
    required this.registro,
    required this.carrera,
    required this.planEstudios,
    required this.estado,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'] ?? '',
      ci: json['ci'] ?? '',
      registro: json['registro'] ?? 0,
      carrera: json['carrera'] ?? '',
      planEstudios: json['planEstudios'] ?? '',
      estado: json['estado'] ?? '',
    );
  }

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

enum AuthStatus { initial, loading, loadingPolling, success, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registroController = TextEditingController();
  final _ciController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  EstudianteModel? _currentStudent;

  static const String baseUrl = 'http://192.168.0.14:3000/api/inscripcion/tasks';
  static const int maxRetries = 15;
  static const Duration pollingInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _registroController.dispose();
    _ciController.dispose();
    super.dispose();
  }

  Future<List<EstudianteModel>> _getEstudiantes() async {
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

    // 202 es aceptable para tareas asíncronas
    if (postResponse.statusCode != 200 && postResponse.statusCode != 202) {
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
          
          if (job != null) {
            if (job['state'] == 'completed') {
              final returnValue = job['returnvalue'];
              
              if (returnValue['success'] == true) {
                final estudiantesJson = returnValue['estudiantes'] as List;
                return estudiantesJson
                    .map((json) => EstudianteModel.fromJson(json))
                    .toList();
              } else {
                throw Exception('Error en la respuesta del servidor: ${returnValue['message'] ?? 'Sin mensaje'}');
              }
            } else if (job['state'] == 'failed') {
              throw Exception('La tarea falló: ${job['error'] ?? 'Error desconocido'}');
            }
          }
        }
        // Si es error 500 o no está completo, continúa el polling
      } catch (e) {
        // Ignora errores temporales y continúa el polling
        if (attempt == maxRetries - 1) {
          throw Exception('Tiempo de espera agotado después de $maxRetries intentos. Último error: $e');
        }
      }
    }

    throw Exception('No se pudo obtener la información después de $maxRetries intentos.');
  }

  EstudianteModel? _validateCredentials(
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

  Future<void> _login(String registro, String ci) async {
    if (registro.isEmpty || ci.isEmpty) {
      setState(() {
        _status = AuthStatus.error;
        _errorMessage = 'Por favor, ingresa tu registro y CI';
      });
      return;
    }

    setState(() {
      _status = AuthStatus.loading;
      _errorMessage = '';
    });

    try {
      // Obtener lista de estudiantes
      setState(() {
        _status = AuthStatus.loadingPolling;
      });
      
      final estudiantes = await _getEstudiantes();

      // Validar credenciales
      final student = _validateCredentials(estudiantes, registro, ci);

      if (student != null) {
        setState(() {
          _currentStudent = student;
          _status = AuthStatus.success;
        });
        
        // Navegar a la pantalla de inscripción
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const InscriptionScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _status = AuthStatus.error;
          _errorMessage = 'Registro o CI incorrecto. Verifica tus datos.';
        });
      }
    } catch (e) {
      setState(() {
        _status = AuthStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0), // Azul UAGRM
              Color(0xFF0D47A1),
              Color(0xFFD32F2F), // Rojo UAGRM
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 50),
                    _buildLoginForm(),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildErrorMessage(),
                    _buildLoadingMessage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Inscripción UAGRM',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sistema de Inscripción de Materias',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _registroController,
              label: 'Número de Registro',
              icon: Icons.person,
              keyboardType: TextInputType.number,
              enabled: _status != AuthStatus.loading &&
                       _status != AuthStatus.loadingPolling,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu número de registro';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'El registro debe contener solo números';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _ciController,
              label: 'Cédula de Identidad',
              icon: Icons.lock,
              obscureText: true,
              enabled: _status != AuthStatus.loading &&
                       _status != AuthStatus.loadingPolling,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu cédula de identidad';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildLoginButton() {
    final isLoading = _status == AuthStatus.loading ||
                     _status == AuthStatus.loadingPolling;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFD32F2F).withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_status != AuthStatus.error) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    String message = '';
    
    switch (_status) {
      case AuthStatus.loading:
        message = 'Conectando con el servidor...';
        break;
      case AuthStatus.loadingPolling:
        message = 'Verificando credenciales...';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1565C0)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF1565C0),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _login(
        _registroController.text.trim(),
        _ciController.text.trim(),
      );
    }
  }
}