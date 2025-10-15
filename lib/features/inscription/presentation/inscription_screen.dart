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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Inscripción',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF6C757D),
            ),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda mejorado
          _buildSearchCard(),
          const SizedBox(height: 24),
          
          if (isLoading) _buildLoadingIndicator(),
          if (errorMessage.isNotEmpty) _buildErrorMessage(),
          if (estudianteData != null) ...[
            _buildStudentInfo(),
            const SizedBox(height: 24),
            _buildSubjectsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: registroController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de registro',
                hintText: 'Ingrese su número de registro',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C757D)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(
                  isLoading ? 'Buscando...' : 'Buscar estudiante y oferta',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: isLoading ? null : _performSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      elevation: 8,
      shadowColor: Colors.red.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEB2B2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC3545)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Color(0xFFDC3545),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.12),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${estudianteData?['nombre']} ${estudianteData?['apellidoPaterno']} ${estudianteData?['apellidoMaterno']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registro: ${estudianteData?['registro']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
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
  }

  Widget _buildSubjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oferta Académica Disponible',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        if (maestroOferta.isEmpty)
          _buildEmptyOfferCard()
        else ...[
          for (var materia in maestroOferta) _buildSubjectCard(materia),
          if (materiasOfertaSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildInscriptionButton(),
          ],
        ],
        if (inscripcionResult != null) ...[
          const SizedBox(height: 24),
          _buildInscriptionResult(),
        ],
      ],
    );
  }

  Widget _buildEmptyOfferCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDBF47)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF856404)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay oferta académica disponible para este estudiante.',
                style: TextStyle(
                  color: Color(0xFF856404),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(dynamic materia) {
    final materiaId = materia['id'] as int;
    final grupos = materia['Grupo_Materia'] as List<dynamic>? ?? [];
    final bool todosSinCupo = grupos.every((grupo) => (grupo['cupo'] ?? 0) <= 0);
    final bool isSelected = materiasOfertaSeleccionadas.contains(materiaId);

    return Card(
      elevation: isSelected ? 12 : 8,
      shadowColor: isSelected 
          ? const Color(0xFF007BFF).withOpacity(0.4) 
          : Colors.black.withOpacity(0.15),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? const BorderSide(color: Color(0xFF007BFF), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF007BFF).withOpacity(0.05),
                    const Color(0xFF007BFF).withOpacity(0.02),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: grupos.isEmpty || todosSinCupo 
                            ? const Color(0xFFDEE2E6) 
                            : const Color(0xFF007BFF),
                        width: 2,
                      ),
                      color: isSelected ? const Color(0xFF007BFF) : Colors.transparent,
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materia['nombre'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: todosSinCupo ? const Color(0xFF6C757D) : const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007BFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                materia['sigla'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF007BFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nivel ${materia['nivel']}',
                              style: const TextStyle(
                                color: Color(0xFF6C757D),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (todosSinCupo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8D7DA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF5C6CB)),
                      ),
                      child: const Text(
                        'SIN CUPOS',
                        style: TextStyle(
                          color: Color(0xFF721C24),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: grupos.isEmpty || todosSinCupo ? null : () {
                      setState(() {
                        if (isSelected) {
                          materiasOfertaSeleccionadas.remove(materiaId);
                          gruposOfertaSeleccionados.remove(materiaId);
                        } else {
                          materiasOfertaSeleccionadas.add(materiaId);
                          if (grupos.isNotEmpty) {
                            final grupoConCupo = grupos.firstWhere(
                              (g) => (g['cupo'] ?? 0) > 0,
                              orElse: () => grupos.first,
                            );
                            gruposOfertaSeleccionados[materiaId] = grupoConCupo['id'] as int;
                          }
                        }
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: grupos.isEmpty || todosSinCupo 
                              ? const Color(0xFFDEE2E6) 
                              : const Color(0xFF007BFF),
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFF007BFF) : Colors.transparent,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
              
              // Advertencia si hay algunos grupos sin cupos
              if (grupos.isNotEmpty && !todosSinCupo && grupos.any((g) => (g['cupo'] ?? 0) <= 0)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDBF47)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFF856404), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Algunos grupos no tienen cupos disponibles',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (grupos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Grupos disponibles:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
                const SizedBox(height: 12),
                for (var grupo in grupos) _buildGroupTile(grupo, materiaId),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8D7DA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF5C6CB)),
                  ),
                  child: const Text(
                    'Sin grupos disponibles',
                    style: TextStyle(
                      color: Color(0xFF721C24),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(dynamic grupo, int materiaId) {
    final bool isSelected = materiasOfertaSeleccionadas.contains(materiaId);
    final bool sinCupos = (grupo['cupo'] ?? 0) <= 0;
    final bool isGroupSelected = gruposOfertaSeleccionados[materiaId] == grupo['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isGroupSelected 
            ? const Color(0xFF007BFF).withOpacity(0.1) 
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGroupSelected 
              ? const Color(0xFF007BFF) 
              : const Color(0xFFE9ECEF),
        ),
      ),
      child: RadioListTile<int>(
        value: grupo['id'] as int,
        groupValue: gruposOfertaSeleccionados[materiaId],
        onChanged: isSelected && !sinCupos
            ? (val) {
                setState(() {
                  gruposOfertaSeleccionados[materiaId] = val!;
                });
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Grupo ${grupo['sigla']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: sinCupos ? const Color(0xFF6C757D) : const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                if (sinCupos)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8D7DA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF5C6CB)),
                    ),
                    child: const Text(
                      'SIN CUPOS',
                      style: TextStyle(
                        color: Color(0xFF721C24),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: sinCupos 
                        ? const Color(0xFFF8D7DA) 
                        : const Color(0xFFD1ECF1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Cupos: ${grupo['cupo'] ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: sinCupos 
                          ? const Color(0xFF721C24) 
                          : const Color(0xFF0C5460),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prof. ${grupo['Docente']?['nombre']} ${grupo['Docente']?['apellidoPaterno']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C757D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: (grupo['AulaHorarios'] as List<dynamic>? ?? []).isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  for (var horario in (grupo['AulaHorarios'] as List<dynamic>? ?? []))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${horario['Horario']?['dia']} ${horario['Horario']?['inicio']}-${horario['Horario']?['final']} - Aula ${horario['Aula']?['numero']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ),
                ],
              )
            : const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Sin horarios asignados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDC3545),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInscriptionButton() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007BFF).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: isInscribing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.assignment_turned_in_rounded, size: 24),
          label: Text(
            isInscribing ? 'Procesando inscripción...' : 'Confirmar Inscripción',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: isInscribing ? null : () => _showInscripcionConfirmation(),
        ),
      ),
    );
  }

  Widget _buildInscriptionResult() {
    final success = inscripcionResult?['success'] == true;
    final result = inscripcionResult?['result'];
    
    return Card(
      elevation: 10,
      shadowColor: success 
          ? Colors.green.withOpacity(0.4) 
          : Colors.red.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: success 
                ? [
                    const Color(0xFFD4EDDA),
                    const Color(0xFFC3E6CB),
                  ]
                : [
                    const Color(0xFFF8D7DA),
                    const Color(0xFFF5C6CB),
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
                      color: success 
                          ? const Color(0xFF28A745) 
                          : const Color(0xFFDC3545),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      success ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      success ? 'Inscripción Exitosa' : 'Error en la Inscripción',
                      style: TextStyle(
                        color: success 
                            ? const Color(0xFF155724) 
                            : const Color(0xFF721C24),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 16),
                if (result['message'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result['message'],
                      style: TextStyle(
                        color: success 
                            ? const Color(0xFF155724) 
                            : const Color(0xFF721C24),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Mostrar materias sin cupos si existen
                if (result['grupoSinCupo'] != null && (result['grupoSinCupo'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Materias sin cupos disponibles:',
                    style: TextStyle(
                      color: const Color(0xFF721C24),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var grupo in result['grupoSinCupo'])
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDC3545).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_rounded, color: const Color(0xFFDC3545), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  grupo['Materium']?['nombre'] ?? 'Materia desconocida',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF721C24),
                                  ),
                                ),
                                Text(
                                  '${grupo['Materium']?['sigla'] ?? 'N/A'} - Grupo: ${grupo['sigla'] ?? 'N/A'} - Cupos: ${grupo['cupo'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF721C24),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showInscripcionConfirmation() {
    // Crear lista de materias seleccionadas con sus detalles
    final List<Map<String, dynamic>> materiasSeleccionadas = [];
    
    for (final materiaId in materiasOfertaSeleccionadas) {
      final materia = maestroOferta.firstWhere((m) => m['id'] == materiaId);
      final grupoId = gruposOfertaSeleccionados[materiaId];
      final grupos = materia['Grupo_Materia'] as List<dynamic>? ?? [];
      final grupo = grupos.firstWhere((g) => g['id'] == grupoId, orElse: () => null);
      
      materiasSeleccionadas.add({
        'materia': materia,
        'grupo': grupo,
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Color(0xFF007BFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirmar Inscripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Confirmas tu inscripción en las siguientes materias?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF495057),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var item in materiasSeleccionadas) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007BFF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['materia']['sigla'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF007BFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['materia']['nombre'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item['grupo'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Grupo: ${item['grupo']['sigla']}',
                                  style: const TextStyle(
                                    color: Color(0xFF6C757D),
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (item['grupo']['cupo'] ?? 0) > 0
                                        ? const Color(0xFFD1ECF1)
                                        : const Color(0xFFF8D7DA),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: (item['grupo']['cupo'] ?? 0) > 0
                                          ? const Color(0xFF0C5460)
                                          : const Color(0xFF721C24),
                                    ),
                                  ),
                                  child: Text(
                                    'Cupos: ${item['grupo']['cupo'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: (item['grupo']['cupo'] ?? 0) > 0
                                          ? const Color(0xFF0C5460)
                                          : const Color(0xFF721C24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if ((item['grupo']['cupo'] ?? 0) <= 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8D7DA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFF5C6CB)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_rounded, color: Color(0xFFDC3545), size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Advertencia: Este grupo no tiene cupos disponibles',
                                        style: TextStyle(
                                          color: Color(0xFF721C24),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 52, 95),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _realizarInscripcion();
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text(
                'Confirmar Inscripción',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _realizarInscripcion() async {
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
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC3545),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar tu sesión actual?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF495057),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF6C757D),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    // Navegar de vuelta a la pantalla de login
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  }
}
