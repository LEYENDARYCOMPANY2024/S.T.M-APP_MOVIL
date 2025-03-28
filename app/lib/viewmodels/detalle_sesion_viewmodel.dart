import 'package:flutter/material.dart';
import '../models/sesion.dart';

class DetalleSesionViewModel extends ChangeNotifier {
  Sesion? sesion;
  bool isLoading = false;
  String? errorMessage;

  void setSesion(Sesion sesionDetalle) {
    sesion = sesionDetalle;
    notifyListeners();
  }

  // Agregar método para recargar datos
  Future<void> recargarDatos() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Aquí podrías agregar lógica adicional para recargar los datos de la sesión si es necesario
      
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
