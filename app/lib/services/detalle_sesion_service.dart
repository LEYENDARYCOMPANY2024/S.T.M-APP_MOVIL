import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/paciente_service.dart';
import '../models/sesion.dart';
import '../models/grafica_datos.dart';

class DetalleSesionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PacienteService _pacienteService = PacienteService();

  Future<Sesion?> obtenerDetalleSesion(int sesionId) async {
    try {
      final response = await _supabase
          .from('paciente_sesiones_p')
          .select('sesiones(*)')
          .eq('sesiones.id_sesion', sesionId)
          .single();

      if (response == null) return null;

      final sesionData = response['sesiones'];
      return Sesion.fromMap(sesionData, "");
    } catch (e) {
      print('❌ Error al obtener detalle de sesión: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> obtenerDatosGraficas(int sesionId) async {
    try {
      print('🔍 Buscando datos de gráficas para la sesión $sesionId');
      
      // Primero obtener los datos de la sesión
      final sesionResponse = await _supabase
          .from('sesiones')
          .select()
          .eq('id_sesion', sesionId)
          .single();

      if (sesionResponse == null) {
        print('⚠️ No se encontró la sesión $sesionId');
        return {};
      }

      // Luego obtener los datos de las gráficas
      final graficasResponse = await _supabase
          .from('graficas_tablas_movil')
          .select()
          .eq('id_sesion_fk', sesionId)
          .order('fecha_registro', ascending: false)
          .limit(1);

      print('📦 Respuesta de gráficas recibida: ${graficasResponse?.length ?? 0} registros');
      
      if (graficasResponse == null || graficasResponse.isEmpty) {
        print('⚠️ No hay datos de gráficas disponibles para la sesión $sesionId');
        return {};
      }

      final graficaData = graficasResponse[0];
      print('📊 Estructura de datos recibida: ${graficaData.keys.join(', ')}');
      
      // Verificar que los datos de las gráficas existan
      if (graficaData['datos_graficas'] == null) {
        print('⚠️ No hay datos de gráficas disponibles');
        return {};
      }

      final datosGraficas = graficaData['datos_graficas'] as Map<String, dynamic>;
      print('📈 Contenido de datos_graficas: $datosGraficas');

      if (datosGraficas['derecha'] == null || datosGraficas['izquierda'] == null) {
        print('⚠️ Los datos de las gráficas están incompletos');
        print('Derecha: ${datosGraficas['derecha']}');
        print('Izquierda: ${datosGraficas['izquierda']}');
        return {};
      }

      try {
        // Adaptar los datos al formato que espera el modelo
        final datosAdaptados = {
          'derecha': datosGraficas['derecha'],
          'izquierda': datosGraficas['izquierda'],
          'fecha_registro': graficaData['fecha_registro'],
        };

        final grafica = GraficaDatos.fromMap(datosAdaptados);
        print('✅ Datos de gráficas procesados correctamente');
        print('Derecha: ${grafica.derecha.length} puntos');
        print('Izquierda: ${grafica.izquierda.length} puntos');

        // Procesar los datos para las gráficas
        return {
          'sesion': {
            'id': sesionResponse['id_sesion'],
            'fecha': sesionResponse['fecha_inicio'],
            'hora': sesionResponse['hora_inicio'],
            'descripcion': sesionResponse['descripcion_sesion'],
            'notaEvolutiva': sesionResponse['nota_evolutiva'],
          },
          'graficas': {
            'derecha': grafica.derecha.map((d) => {'value': d.value, 'timestamp': d.timestamp}).toList(),
            'izquierda': grafica.izquierda.map((d) => {'value': d.value, 'timestamp': d.timestamp}).toList(),
            'fechaRegistro': grafica.fechaRegistro.toIso8601String(),
          }
        };
      } catch (e) {
        print('❌ Error al procesar los datos de la gráfica: $e');
        print('Datos recibidos: $graficaData');
        return {};
      }
    } catch (e) {
      print('❌ Error al obtener datos de gráficas: $e');
      return {};
    }
  }
}
