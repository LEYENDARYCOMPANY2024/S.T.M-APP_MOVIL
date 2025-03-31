import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/paciente_service.dart';
import '../services/auth_services.dart';
import '../models/terapeuta.dart';

class DetalleChatViewModel with ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _chatChannel;
  
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> mensajes = [];
  int? idChat;

  @override
  void dispose() {
    _desuscribirse();
    super.dispose();
  }

  void _desuscribirse() async {
    await _chatChannel?.unsubscribe();
    _chatChannel = null;
  }
  
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

      // Una vez que tenemos el idChat, nos suscribimos a los cambios
      await _suscribirseACambios();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error al cargar el chat: ${e.toString()}';
      notifyListeners();
      print('❌ Error en inicializarChat: $e');
    }
  }

  Future<void> _suscribirseACambios() async {
    if (idChat == null) return;

    try {
      // Nos desuscribimos primero si hay una suscripción existente
      _desuscribirse();

      // Crear nueva suscripción
      _chatChannel = _supabase.channel('public:mensajes').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'mensajes',
        callback: (payload) async {
          print('📨 Nuevo mensaje recibido: $payload');
          // Verificar si el mensaje pertenece a este chat
          if (payload.newRecord['id_chat_m_fk'] == idChat) {
            await cargarMensajes();
          }
        },
      );

      await _chatChannel?.subscribe();
      print('✅ Suscripción a mensajes establecida para chat $idChat');
    } catch (e) {
      print('❌ Error al suscribirse a mensajes: $e');
      errorMessage = 'Error al suscribirse a actualizaciones: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> cargarMensajes() async {
    if (idChat == null) return;

    try {
      final nuevosMensajes = await _pacienteService.obtenerMensajes(idChat!);
      mensajes = nuevosMensajes;
      notifyListeners();
      print('✅ Mensajes actualizados: ${mensajes.length} mensajes');
    } catch (e) {
      print('❌ Error al cargar mensajes: $e');
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
        remitente: 'paciente',
      );

      if (enviado) {
        print('✅ Mensaje enviado correctamente');
      }

      return enviado;
    } catch (e) {
      print('❌ Error al enviar mensaje: $e');
      errorMessage = 'Error al enviar mensaje: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
} 
 