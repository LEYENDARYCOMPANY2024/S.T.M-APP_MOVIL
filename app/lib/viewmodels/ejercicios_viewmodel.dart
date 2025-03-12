import 'package:flutter/material.dart';

class EjerciciosViewModel extends ChangeNotifier {
  // Lista de niveles con su estado de completado
  final List<Nivel> _niveles = [
    Nivel(nombre: "Nivel 1", descripcion: "ver más >", completado: false),
    Nivel(nombre: "Nivel 2", descripcion: "ver más >", completado: false),
    Nivel(nombre: "Nivel 3", descripcion: "a", completado: false),
    Nivel(nombre: "Nivel 4", descripcion: "b", completado: false),
    Nivel(nombre: "Nivel 5", descripcion: "b", completado: false),
    Nivel(nombre: "Nivel 6", descripcion: "a", completado: false),
    Nivel(nombre: "Nivel 7", descripcion: "a", completado: false),
    Nivel(nombre: "Nivel 8", descripcion: "a", completado: false),
  ];

  // Obtener la lista de niveles
  List<Nivel> get niveles => _niveles;

  // Marcar un nivel como completado
  void completarNivel(int index) {
    if (index >= 0 && index < _niveles.length) {
      _niveles[index].completado = true;
      notifyListeners(); // Notificar a los listeners que los datos han cambiado
    }
  }

  // Recargar datos (simulado)
  Future<void> recargarDatos() async {
    // Simular una carga de datos
    await Future.delayed(const Duration(seconds: 2));
    notifyListeners();
  }
}

// Modelo de datos para un nivel
class Nivel {
  final String nombre;
  final String descripcion;
  bool completado;

  Nivel({
    required this.nombre,
    required this.descripcion,
    this.completado = false,
  });
}