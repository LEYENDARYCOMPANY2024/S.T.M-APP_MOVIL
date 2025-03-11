import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../viewmodels/perfil_viewmodel.dart';

class PerfilDesign extends StatefulWidget {
  final Paciente paciente;

  const PerfilDesign({Key? key, required this.paciente}) : super(key: key);

  @override
  _PerfilDesignState createState() => _PerfilDesignState();
}

class _PerfilDesignState extends State<PerfilDesign> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPasswordField = false;
  bool _isUpdating = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-llenar el campo de correo si existe
    if (widget.paciente.correoElectronico != null && 
        widget.paciente.correoElectronico!.isNotEmpty) {
      _correoController.text = widget.paciente.correoElectronico!;
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _mostrarSnackBar(BuildContext context, String mensaje, bool esError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _actualizarDatos(BuildContext context) async {
    // Comprobar si hay datos para actualizar
    if (_usuarioController.text.isEmpty && _correoController.text.isEmpty) {
      _mostrarSnackBar(context, "Ingresa un nuevo usuario o correo electrónico", true);
      return;
    }
    
    // Validar formato de correo electrónico si se ingresó uno
    if (_correoController.text.isNotEmpty && !_isValidEmail(_correoController.text)) {
      _mostrarSnackBar(context, "Por favor ingresa un correo electrónico válido", true);
      return;
    }
    
    // Si aún no se muestra el campo de contraseña, mostrarlo
    if (!_showPasswordField) {
      setState(() {
        _showPasswordField = true;
      });
      return;
    }
    
    // Validar la contraseña
    if (_passwordController.text.isEmpty) {
      _mostrarSnackBar(context, "Por favor ingresa tu contraseña actual", true);
      return;
    }

    // Mostrar indicador de carga
    setState(() {
      _isUpdating = true;
    });

    // Obtener el ViewModel
    final perfilViewModel = Provider.of<PerfilViewModel>(context, listen: false);

    // Llamar al método para actualizar datos
    bool actualizado = await perfilViewModel.actualizarDatos(
      contrasenaActual: _passwordController.text,
      nuevoUsuario: _usuarioController.text.isEmpty ? null : _usuarioController.text,
      nuevoCorreo: _correoController.text.isEmpty ? null : _correoController.text,
    );

    // Actualizar UI
    setState(() {
      _isUpdating = false;
      if (actualizado) {
        // Resetear controllers y estado si la actualización fue exitosa
        _passwordController.clear();
        _showPasswordField = false;
      }
    });

    // Mostrar mensaje de feedback
    if (perfilViewModel.errorMessage != null) {
      _mostrarSnackBar(context, perfilViewModel.errorMessage!, true);
    } else if (perfilViewModel.successMessage != null) {
      _mostrarSnackBar(context, perfilViewModel.successMessage!, false);
    }

    // Limpiar mensajes para evitar duplicados
    perfilViewModel.limpiarMensajes();
  }

  bool _isValidEmail(String email) {
    // Expresión regular simple para validar correo electrónico
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF1565C0), // Azul profundo
        title: const Text(
          'Perfil del Paciente',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar con efecto
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF1565C0),
                  child: Text(
                    widget.paciente.nombreUsuario[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Nombre y edad
              Text(
                widget.paciente.nombreUsuario,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                '${widget.paciente.edad} años',
                style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              // Tarjeta con información personal estilizada
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 6,
                shadowColor: Colors.black38,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Nombre Completo', '${widget.paciente.nombre} ${widget.paciente.primerApellido} ${widget.paciente.segundoApellido ?? ''}'),
                      _buildInfoRow(Icons.wc, 'Género', widget.paciente.genero),
                      _buildInfoRow(Icons.favorite, 'Estado Civil', widget.paciente.estadoCivil ?? 'No disponible'),
                      _buildInfoRow(Icons.school, 'Escolaridad', widget.paciente.escolaridad ?? 'No disponible'),
                      _buildInfoRow(Icons.work, 'Ocupación', widget.paciente.ocupacion.isNotEmpty ? widget.paciente.ocupacion : 'No disponible'),
                      if (widget.paciente.correoElectronico != null && widget.paciente.correoElectronico!.isNotEmpty)
                        _buildInfoRow(Icons.email, 'Correo Electrónico', widget.paciente.correoElectronico!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildStatusIndicator(widget.paciente.estadoPaciente),
              const SizedBox(height: 30),
              // Formulario para cambiar usuario y correo
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 6,
                shadowColor: Colors.black38,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text(
                            "Actualizar información",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 30, thickness: 1),
                      TextField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          labelText: 'Nuevo Usuario',
                          hintText: widget.paciente.nombreUsuario,
                          prefixIcon: Icon(Icons.person, color: Color(0xFF1565C0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icon(Icons.email, color: Color(0xFF1565C0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
                          ),
                        ),
                      ),
                      if (_showPasswordField) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Verificación de seguridad",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Para confirmar los cambios, ingresa tu contraseña actual:",
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña Actual',
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFF1565C0)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isUpdating ? null : () => _actualizarDatos(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                          ),
                          child: _isUpdating
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_showPasswordField ? Icons.check_circle : Icons.edit),
                                    SizedBox(width: 8),
                                    Text(
                                      _showPasswordField ? 'Confirmar Cambios' : 'Actualizar Información',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_showPasswordField) ...[
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showPasswordField = false;
                              _passwordController.clear();
                            });
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1565C0)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String estadoPaciente) {
    Color borderColor = estadoPaciente.toLowerCase() == 'activo' ? Colors.green : Colors.red;
    String statusText = estadoPaciente.toLowerCase() == 'activo' ? 'Activo' : 'Inactivo';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: borderColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}