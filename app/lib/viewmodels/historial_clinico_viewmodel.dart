import 'package:flutter/material.dart';
import '../models/historial_clinico.dart';
import '../models/paciente.dart';
import '../services/historial_clinico_service.dart';
import '../services/paciente_service.dart';
import '../services/auth_services.dart';

class HistorialClinicoViewModel with ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();

  final HistorialClinicoService _historialService;
  final AuthService _authService;
  
  HistorialClinicoViewModel(this._historialService, this._authService);


  HistorialClinico? _historialClinico;
  Paciente? _paciente;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  HistorialClinico? get historialClinico => _historialClinico;
  Paciente? get paciente => _paciente;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Método para determinar si el paciente es mujer
  bool get esMujer => _paciente?.genero?.toLowerCase() == 'femenino';

  // Inicializar datos
  Future<void> init() async {
    _setLoading(true);
    try {
      final pacienteId = await _authService.obtenerIdPacienteDesdeToken();
      if (pacienteId == null) {
        _setError('No se pudo obtener el ID del paciente');
        return;
      }

      _paciente = await _pacienteService.getPaciente(pacienteId);
      if (_paciente == null) {
        _setError('No se encontró información del paciente');
        return;
      }

      _historialClinico = await _historialService.getHistorialClinicoPorId(pacienteId);
      
      // Si el historial es null o está vacío, mostrar mensaje apropiado
      if (_historialClinico == null || 
          _historialClinico!.datosHistorialClinico.isEmpty ||
          _historialClinico!.datosHistorialClinico.values
              .every((value) => value == null || value.toString().isEmpty)) {
        _historialClinico = null; // Asegurar que sea null para mostrar mensaje
      }

      _errorMessage = '';
    } catch (e) {
      print('Error al cargar datos: $e');
      _setError('Error al cargar los datos del historial clínico');
    } finally {
      _setLoading(false);
    }
  }

  // Establecer estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Establecer mensaje de error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Método para verificar si un campo es "Sí"
  bool esCampoSi(String? valor) {
    if (valor == null) return false;
    return valor.toLowerCase().contains('si');
  }

  // Método para obtener el valor de un campo con valor por defecto
  String obtenerValorCampo(String campo, {String valorDefecto = 'No especificado'}) {
    return _historialClinico?.datosHistorialClinico[campo]?.toString() ?? valorDefecto;
  }
}