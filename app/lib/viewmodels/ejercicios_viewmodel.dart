import 'package:flutter/material.dart';
import '../models/nivel.dart';
import '../services/ejercicios_services.dart';

class EjerciciosViewModel extends ChangeNotifier {
  final EjerciciosService _ejerciciosService;
  List<Nivel> _niveles = [];
  bool _cargando = false;
  String _error = '';

  EjerciciosViewModel(this._ejerciciosService);

  // Getters
  List<Nivel> get niveles => _niveles;
  bool get cargando => _cargando;
  String get error => _error;

  // Cargar niveles y ejercicios
  Future<void> cargarNivelesYEjercicios() async {
    try {
      _cargando = true;
      _error = '';
      notifyListeners();

      _niveles = await _ejerciciosService.obtenerNivelesConEjercicios();
      print('Niveles cargados: ${_niveles.map((n) => '${n.nombre}: ${n.estado}').toList()}');
      
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar los niveles y ejercicios: $e';
      _cargando = false;
      notifyListeners();
      throw e; // Importante para que el RefreshIndicator sepa que hubo un error
    }
  }

  // Cambiar el estado de expansión de un nivel
  void toggleExpansion(int index) {
    if (index >= 0 && index < _niveles.length) {
      _niveles[index] = _niveles[index].copyWith(
        expandido: !_niveles[index].expandido
      );
      notifyListeners();
    }
  }

  // Verificar si un nivel está desbloqueado
  bool nivelDesbloqueado(int index) {
    if (index >= 0 && index < _niveles.length) {
      String estadoActual = _niveles[index].estado.toString().toLowerCase().trim();
      return estadoActual.contains('desbloqueado');
    }
    return false;
  }
}
