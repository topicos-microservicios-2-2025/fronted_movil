const Map<String, dynamic> fakeJson = {
  "success": true,
  "result": {
    "success": true,
    "estudiante": {
      "estudiante": {
        "id": 1,
        "ci": "12345678",
        "nombre": "Carlos",
        "apellidoPaterno": "García",
        "apellidoMaterno": "López",
        "fechaNacimiento": "2000-01-01T00:00:00.000Z",
        "nacionalidad": "Boliviana",
        "registro": 1,
        "Detalle_carrera_cursadas": [
          {
            "id": 1,
            "fechaInscripcion": "2024-02-10T00:00:00.000Z",
            "Plan_de_estudio": {
              "id": 1,
              "nombre": "Plan 2023 - Ingeniería Informática",
              "tipoPeriodo": "Semestral",
              "modalidad": "Presencial",
              "codigo": "INF-2023",
              "carreraId": 1
            }
          }
        ]
      },
      "materiasVencidasLista": [
        {"id": 1, "nombre": "FISICA I", "horasDeEstudio": 8, "sigla": "FIS100", "nivel": 1, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 2, "nombre": "INTRODUCCION A LA INFORMATICA", "horasDeEstudio": 6, "sigla": "INF110", "nivel": 1, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 3, "nombre": "ESTRUCTURAS DISCRETAS", "horasDeEstudio": 6, "sigla": "INF119", "nivel": 1, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 4, "nombre": "INGLES TECNICO I", "horasDeEstudio": 6, "sigla": "LIN100", "nivel": 1, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 5, "nombre": "CALCULO I", "horasDeEstudio": 6, "sigla": "MAT101", "nivel": 1, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 6, "nombre": "FISICA II", "horasDeEstudio": 8, "sigla": "FIS102", "nivel": 2, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 7, "nombre": "PROGRAMACION I", "horasDeEstudio": 6, "sigla": "INF120", "nivel": 2, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 8, "nombre": "INGLES TECNICO II", "horasDeEstudio": 6, "sigla": "LIN101", "nivel": 2, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 9, "nombre": "CALCULO II", "horasDeEstudio": 6, "sigla": "MAT102", "nivel": 2, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 10, "nombre": "ALGEBRA LINEAL", "horasDeEstudio": 6, "sigla": "MAT103", "nivel": 2, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 11, "nombre": "ADMINISTRACION", "horasDeEstudio": 6, "sigla": "ADM100", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 12, "nombre": "PROGRAMACION II", "horasDeEstudio": 6, "sigla": "INF210", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 13, "nombre": "ARQUITECTURA DE COMPUTADORAS", "horasDeEstudio": 6, "sigla": "INF211", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 14, "nombre": "ECUACIONES DIFERENCIALES", "horasDeEstudio": 6, "sigla": "MAT207", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 15, "nombre": "FISICA III", "horasDeEstudio": 8, "sigla": "FIS200", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 16, "nombre": "TEORIA DE CAMPOS", "horasDeEstudio": 6, "sigla": "ELT241", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 17, "nombre": "ANALISIS DE CIRCUITOS", "horasDeEstudio": 6, "sigla": "RDS210", "nivel": 3, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 18, "nombre": "CONTABILIDAD", "horasDeEstudio": 6, "sigla": "ADM200", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 19, "nombre": "ESTRUCTURA DE DATOS I", "horasDeEstudio": 6, "sigla": "INF220", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 20, "nombre": "PROGRAMACION ENSAMBLADOR", "horasDeEstudio": 6, "sigla": "INF221", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 21, "nombre": "PROBABILIDADES Y ESTADIST.I", "horasDeEstudio": 6, "sigla": "MAT202", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 22, "nombre": "METODOS NUMERICOS", "horasDeEstudio": 6, "sigla": "MAT205", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 23, "nombre": "ANALISIS DE CIRCUITOS ELECTRONICOS", "horasDeEstudio": 6, "sigla": "RDS220", "nivel": 4, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 24, "nombre": "ESTRUCTURAS DE DATOS II", "horasDeEstudio": 6, "sigla": "INF310", "nivel": 5, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 25, "nombre": "BASE DE DATOS I", "horasDeEstudio": 6, "sigla": "INF312", "nivel": 5, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 26, "nombre": "PROGRAMAC.LOGICA Y FUNCIONAL", "horasDeEstudio": 6, "sigla": "INF318", "nivel": 5, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"},
        {"id": 27, "nombre": "LENGUAJES FORMALES", "horasDeEstudio": 6, "sigla": "INF319", "nivel": 5, "createdAt": "2025-10-09T12:46:10.177Z", "updatedAt": "2025-10-09T12:46:10.177Z"}
      ],
      "maestroOferta": [
        {
          "id": 28,
          "nombre": "PROBABILIDADES Y ESTADISTICAS II",
          "horasDeEstudio": 6,
          "sigla": "MAT302",
          "nivel": 5,
          "Grupo_Materia": [
            {
              "id": 55,
              "sigla": "SC",
              "materiaId": 28,
              "docenteId": 1,
              "periodoId": 1,
              "cupo": 15,
              "createdAt": "2025-10-09T12:46:10.181Z",
              "updatedAt": "2025-10-09T12:46:10.181Z",
              "Docente": {
                "id": 1,
                "nombre": "Juan",
                "apellidoPaterno": "Martínez",
                "apellidoMaterno": "Rojas",
                "ci": "11223344",
                "fechaNac": "1980-03-10T00:00:00.000Z",
                "profesion": "Ingeniero de Sistemas",
                "createdAt": "2025-10-09T12:46:10.166Z",
                "updatedAt": "2025-10-09T12:46:10.166Z"
              }
            },
            {
              "id": 56,
              "sigla": "SA",
              "materiaId": 28,
              "docenteId": 2,
              "periodoId": 1,
              "cupo": 15,
              "createdAt": "2025-10-09T12:46:10.181Z",
              "updatedAt": "2025-10-09T12:46:10.181Z",
              "Docente": {
                "id": 2,
                "nombre": "María",
                "apellidoPaterno": "Fernández",
                "apellidoMaterno": "Gómez",
                "ci": "44332211",
                "fechaNac": "1975-07-22T00:00:00.000Z",
                "profesion": "Licenciada en Filosofía",
                "createdAt": "2025-10-09T12:46:10.166Z",
                "updatedAt": "2025-10-09T12:46:10.166Z"
              }
            }
          ]
        }
      ]
    }
  }
};
