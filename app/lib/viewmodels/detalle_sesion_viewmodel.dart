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
}
