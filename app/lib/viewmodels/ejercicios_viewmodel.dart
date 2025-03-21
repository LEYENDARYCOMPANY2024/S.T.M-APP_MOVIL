// viewmodels/ejercicios_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/nivel.dart';
import '../services/ejercicios_services.dart';

class EjerciciosViewModel extends ChangeNotifier {
  final EjerciciosService _ejerciciosService;
  List<Nivel> _niveles = [];
  bool _cargando = false;
  String _error = '';
  int _idPaciente = 0; // Esto debería venir de tu sistema de autenticación

  EjerciciosViewModel(this._ejerciciosService);

  // Getters
  List<Nivel> get niveles => _niveles;
  bool get cargando => _cargando;
  String get error => _error;

  // Establecer el ID del paciente actual
  void establecerIdPaciente(int id) {
    _idPaciente = id;
  }

  // Cargar niveles y ejercicios
  Future<void> cargarNivelesYEjercicios() async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      // Verificar que tenemos un ID de paciente válido
      if (_idPaciente <= 0) {
        _error = 'No se ha establecido un paciente válido';
        _cargando = false;
        notifyListeners();
        return;
      }

      _niveles = await _ejerciciosService.obtenerNivelesConEjercicios(_idPaciente);
      print('Niveles cargados: ${_niveles.map((n) => '${n.nombre}: ${n.estado}').toList()}');
      
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar los niveles y ejercicios: $e';
      _cargando = false;
      notifyListeners();
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
      return _niveles[index].estado == 'desbloqueado';
    }
    return false;
  }
}
