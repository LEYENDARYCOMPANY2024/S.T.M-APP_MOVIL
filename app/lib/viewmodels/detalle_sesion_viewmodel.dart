import 'package:flutter/material.dart';
import '../models/sesion.dart';
import '../services/detalle_sesion_service.dart';

class DetalleSesionViewModel extends ChangeNotifier {
  final DetalleSesionService _service = DetalleSesionService();
  Sesion? sesion;
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic> datosGraficas = {};

  void setSesion(Sesion sesionDetalle) {
    sesion = sesionDetalle;
    _cargarDatosGraficas();
    notifyListeners();
  }

  Future<void> _cargarDatosGraficas() async {
    if (sesion == null) return;
    
    try {
      isLoading = true;
      notifyListeners();
      
      datosGraficas = await _service.obtenerDatosGraficas(sesion!.id);
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Error al cargar los datos de las gráficas";
      isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> recargarDatos() async {
    try {
      isLoading = true;
      notifyListeners();
      
      if (sesion != null) {
        await _cargarDatosGraficas();
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Error al recargar los datos";
      isLoading = false;
      notifyListeners();
      throw e;
    }
  }
}
