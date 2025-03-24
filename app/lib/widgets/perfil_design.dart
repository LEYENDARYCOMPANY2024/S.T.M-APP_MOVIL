import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../viewmodels/perfil_viewmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.paciente.correoElectronico.isNotEmpty) {
      _correoController.text = widget.paciente.correoElectronico;
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
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    // Mantener la misma funcionalidad, solo cambió el diseño visual
    if (_usuarioController.text.isEmpty && _correoController.text.isEmpty) {
      _mostrarSnackBar(context, "Ingresa un nuevo usuario o correo electrónico", true);
      return;
    }

    if (_correoController.text.isNotEmpty && !_isValidEmail(_correoController.text)) {
      _mostrarSnackBar(context, "Por favor ingresa un correo electrónico válido", true);
      return;
    }

    if (!_showPasswordField) {
      if (!mounted) return;
      setState(() {
        _showPasswordField = true;
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      _mostrarSnackBar(context, "Por favor ingresa tu contraseña actual", true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isUpdating = true;
    });

    final perfilViewModel = Provider.of<PerfilViewModel>(context, listen: false);
    bool actualizado = await perfilViewModel.actualizarDatos(
      contrasenaActual: _passwordController.text,
      nuevoUsuario: _usuarioController.text.isEmpty ? null : _usuarioController.text,
      nuevoCorreo: _correoController.text.isEmpty ? null : _correoController.text,
    );

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (actualizado) {
        _passwordController.clear();
        _showPasswordField = false;
      }
    });

    if (actualizado) {
      _mostrarSnackBar(context, "Datos actualizados correctamente", false);
    } else if (perfilViewModel.errorMessage != null) {
      _mostrarSnackBar(context, perfilViewModel.errorMessage!, true);
    }

    if (!mounted) return;
    perfilViewModel.limpiarMensajes();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1565C0);
    final Color accentColor = Color(0xFF42A5F5);
    final Color surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Header gradient background
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, accentColor],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  // Profile header with avatar
                  _buildProfileHeader(),
                  
                  // Content cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        _buildSectionTitle('Información Personal'),
                        SizedBox(height: 10),
                        _buildInfoCard(),
                        SizedBox(height: 20),
                        _buildStatusCard(),
                        SizedBox(height: 20),
                        _buildCodeCard(),
                        SizedBox(height: 20),
                        _buildSectionTitle('Actualizar Datos'),
                        SizedBox(height: 10),
                        _buildUpdateCard(),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar with decorative elements
        Stack(
          alignment: Alignment.center,
          children: [
            // Halo effect behind avatar
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            
            // Avatar
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFF1565C0),
                child: Text(
                  widget.paciente.nombreUsuario[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 40, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Status indicator dot
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: widget.paciente.estadoPaciente.toLowerCase() == 'activo' 
                      ? Colors.green 
                      : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 5),
        
        // Name and age
        Text(
          widget.paciente.nombreUsuario,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black26,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        
        Text(
          '${widget.paciente.edad} años',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person_outline, 'Nombre', widget.paciente.nombre),
            _divider(),
            _buildInfoRow(Icons.wc, 'Género', widget.paciente.genero),
            _divider(),
            _buildInfoRow(Icons.favorite_border, 'Estado Civil', widget.paciente.estadoCivil),
            _divider(),
            _buildInfoRow(Icons.school_outlined, 'Escolaridad', widget.paciente.escolaridad),
            _divider(),
            _buildInfoRow(Icons.work_outline, 'Ocupación', widget.paciente.ocupacion),
            _divider(),
            _buildInfoRow(Icons.email_outlined, 'Correo', widget.paciente.correoElectronico),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
      height: 20,
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              color: Color(0xFF1565C0),
              size: 22,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value != null && value.isNotEmpty ? value : "No disponible",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    bool isActive = widget.paciente.estadoPaciente.toLowerCase() == 'activo';
    Color statusColor = isActive ? Colors.green.shade600 : Colors.red.shade600;
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.check_circle : Icons.cancel_outlined,
                color: statusColor,
                size: 30,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado del Paciente',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor,
                  width: 1,
                ),
              ),
              child: Text(
                isActive ? 'En Tratamiento' : 'Sin Atención',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard() {
    bool isActive = widget.paciente.estadoPaciente.toLowerCase() == 'activo';
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.lock_clock : Icons.qr_code,
                color: Color(0xFF1565C0),
                size: 30,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código de Paciente',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (isActive)
                    Text(
                      'El código se mostrará cuando termine tu tratamiento con el terapeuta',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.paciente.codigo,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: Color(0xFF1565C0),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.paciente.codigo));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Código copiado al portapapeles'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateCard() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _usuarioController,
              icon: Icons.person_outline,
              label: 'Nuevo Usuario',
              hint: 'Ingresa un nuevo nombre de usuario',
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _correoController,
              icon: Icons.email_outlined,
              label: 'Nuevo Correo Electrónico',
              hint: 'Ingresa un nuevo correo electrónico',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            if (_showPasswordField)
              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                label: 'Contraseña Actual',
                hint: 'Ingresa tu contraseña actual',
                obscure: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: _isUpdating
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _actualizarDatos(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _showPasswordField ? 'Confirmar Cambios' : 'Actualizar Datos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Function? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Color(0xFF1565C0),
          ),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => onToggleVisibility(),
                )
              : null,
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}