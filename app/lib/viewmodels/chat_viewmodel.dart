import 'package:flutter/material.dart';
import '../models/terapeuta.dart';
import '../models/paciente.dart';
import '../services/paciente_service.dart';
import '../services/auth_services.dart';
import '../services/sesion_service.dart';

class ChatViewModel with ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  final SesionService _sesionService = SesionService();
  final AuthService _authService = AuthService();

  bool isLoading = true;
  String? errorMessage;
  Paciente? paciente;
  List<Terapeuta> terapeutas = [];
  Terapeuta? selectedTerapeuta;

  Future<void> cargarDatos() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Obtener el ID del paciente desde el token
      final pacienteId = await _authService.obtenerIdPacienteDesdeToken();
      
      if (pacienteId == null) {
        throw Exception('No se pudo obtener el ID del paciente');
      }

      // Cargar datos del paciente
      paciente = await _pacienteService.getPaciente(pacienteId);

      if (paciente == null) {
        throw Exception('No se encontraron datos del paciente');
      }

      // Obtener terapeutas del paciente
      terapeutas = await _sesionService.getTerapeutasPaciente(pacienteId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error al cargar datos: ${e.toString()}';
      notifyListeners();
      print(errorMessage);
    }
  }

  Future<void> recargarDatos() async {
    await cargarDatos();
  }

  void selectTerapeuta(Terapeuta terapeuta) {
    selectedTerapeuta = terapeuta;
    notifyListeners();
  }
}