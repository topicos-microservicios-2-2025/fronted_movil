import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobTrackingScreen extends StatefulWidget {
  final int shortId;
  final String queue;
  final Map<String, dynamic>? estudianteData;

  const JobTrackingScreen({
    Key? key,
    required this.shortId,
    required this.queue,
    this.estudianteData,
  }) : super(key: key);

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  String _currentStatus = 'waiting';
  Map<String, dynamic>? _jobResult;
  bool _isCompleted = false;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTracking();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isCompleted) {
        _checkJobStatus();
      }
    });
    // Check immediately
    _checkJobStatus();
  }

  Future<void> _checkJobStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.14:3000/api/inscripcion/tasks/${widget.shortId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentStatus = data['estado'] ?? 'waiting';
          if (data['returnvalue'] != null) {
            _jobResult = data['returnvalue'];
          }
        });

        if (_currentStatus == 'completed' || _currentStatus == 'failed') {
          _timer?.cancel();
          _pulseController.stop();
          _progressController.forward();
          setState(() {
            _isCompleted = true;
          });
        }
      }
    } catch (e) {
      print('Error checking job status: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Estado de Inscripción',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6C757D)),
          onPressed: () => Navigator.of(context).pop(_jobResult),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildJobInfoCard(),
              const SizedBox(height: 24),
              _buildStatusCard(),
              const SizedBox(height: 24),
              if (_isCompleted && _jobResult != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobInfoCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.assignment_turned_in_rounded,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            if (widget.estudianteData != null)
              Text(
                '${widget.estudianteData!['nombre']} ${widget.estudianteData!['apellidoPaterno']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              'Job ID: ${widget.shortId}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cola: ${widget.queue}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (_currentStatus) {
      case 'waiting':
        statusColor = const Color(0xFFFFC107);
        statusIcon = Icons.hourglass_empty_rounded;
        statusText = 'En Cola';
        statusDescription = 'Tu solicitud está siendo procesada...';
        break;
      case 'active':
        statusColor = const Color(0xFF007BFF);
        statusIcon = Icons.sync_rounded;
        statusText = 'Procesando';
        statusDescription = 'Inscribiendo materias seleccionadas...';
        break;
      case 'completed':
        statusColor = const Color(0xFF28A745);
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Completado';
        statusDescription = 'Proceso de inscripción finalizado';
        break;
      case 'failed':
        statusColor = const Color(0xFFDC3545);
        statusIcon = Icons.error_rounded;
        statusText = 'Error';
        statusDescription = 'Hubo un problema con la inscripción';
        break;
      default:
        statusColor = const Color(0xFF6C757D);
        statusIcon = Icons.help_rounded;
        statusText = 'Desconocido';
        statusDescription = 'Estado no reconocido';
    }

    return Card(
      elevation: 10,
      shadowColor: statusColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            if (!_isCompleted)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, size: 40, color: Colors.white),
                    ),
                  );
                },
              )
            else
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _progressAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, size: 40, color: Colors.white),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusDescription,
              style: TextStyle(
                fontSize: 16,
                color: statusColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isCompleted) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                backgroundColor: statusColor.withOpacity(0.2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_jobResult == null) return const SizedBox.shrink();

    print('=== DEBUG JobResult ===');
    print('Full jobResult: $_jobResult');

    final success = _jobResult!['success'] == true;
    final result = _jobResult!['result'];

    print('First level success: $success');
    print('First level result: $result');

    // Extraer el resultado anidado si existe - manejo mejorado
    dynamic nestedResult = result;

    // Si result tiene otra estructura anidada, extraerla
    if (result is Map) {
      if (result.containsKey('result')) {
        nestedResult = result['result'];
        print('Found nested result: $nestedResult');
      }
    }

    print('Final nestedResult: $nestedResult');

    // Detectar si es un problema de cupos - múltiples formas de detectarlo
    final hasGroupsWithoutQuota =
        nestedResult != null &&
        nestedResult is Map &&
        nestedResult['grupoSinCupo'] != null &&
        nestedResult['grupoSinCupo'] is List &&
        (nestedResult['grupoSinCupo'] as List).isNotEmpty;

    final hasQuotaMessage =
        nestedResult != null &&
        nestedResult is Map &&
        nestedResult['message'] != null &&
        nestedResult['message'] is String &&
        (nestedResult['message'] as String).toLowerCase().contains('cupo');

    final isQuotaIssue = hasGroupsWithoutQuota || hasQuotaMessage;

    print('hasGroupsWithoutQuota: $hasGroupsWithoutQuota');
    print('hasQuotaMessage: $hasQuotaMessage');
    print('isQuotaIssue: $isQuotaIssue');

    Color resultColor;
    String resultTitle;
    IconData resultIcon;

    if (!success) {
      resultColor = const Color(0xFFDC3545);
      resultTitle = 'Inscripción Fallida';
      resultIcon = Icons.error_rounded;
    } else if (isQuotaIssue) {
      resultColor = Colors.orange.shade700;
      resultTitle = 'No se pudo inscribir';
      resultIcon = Icons.warning_rounded;
    } else {
      resultColor = const Color(0xFF28A745);
      resultTitle = 'Inscripción Exitosa';
      resultIcon = Icons.check_circle_rounded;
    }

    print('Final resultTitle: $resultTitle');
    print('=== END DEBUG ===');

    return Card(
      elevation: 10,
      shadowColor: resultColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              resultColor.withOpacity(0.1),
              resultColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: resultColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(resultIcon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      resultTitle,
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              if (nestedResult != null && nestedResult is Map) ...[
                const SizedBox(height: 16),
                if (nestedResult['message'] != null &&
                    nestedResult['message'] is String)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isQuotaIssue
                          ? Colors.orange.shade50
                          : resultColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: resultColor.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: resultColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: resultColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isQuotaIssue
                                    ? Icons.warning_rounded
                                    : Icons.info_outline,
                                color: resultColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isQuotaIssue
                                    ? 'Motivo de la inscripción no completada:'
                                    : 'Información:',
                                style: TextStyle(
                                  color: resultColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nestedResult['message'],
                          style: TextStyle(
                            color: resultColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Mostrar materias sin cupos si existen
                if (hasGroupsWithoutQuota) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Materias sin cupos:',
                    style: TextStyle(
                      color: resultColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var grupo in (nestedResult['grupoSinCupo'] as List))
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: resultColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: resultColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  grupo['Materium']?['nombre'] ??
                                      'Materia desconocida',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: resultColor,
                                  ),
                                ),
                                Text(
                                  '${grupo['Materium']?['sigla'] ?? 'N/A'} - Grupo: ${grupo['sigla'] ?? 'N/A'} - Cupos: ${grupo['cupo'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: resultColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(_jobResult);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text(
                    'Volver a Inscripción',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: resultColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
