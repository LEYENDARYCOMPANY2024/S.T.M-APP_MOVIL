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
    
    // Mapa con valores por defecto siguiendo la estructura del historial clínico
    Map<String, dynamic> datosDefault = {
      // Expediente
      "expediente": "",
      "fecha": "",

      // Exploración Física
      "peso": "",
      "estatura": "",
      "imc": "",
      "espasmos": "espasmosNo",
      "sitioEspasmos": "",

      // Antecedentes Patológicos
      "diabetes": "diabetesNo",
      "sitioDiabetes": "",
      "alergia": "alergiaNo",
      "sitioAlergia": "",
      "hta": "htaNo",
      "sitioHTA": "",
      "cancer": "cancerNo",
      "sitioCancer": "",
      "transfusiones": "transfusionesNo",
      "sitioTransfusiones": "",
      "reumaticas": "reumaticasNo",
      "sitioReutmaticas": "",
      "encames": "",
      "accidentes": "",
      "cardiopatias": "",
      "cirugias": "",
      "fracturas": "fracturasNo",
      "sitioFracturas": "",

      // Hábitos de Salud
      "tabaquismo": "tabaquismoNo",
      "sitioHabitos": "",
      "alcoholismo": "alcoholismoNo",
      "sitioAlcoholismo": "",
      "drogas": "drogasNo",
      "sitioDrogas": "",
      "actividadFisica": "actividadFisicaNo",
      "sitioActividad": "",
      "automedica": "automedicaNo",
      "sitioAutomedica": "",

      // Diagnóstico Médico
      "sitioreflejos": "",
      "sitioSensibilidad": "",
      "sitioLenguaje": "",
      "sitioOtros": "",

      // Cicatriz Quirúrgica
      "sitioSitio": "",
      "queloide": "queloideNo",
      "abierta": "abiertaNo",
      "retractil": "retractilNo",
      "adherencia": "adherenciaNo",
      "hipertrofica": "hipertroficaNo",

      // Marcha y Deambulación
      "libre": "libreNo",
      "espasticas": "espasticasNo",
      "claudicante": "claudicanteNo",
      "ataxica": "ataxicaNo",
      "conAyuda": "conAyudaNo",
      "otrosMarcha": "",
      "observacionesMarcha": "",

      // Traslados
      "valoracionFinal": "",
      "Observacionesfinales": "",

      // Información específica para mujeres
      "embarazo": "embarazoNo",
      "hijos": "",
    };

    // Procesar los datos recibidos
    Map<String, dynamic> datosRecibidos = {};
    if (map['datos_historial_clinico'] != null) {
      if (map['datos_historial_clinico'] is String) {
        try {
          datosRecibidos = json.decode(map['datos_historial_clinico']);
        } catch (e) {
          print('Error decodificando JSON: $e');
        }
      } else if (map['datos_historial_clinico'] is Map) {
        datosRecibidos = Map<String, dynamic>.from(map['datos_historial_clinico']);
      }
    }

    // Combinar los datos por defecto con los recibidos
    Map<String, dynamic> datosFinal = {...datosDefault, ...datosRecibidos};

    return HistorialClinico(
      idHistorialClinico: map['id_historial_clinico'] as int?,
      idPacienteHcFk: map['id_paciente_hc_fk'] as int,
      datosHistorialClinico: datosFinal,
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