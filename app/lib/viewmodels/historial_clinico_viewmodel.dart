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
      // Obtener ID del paciente actual
      final pacienteId = await _authService.obtenerIdPacienteDesdeToken();
      if (pacienteId == null) {
        _setError('No se pudo obtener el ID del paciente');
        return;
      }

      // Cargar datos del paciente
      _paciente = await _pacienteService.getPaciente(pacienteId);
      if (_paciente == null) {
        _setError('No se encontró información del paciente');
        return;
      }

      // Cargar historial clínico
      _historialClinico = await _historialService.getHistorialClinicoPorId(pacienteId);
      if (_historialClinico?.datosHistorialClinico == null) {
        _setError('Los datos del historial clínico están incompletos o nulos');
        return;
      }

      
      _errorMessage = '';
    } catch (e) {
      _setError('Error al cargar datos: $e');
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
}