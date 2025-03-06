import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/token_service.dart';
import '../models/paciente.dart';

class PerfilViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  Paciente? paciente; // Datos del paciente

  bool isLoading = true; // Estado de carga
  String? errorMessage; // Mensaje de error en caso de falla

  // Cargar los datos del paciente para la pantalla de perfil
  Future<void> cargarDatos() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Obtener el ID del usuario actual desde el servicio de tokens
      final userId = await TokenService.getUserId();

      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Obtener los datos del paciente
      paciente = await _pacienteService.getPaciente(userId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar datos del perfil: $e');
      errorMessage = "Ocurrió un error al cargar los datos";
      isLoading = false;
      notifyListeners();
    }
  }
}
