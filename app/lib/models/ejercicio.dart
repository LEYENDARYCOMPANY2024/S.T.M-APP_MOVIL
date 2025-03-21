// models/ejercicio.dart
class Ejercicio {
  final int id;
  final String nombre;
  final String instrucciones;
  final String? videoUrl;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.instrucciones,
    this.videoUrl,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      id: map['id_ejercicio'] ?? 0,
      nombre: map['nom_ejercicio'] ?? '',
      instrucciones: map['instrucciones'] ?? '',
      videoUrl: map['video_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_ejercicio': id,
      'nom_ejercicio': nombre,
      'instrucciones': instrucciones,
      'video_url': videoUrl,
    };
  }
}