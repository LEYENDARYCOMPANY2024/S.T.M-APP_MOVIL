import 'package:flutter/material.dart';
import '../services/paciente_service.dart';
import '../services/email_service.dart';
import '../services/hash_services.dart';

class RestablecerContrasenaViewModel extends ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  final TextEditingController usuarioCorreoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController nuevaContrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();
  
  bool _usuarioEncontrado = false;
  bool _codigoEnviado = false;
  bool _codigoValidado = false;
  bool _cargando = false;
  String _mensajeError = '';
  Map<String, dynamic>? _pacienteEncontrado;
  String? _codigoGenerado;

  bool get usuarioEncontrado => _usuarioEncontrado;
  bool get codigoEnviado => _codigoEnviado;
  bool get codigoValidado => _codigoValidado;
  bool get cargando => _cargando;
  String get mensajeError => _mensajeError;
  Map<String, dynamic>? get pacienteEncontrado => _pacienteEncontrado;

  Future<bool> buscarUsuario() async {
    _cargando = true;
    _mensajeError = '';
    notifyListeners();

    try {
      final response = await _pacienteService.buscarPacientePorUsuarioOCorreo(
        usuarioCorreoController.text.trim()
      );

      if (response != null) {
        _pacienteEncontrado = response;
        _usuarioEncontrado = true;
        _mensajeError = '';
      } else {
        _usuarioEncontrado = false;
        _mensajeError = 'No se encontró ningún usuario con esos datos';
      }
    } catch (e) {
      _usuarioEncontrado = false;
      _mensajeError = 'Ocurrió un error al buscar el usuario';
      print('❌ Error al buscar usuario: $e');
    }

    _cargando = false;
    notifyListeners();
    return _usuarioEncontrado;
  }

  Future<bool> enviarCodigoRestablecimiento() async {
    if (_pacienteEncontrado == null) return false;

    _cargando = true;
    notifyListeners();

    try {
      // Generar código de 6 dígitos
      _codigoGenerado = List.generate(6, (_) => (DateTime.now().millisecondsSinceEpoch % 10).toString()).join();
      
      // Guardar código en la base de datos
      final codigoGuardado = await _pacienteService.enviarCodigoRestablecimiento(
        _pacienteEncontrado!['id_paciente'],
        _pacienteEncontrado!['correo_electronico_p']
      );

      if (codigoGuardado) {
        // Enviar correo con el código
        final emailEnviado = await EmailService.enviarCodigoRestablecimiento(
          _pacienteEncontrado!['correo_electronico_p'],
          _codigoGenerado!
        );

        if (emailEnviado) {
          _codigoEnviado = true;
          _mensajeError = '';
        } else {
          _mensajeError = 'Error al enviar el correo electrónico';
        }
      } else {
        _mensajeError = 'Error al generar el código de restablecimiento';
      }

      _cargando = false;
      notifyListeners();
      return _codigoEnviado;
    } catch (e) {
      _mensajeError = 'Error al enviar el código de restablecimiento';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validarCodigo() async {
    if (_pacienteEncontrado == null) return false;

    _cargando = true;
    notifyListeners();

    try {
      // Obtener el código y su fecha de expiración de la base de datos
      final pacienteData = await _pacienteService.obtenerCodigoRestablecimiento(_pacienteEncontrado!['id_paciente']);
      
      if (pacienteData == null || 
          pacienteData['codigo_restablecimiento'] == null || 
          pacienteData['fecha_expiracion_codigo'] == null) {
        _mensajeError = 'No hay un código de restablecimiento válido';
        _cargando = false;
        notifyListeners();
        return false;
      }

      // Verificar si el código ha expirado
      final fechaExpiracion = DateTime.parse(pacienteData['fecha_expiracion_codigo']);
      if (DateTime.now().isAfter(fechaExpiracion)) {
        _mensajeError = 'El código ha expirado. Por favor, solicita uno nuevo';
        _cargando = false;
        notifyListeners();
        return false;
      }

      // Verificar si el código coincide
      if (codigoController.text.trim() != pacienteData['codigo_restablecimiento']) {
        _mensajeError = 'Código inválido';
        _cargando = false;
        notifyListeners();
        return false;
      }

      _codigoValidado = true;
      _mensajeError = '';
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _mensajeError = 'Error al validar el código';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restablecerContrasena() async {
    if (!_codigoValidado || _pacienteEncontrado == null) return false;

    if (nuevaContrasenaController.text != confirmarContrasenaController.text) {
      _mensajeError = 'Las contraseñas no coinciden';
      notifyListeners();
      return false;
    }

    if (nuevaContrasenaController.text.length < 6) {
      _mensajeError = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      // Hashear la nueva contraseña
      final hashedPassword = await HashService.hashPassword(nuevaContrasenaController.text);
      
      // Actualizar la contraseña en la base de datos
      final actualizado = await _pacienteService.actualizarContrasena(
        _pacienteEncontrado!['id_paciente'],
        hashedPassword
      );

      if (actualizado) {
        // Enviar correo de confirmación
        await EmailService.enviarConfirmacionCambioContrasena(
          _pacienteEncontrado!['correo_electronico_p']
        );
        _mensajeError = '';
      } else {
        _mensajeError = 'Error al actualizar la contraseña';
      }

      _cargando = false;
      notifyListeners();
      return actualizado;
    } catch (e) {
      _mensajeError = 'Error al restablecer la contraseña';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  void limpiar() {
    usuarioCorreoController.clear();
    codigoController.clear();
    nuevaContrasenaController.clear();
    confirmarContrasenaController.clear();
    _usuarioEncontrado = false;
    _codigoEnviado = false;
    _codigoValidado = false;
    _cargando = false;
    _mensajeError = '';
    _pacienteEncontrado = null;
    _codigoGenerado = null;
    notifyListeners();
  }

  @override
  void dispose() {
    usuarioCorreoController.dispose();
    codigoController.dispose();
    nuevaContrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }
} 