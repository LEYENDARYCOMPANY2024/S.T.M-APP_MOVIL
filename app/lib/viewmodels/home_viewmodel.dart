import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/token_service.dart';
import '../models/terapeuta.dart';
import '../models/paciente.dart'; // Asegúrate de importar el modelo de Paciente

class HomeViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  
  Terapeuta? terapeuta; // Datos del terapeuta
  Paciente? paciente; // Datos del paciente
  Map<String, dynamic>? proximaSesion; // Datos de la próxima sesión
  Map<String, dynamic>? datosProgreso; // Datos del progreso
  
  bool isLoading = true; // Estado de carga
  String? errorMessage; // Mensaje de error en caso de falla

  // Cargar todos los datos necesarios para la pantalla Home
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
      
      // Obtener los datos del terapeuta asignado
      terapeuta = await _pacienteService.getTerapeutaAsignado(userId);
      
      // Obtener los datos del paciente
      paciente = await _pacienteService.getPaciente(userId);
      
      // Obtener datos de la próxima sesión
      proximaSesion = await _pacienteService.getProximaSesion(userId);
      
      // Obtener datos de progreso del paciente
      datosProgreso = await _pacienteService.getDatosProgreso(userId);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar datos de Home: $e');
      errorMessage = "Ocurrió un error al cargar los datos";
      isLoading = false;
      notifyListeners();
    }
  }

  // Recargar datos (útil para un botón de actualizar)
  void recargarDatos() {
    cargarDatos();
  }

  // Cargar datos del perfil
  Future<void> cargarPerfil() async {
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
      errorMessage = "Ocurrió un error al cargar los datos del perfil";
      isLoading = false;
      notifyListeners();
    }
  }
}
