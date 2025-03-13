import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/sesion_service.dart';
import '../models/terapeuta.dart';
import '../models/sesion.dart';

class SesionesViewModel extends ChangeNotifier {
  final SesionService _sesionService = SesionService();
  
  List<Terapeuta> terapeutas = [];
  Map<int, List<Sesion>> sesionesPorTerapeuta = {};
  
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = "";
  
  // Cargar todos los terapeutas del paciente
  Future<void> cargarTerapeutas() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      // Obtener el ID del usuario actual
      final userId = await TokenService.getUserId();
      
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // Obtener los terapeutas del paciente
      terapeutas = await _sesionService.getTerapeutasPaciente(userId);
      
      // Inicializar el mapa de sesiones por terapeuta
      sesionesPorTerapeuta.clear();
      
      // Para cada terapeuta, cargar sus sesiones con el paciente
      for (var terapeuta in terapeutas) {
        await cargarSesionesTerapeuta(userId, terapeuta.id);
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar terapeutas: $e');
      errorMessage = "Ocurrió un error al cargar los datos de terapeutas";
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar las sesiones de un terapeuta específico
  Future<void> cargarSesionesTerapeuta(int pacienteId, int terapeutaId) async {
    try {
      // Obtener las sesiones del paciente con este terapeuta
      List<Sesion> sesiones = await _sesionService.getSesionesPacienteConTerapeuta(pacienteId, terapeutaId);
      
      // Actualizar el mapa de sesiones por terapeuta
      sesionesPorTerapeuta[terapeutaId] = sesiones;
      
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar sesiones del terapeuta $terapeutaId: $e');
    }
  }
  
  // Buscar terapeuta por nombre
  Future<void> buscarTerapeuta(String query) async {
    try {
      searchQuery = query;
      isLoading = true;
      notifyListeners();
      
      final userId = await TokenService.getUserId();
      
      if (userId == null) {
        errorMessage = "No se pudo obtener el ID del usuario";
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // Buscar terapeutas por nombre
      terapeutas = await _sesionService.buscarTerapeuta(userId, query);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al buscar terapeuta: $e');
      errorMessage = "Ocurrió un error al buscar terapeutas";
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Recargar todos los datos
  void recargarDatos() {
    cargarTerapeutas();
  }
}