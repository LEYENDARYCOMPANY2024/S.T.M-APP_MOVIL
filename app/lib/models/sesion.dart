import 'package:intl/intl.dart'; // Para el formato de fecha y hora

class Sesion {
  final int id;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime horaInicio;
  final String? notaEvolutiva;
  final Map<String, dynamic> videoMediapipe;
  final String nombreTerapeuta; // Para mostrar a qué terapeuta pertenece la sesión

  Sesion({
    required this.id,
    required this.descripcion,
    required this.fechaInicio,
    required this.horaInicio,
    this.notaEvolutiva,
    required this.videoMediapipe,
    required this.nombreTerapeuta,
  });

  // Convertir un mapa (de Supabase) a un objeto Sesion
  factory Sesion.fromMap(Map<String, dynamic> map, String nombreTerapeuta) {
    return Sesion(
      id: map['id_sesion'] ?? 0,
      descripcion: map['descripcion_sesion'] ?? '',
      fechaInicio: DateTime.tryParse(map['fecha_inicio'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      horaInicio: DateTime.tryParse(map['hora_inicio'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      notaEvolutiva: map['nota_evolutiva'] ?? 'Sin nota',
      videoMediapipe: map['video_mediapipe_t'] ?? {},
      nombreTerapeuta: nombreTerapeuta,
    );
  }

  // Convertir objeto Sesion a un mapa (para futuras operaciones)
  Map<String, dynamic> toMap() {
    return {
      'id_sesion': id,
      'descripcion_sesion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'hora_inicio': horaInicio.toIso8601String(),
      'nota_evolutiva': notaEvolutiva,
      'video_mediapipe_t': videoMediapipe.isEmpty ? null : videoMediapipe,
    };
  }

  // Formato amigable para la fecha
  String get fechaFormateada {
    return DateFormat('dd/MM/yyyy').format(fechaInicio);
  }

  // Formato amigable para la hora
  String get horaFormateada {
    return DateFormat('HH:mm').format(horaInicio);
  }
}
