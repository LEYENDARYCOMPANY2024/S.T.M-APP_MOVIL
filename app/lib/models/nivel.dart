// models/nivel.dart
import 'ejercicio.dart';

class Nivel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int orden;
  final String estado; // 'bloqueado' o 'desbloqueado'
  final List<Ejercicio> ejercicios;
  bool expandido; // para controlar el estado del desplegable

  Nivel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    this.ejercicios = const [],
    this.expandido = false,
  });

  factory Nivel.fromMap(Map<String, dynamic> map) {
    return Nivel(
      id: map['id_nivel'] ?? 0,
      nombre: map['nombre_nivel'] ?? '',
      descripcion: map['descripcion'],
      orden: map['orden'] ?? 0,
      estado: map['estado'] ?? 'bloqueado',
      ejercicios: [],
    );
  }

  Nivel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    int? orden,
    String? estado,
    List<Ejercicio>? ejercicios,
    bool? expandido,
  }) {
    return Nivel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      orden: orden ?? this.orden,
      estado: estado ?? this.estado,
      ejercicios: ejercicios ?? this.ejercicios,
      expandido: expandido ?? this.expandido,
    );
  }
}