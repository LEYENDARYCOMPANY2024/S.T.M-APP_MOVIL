import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/terapeuta.dart';
import '../models/paciente.dart';
import '../services/hash_services.dart';

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

  Future<Map<String, dynamic>?> getProximaSesion(int pacienteId) async {
  try {
    // Obtener la fecha actual
    final now = DateTime.now();
    final hoy = now.toString().split(' ')[0]; // Formato YYYY-MM-DD
    
    // Primero, obtenemos todas las sesiones del paciente
    final response = await _supabase
        .from('paciente_sesiones_p')
        .select('sesiones(*)')
        .eq('id_paciente_ps_fk', pacienteId);
    
    print('📅 Respuesta de sesiones: $response');
    
    if (response.isEmpty) {
      print('ℹ️ No hay sesiones para el paciente ID: $pacienteId');
      return null;
    }

    
    // Filtrar y ordenar manualmente las sesiones para encontrar la próxima
    List<Map<String, dynamic>> sesiones = [];
    for (var item in response) {
      final sesionData = item['sesiones'];
      // Verificar si la fecha es futura o de hoy
      if (sesionData['fecha_inicio'] != null && sesionData['fecha_inicio'].compareTo(hoy) >= 0) {
        sesiones.add(sesionData);
      }
    }
    
    if (sesiones.isEmpty) {
      print('ℹ️ No hay sesiones futuras para el paciente ID: $pacienteId');
      return null;
    }
    
    // Ordenar las sesiones por fecha_inicio
    sesiones.sort((a, b) => a['fecha_inicio'].compareTo(b['fecha_inicio']));
    
    // Obtener la primera (más cercana) sesión
    final proximaSesion = sesiones.first;
    
    // Formatear la fecha para mostrarla en español
    final fechaInicio = DateTime.parse(proximaSesion['fecha_inicio']);
    final List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    final fechaFormateada = '${fechaInicio.day} de ${meses[fechaInicio.month - 1]}, ${fechaInicio.year}';
    
    // Extraer y formatear la hora
    String horaInicio = 'Pendiente';
    if (proximaSesion['hora_inicio'] != null) {
      try {
        // Intentar parsear la hora del timestamp
        final horaCompleta = DateTime.parse(proximaSesion['hora_inicio']);
        horaInicio = '${horaCompleta.hour.toString().padLeft(2, '0')}:${horaCompleta.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        print('⚠️ Error al parsear la hora: $e');
        // Si hay error, intentar extraer solo la parte de la hora si es un string
        if (proximaSesion['hora_inicio'] is String) {
          final partes = proximaSesion['hora_inicio'].split('T');
          if (partes.length > 1) {
            horaInicio = partes[1].substring(0, 5); // Formato HH:MM
          }
        }
      }
    }
    
    return {
      'fecha': fechaFormateada,
      'hora': horaInicio,
    };
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
}