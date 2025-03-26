import 'dart:convert';

class HistorialClinico {
  final int? idHistorialClinico;
  final int idPacienteHcFk;
  final Map<String, dynamic> datosHistorialClinico;

  HistorialClinico({
    this.idHistorialClinico,
    required this.idPacienteHcFk,
    required this.datosHistorialClinico,
  });

  factory HistorialClinico.fromMap(Map<String, dynamic> map) {
    print('Datos recibidos: $map');
    
    // Si datos_historial_clinico es null, retornar un mapa vacío
    Map<String, dynamic> datos = {};
    
    if (map['datos_historial_clinico'] != null) {
      if (map['datos_historial_clinico'] is String) {
        try {
          datos = json.decode(map['datos_historial_clinico']);
        } catch (e) {
          print('Error decodificando JSON: $e');
        }
      } else if (map['datos_historial_clinico'] is Map) {
        datos = Map<String, dynamic>.from(map['datos_historial_clinico']);
      }
    }

    return HistorialClinico(
      idHistorialClinico: map['id_historial_clinico'] as int?,
      idPacienteHcFk: map['id_paciente_hc_fk'] as int,
      datosHistorialClinico: datos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_historial_clinico': idHistorialClinico,
      'id_paciente_hc_fk': idPacienteHcFk,
      'datos_historial_clinico': datosHistorialClinico,
    };
  }

  // Método para crear un historial clínico vacío
  factory HistorialClinico.empty(int idPaciente) {
    return HistorialClinico(
      idPacienteHcFk: idPaciente,
      datosHistorialClinico: {
        "hta": "",
        "imc": "",
        "peso": "",
        "fecha": "",
        "hijos": "",
        "libre": "",
        "cancer": "",
        "drogas": "",
        "abierta": "",
        "alergia": "",
        "ataxica": "",
        "encames": "",
        "cirugias": "",
        "conAyuda": "",
        "diabetes": "",
        "embarazo": "",
        "espasmos": "",
        "estatura": "",
        "queloide": "",
        "sitioHTA": "",
        "fracturas": "",
        "retractil": "",
        "accidentes": "",
        "adherencia": "",
        "automedica": "",
        "espasticas": "",
        "expediente": "",
        "reumaticas": "",
        "sitioOtros": "",
        "sitioSitio": "",
        "tabaquismo": "",
        "alcoholismo": "",
        "claudicante": "",
        "otrosMarcha": "",
        "sitioCancer": "",
        "sitioDrogas": "",
        "cardiopatias": "",
        "hipertrofica": "",
        "sitioAlergia": "",
        "sitioHabitos": "",
        "sitioMujeres": "",
        "sitioDiabetes": "",
        "sitioEspasmos": "",
        "sitioLenguaje": "",
        "sitioreflejos": "",
        "transfusiones": "",
        "sitioActividad": "",
        "sitioFracturas": "",
        "actividadFisica": "",
        "sitioAutomedica": "",
        "valoracionFinal": "",
        "sitioAlcoholismo": "",
        "sitioReutmaticas": "",
        "sitioSensibilidad": "",
        "valoracionInicial": "",
        "sitioTransfusiones": "",
        "Marchaobservaciones": "",
        "observacionesMarcha": "",
        "Observacionesfinales": "",
      },
    );
  }

  // Copia con valores actualizados
  HistorialClinico copyWith({
    int? idHistorialClinico,
    int? idPacienteHcFk,
    Map<String, dynamic>? datosHistorialClinico,
  }) {
    return HistorialClinico(
      idHistorialClinico: idHistorialClinico ?? this.idHistorialClinico,
      idPacienteHcFk: idPacienteHcFk ?? this.idPacienteHcFk,
      datosHistorialClinico: datosHistorialClinico ?? this.datosHistorialClinico,
    );
  }
}