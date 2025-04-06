import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static final _supabase = Supabase.instance.client;
  static const String _remitente = 'leyendary2024@gmail.com';
  
  static String get _functionEndpoint => dotenv.env['ENDPOINT_URL'] ?? 
    'https://hxjmzijhcmhfcrjcptge.supabase.co/functions/v1/send-email';

  static Future<bool> enviarCodigoRestablecimiento(String destinatario, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse(_functionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['SUPABASE_ANON_KEY']}',
          'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? ''
        },
        body: jsonEncode({
          'to': destinatario,
          'type': 'reset',
          'code': codigo,
        }),
      );

      print('📧 Respuesta del servidor: ${response.body}');
      print('📧 Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ Error al enviar correo: ${response.body}');
        return false;
      }

      print('✉️ Código de restablecimiento enviado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al enviar correo: $e');
      return false;
    }
  }

  static Future<bool> enviarConfirmacionCambioContrasena(String destinatario) async {
    try {
      final response = await http.post(
        Uri.parse(_functionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['SUPABASE_ANON_KEY']}',
          'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? ''
        },
        body: jsonEncode({
          'to': destinatario,
          'type': 'confirmation',
        }),
      );

      print('📧 Respuesta del servidor: ${response.body}');
      print('📧 Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ Error al enviar correo: ${response.body}');
        return false;
      }

      print('✉️ Confirmación de cambio de contraseña enviada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al enviar correo: $e');
      return false;
    }
  }
} 