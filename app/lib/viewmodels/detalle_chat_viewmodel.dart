import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../models/terapeuta.dart';

class DetalleChatViewModel with ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> mensajes = [];
  int? idChat;
  
  Future<void> inicializarChat(Terapeuta terapeuta) async {
    try {
      isLoading = true;
      notifyListeners();

      final chatData = await _pacienteService.obtenerOCrearChat(terapeuta);
      
      if (chatData == null) {
        throw Exception('No se pudo obtener el chat');
      }

      idChat = chatData['id_chat'];
      if (chatData['mensajes'] != null) {
        mensajes = List<Map<String, dynamic>>.from(chatData['mensajes']);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error al cargar el chat: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> cargarMensajes() async {
    if (idChat == null) return;

    try {
      final nuevosMensajes = await _pacienteService.obtenerMensajes(idChat!);
      mensajes = nuevosMensajes;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar mensajes: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> enviarMensaje(String mensaje) async {
    if (idChat == null || mensaje.trim().isEmpty) return false;

    try {
      final enviado = await _pacienteService.enviarMensaje(
        idChat: idChat!,
        mensaje: mensaje.trim(),
        remitente: 'PACIENTE',
      );

      if (enviado) {
        await cargarMensajes(); // Recargar mensajes después de enviar
      }

      return enviado;
    } catch (e) {
      errorMessage = 'Error al enviar mensaje: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
} 
 