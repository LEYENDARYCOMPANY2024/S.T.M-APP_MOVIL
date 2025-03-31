import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/terapeuta.dart';
import '../models/paciente.dart';
import '../services/hash_services.dart';
import 'package:intl/intl.dart';
import '../services/auth_services.dart';

class PacienteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener los datos del paciente
  Future<Paciente?> getPaciente(int pacienteId) async {
    try {
      // Consultamos la tabla de pacientes para obtener sus datos asegurando los campos necesarios
      final pacienteData = await _supabase
          .from('pacientes')
          .select('''
            id_paciente,
            nombre,
            primer_apellido,
            segundo_apellido,
            edad,
            codigo,
            genero,
            estado_civil,
            escolaridad,
            ocupacion,
            nombre_usuario_p,
            contrasena_p,
            estado_paciente,
            correo_electronico_p
          ''')
          .eq('id_paciente', pacienteId)
          .maybeSingle();

      print('📦 Datos recibidos del paciente: $pacienteData');

      if (pacienteData == null) {
        print('⚠️ No se encontró el paciente con ID: $pacienteId');
        return null;
      }

      return Paciente.fromMap(pacienteData); // Convertir el mapa a un objeto Paciente
    } catch (e) {
      print('❌ Error al obtener paciente: $e');
      return null;
    }
  }

  // Verificar la contraseña del paciente
  Future<bool> verificarContrasena(int pacienteId, String contrasenaIngresada) async {
    try {
      final pacienteData = await _supabase
          .from('pacientes')
          .select('contrasena_p')
          .eq('id_paciente', pacienteId)
          .maybeSingle();

      if (pacienteData == null) {
        print('⚠️ No se encontró el paciente con ID: $pacienteId');
        return false;
      }

      String contrasenaAlmacenada = pacienteData['contrasena_p'];
      
      // Usar el HashService para verificar la contraseña con BCrypt
      return HashService.verifyPassword(contrasenaIngresada, contrasenaAlmacenada);
    } catch (e) {
      print('❌ Error al verificar contraseña: $e');
      return false;
    }
  }

  // Actualizar el nombre de usuario y/o correo electrónico del paciente
  Future<bool> actualizarDatosPaciente(int pacienteId, {String? nuevoUsuario, String? nuevoCorreo}) async {
    try {
      Map<String, dynamic> datosActualizar = {};
      
      if (nuevoUsuario != null && nuevoUsuario.isNotEmpty) {
        datosActualizar['nombre_usuario_p'] = nuevoUsuario;
      }
      
      if (nuevoCorreo != null && nuevoCorreo.isNotEmpty) {
        datosActualizar['correo_electronico_p'] = nuevoCorreo;
      }
      
      if (datosActualizar.isEmpty) {
        return false; // No hay datos para actualizar
      }

      await _supabase
          .from('pacientes')
          .update(datosActualizar)
          .eq('id_paciente', pacienteId);
      
      print('✅ Datos actualizados correctamente');
      return true;
    } catch (e) {
      print('❌ Error al actualizar datos del paciente: $e');
      return false;
    }
  }

  // Obtener el terapeuta asignado al paciente
  Future<Terapeuta?> getTerapeutaAsignado(int pacienteId) async {
    try {
      // Primero consultamos la tabla terapeuta_paciente para obtener el id del terapeuta
      final relacionData = await _supabase
          .from('terapeuta_paciente')
          .select('id_terapeuta_tp_fk')
          .eq('id_paciente_tp_fk', pacienteId)
          .maybeSingle();

      if (relacionData == null) {
        print('⚠️ Paciente no tiene terapeuta asignado');
        return null;
      }

      int terapeutaId = relacionData['id_terapeuta_tp_fk'];

      // Luego obtenemos los datos del terapeuta
      final terapeutaData = await _supabase
          .from('terapeutas')
          .select()
          .eq('id_terapeuta', terapeutaId)
          .maybeSingle();

      if (terapeutaData == null) {
        print('⚠️ No se encontró el terapeuta con ID: $terapeutaId');
        return null;
      }

      return Terapeuta.fromMap(terapeutaData); // Convertir el mapa a un objeto Terapeuta
    } catch (e) {
      print('❌ Error al obtener terapeuta asignado: $e');
      return null;
    }
  }

  // Obtener la próxima sesión
  Future<Map<String, dynamic>?> getProximaSesion(int pacienteId) async {
    try {
      final now = DateTime.now();
      
      final response = await _supabase
          .from('paciente_sesiones_p')
          .select('''
            sesiones (
              fecha_inicio,
              hora_inicio,
              descripcion_sesion
            )
          ''')
          .eq('id_paciente_ps_fk', pacienteId)
          .order('sesiones(fecha_inicio)', ascending: true)
          .order('sesiones(hora_inicio)', ascending: true);

      if (response.isEmpty) return null;

      // Filtrar y encontrar la próxima sesión
      for (var item in response) {
        if (item['sesiones'] != null) {
          final fechaSesion = DateTime.parse(item['sesiones']['fecha_inicio']);
          final horaSesion = DateTime.parse(item['sesiones']['hora_inicio']);
          
          // Combinar fecha y hora para comparación
          final fechaHoraSesion = DateTime(
            fechaSesion.year,
            fechaSesion.month,
            fechaSesion.day,
            horaSesion.hour,
            horaSesion.minute,
          );

          if (fechaHoraSesion.isAfter(now)) {
            return {
              'fecha': DateFormat('dd/MM/yyyy').format(fechaSesion),
              'hora': DateFormat('HH:mm').format(horaSesion),
              'descripcion': item['sesiones']['descripcion_sesion'],
            };
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ Error al obtener próxima sesión: $e');
      return null;
    }
  }

  // Obtener datos de progreso del paciente
  Future<Map<String, dynamic>> getDatosProgreso(int pacienteId) async {
    // Aquí implementarías la consulta para obtener datos de progreso
    // Por ahora retornaremos datos ficticios
    return {
      'sesionesCompletadas': 8,
      'progresoGeneral': 75, // Porcentaje
    };
  }

  Future<bool> actualizarInformacionPersonal(
    int pacienteId, {
    required String nombre,
    required String primerApellido,
    required String segundoApellido,
    required int edad,
    required String genero,
    String? estadoCivil,
    String? escolaridad,
    required String ocupacion,
  }) async {
    try {
      await _supabase
          .from('pacientes')
          .update({
            'nombre': nombre,
            'primer_apellido': primerApellido,
            'segundo_apellido': segundoApellido,
            'edad': edad,
            'genero': genero,
            'estado_civil': estadoCivil,
            'escolaridad': escolaridad,
            'ocupacion': ocupacion,
          })
          .eq('id_paciente', pacienteId);
      
      print('✅ Información personal actualizada correctamente');
      return true;
    } catch (e) {
      print('❌ Error al actualizar información personal: $e');
      return false;
    }
  }

  // Obtener o crear chat con terapeuta
  Future<Map<String, dynamic>?> obtenerOCrearChat(Terapeuta terapeuta) async {
    try {
      // Obtener el ID del paciente desde el token
      final pacienteId = await AuthService().obtenerIdPacienteDesdeToken();
      if (pacienteId == null) {
        throw Exception('No se pudo obtener el ID del paciente');
      }

      // Primero obtenemos el id_terapeuta_paciente
      final terapeutaPacienteData = await _supabase
          .from('terapeuta_paciente')
          .select('id_terapeuta_paciente')
          .eq('id_terapeuta_tp_fk', terapeuta.id)
          .eq('id_paciente_tp_fk', pacienteId)
          .single();

      final idTerapeutaPaciente = terapeutaPacienteData['id_terapeuta_paciente'];

      // Buscamos si existe un chat
      final chatExistente = await _supabase
          .from('chat')
          .select('''
            *,
            mensajes (
              id_mensaje,
              mensaje,
              remitente,
              enviado_en
            )
          ''')
          .eq('id_terapeuta_paciente_c_fk', idTerapeutaPaciente)
          .maybeSingle();

      if (chatExistente != null) {
        print('✅ Chat existente encontrado');
        return chatExistente;
      }

      // Si no existe, creamos uno nuevo
      final nuevoChat = await _supabase
          .from('chat')
          .insert({
            'id_terapeuta_paciente_c_fk': idTerapeutaPaciente,
          })
          .select()
          .single();

      print('✅ Nuevo chat creado');
      return {
        ...nuevoChat,
        'mensajes': [],
      };
    } catch (e) {
      print('❌ Error al obtener/crear chat: $e');
      return null;
    }
  }

  // Obtener mensajes de un chat
  Future<List<Map<String, dynamic>>> obtenerMensajes(int idChat) async {
    try {
      final mensajes = await _supabase
          .from('mensajes')
          .select()
          .eq('id_chat_m_fk', idChat)
          .order('enviado_en', ascending: true);

      print('✅ Mensajes obtenidos: ${mensajes.length}');
      return List<Map<String, dynamic>>.from(mensajes);
    } catch (e) {
      print('❌ Error al obtener mensajes: $e');
      return [];
    }
  }

  // Enviar un nuevo mensaje
  Future<bool> enviarMensaje({
    required int idChat,
    required String mensaje,
    required String remitente,
  }) async {
    try {
      await _supabase
          .from('mensajes')
          .insert({
            'id_chat_m_fk': idChat,
            'mensaje': mensaje,
            'remitente': 'paciente',
          });

      print('✅ Mensaje enviado correctamente');
      return true;
    } catch (e) {
      print('❌ Error al enviar mensaje: $e');
      return false;
    }
  }
}