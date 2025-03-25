import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../viewmodels/perfil_viewmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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

  // Nuevos controladores para la información personal
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _primerApellidoController = TextEditingController();
  final TextEditingController _segundoApellidoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _ocupacionController = TextEditingController();
  String? _generoSeleccionado;
  String? _estadoCivilSeleccionado;
  String? _escolaridadSeleccionada;
  bool _editandoInfo = false;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    if (widget.paciente.correoElectronico.isNotEmpty) {
      _correoController.text = widget.paciente.correoElectronico;
    }
  }

  void _inicializarControladores() {
    _nombreController.text = widget.paciente.nombre;
    _primerApellidoController.text = widget.paciente.primerApellido;
    _segundoApellidoController.text = widget.paciente.segundoApellido ?? '';
    _edadController.text = widget.paciente.edad.toString();
    _ocupacionController.text = widget.paciente.ocupacion;
    _generoSeleccionado = widget.paciente.genero;
    _estadoCivilSeleccionado = widget.paciente.estadoCivil;
    _escolaridadSeleccionada = widget.paciente.escolaridad;
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _edadController.dispose();
    _ocupacionController.dispose();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _editandoInfo ? Icons.save : Icons.edit,
                    color: Color(0xFF1565C0),
                  ),
                  onPressed: () {
                    if (_editandoInfo) {
                      _guardarCambios();
                    }
                    setState(() {
                      _editandoInfo = !_editandoInfo;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildEditableInfoRow(
              'Nombre',
              _nombreController,
              Icons.person_outline,
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildEditableInfoRow(
              'Primer Apellido',
              _primerApellidoController,
              Icons.person_outline,
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildEditableInfoRow(
              'Segundo Apellido',
              _segundoApellidoController,
              Icons.person_outline,
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildEditableInfoRow(
              'Edad',
              _edadController,
              Icons.calendar_today,
              enabled: _editandoInfo,
              keyboardType: TextInputType.number,
            ),
            _divider(),
            _buildDropdownRow(
              label: 'Género',
              value: _generoSeleccionado,
              icon: Icons.wc,
              items: const ['masculino', 'femenino'],
              onChanged: (String? value) {
                if (_editandoInfo) {
                  setState(() => _generoSeleccionado = value);
                }
              },
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildDropdownRow(
              label: 'Estado Civil',
              value: _estadoCivilSeleccionado,
              icon: Icons.favorite_border,
              items: const [
                'soltero',
                'casado',
                'divorciado',
                'viudo',
                'union_libre',
                'separado'
              ],
              onChanged: (String? value) {
                if (_editandoInfo) {
                  setState(() => _estadoCivilSeleccionado = value);
                }
              },
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildDropdownRow(
              label: 'Escolaridad',
              value: _escolaridadSeleccionada,
              icon: Icons.school_outlined,
              items: const [
                'primaria',
                'secundaria',
                'preparatoria',
                'licenciatura',
                'maestria',
                'doctorado',
                'otro'
              ],
              onChanged: (String? value) {
                if (_editandoInfo) {
                  setState(() => _escolaridadSeleccionada = value);
                }
              },
              enabled: _editandoInfo,
            ),
            _divider(),
            _buildDropdownRow(
              label: 'Ocupación',
              value: _ocupacionController.text,
              icon: Icons.work_outline,
              items: const [
                'empleado',
                'freelance',
                'autonomo',
                'empleador',
                'desempleado',
                'estudiante',
                'jubilado',
                'pensionado',
                'otro'
              ],
              onChanged: (String? value) {
                if (_editandoInfo) {
                  setState(() => _ocupacionController.text = value ?? '');
                }
              },
              enabled: _editandoInfo,
            ),
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

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
            child: Icon(icon, color: Color(0xFF1565C0), size: 22),
          ),
          SizedBox(width: 15),
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        controller.text,
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

  String _formatearValorEnum(String valor) {
    // Convertir 'union_libre' a 'Unión Libre', etc.
    return valor
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = false,
  }) {
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
            child: Icon(icon, color: Color(0xFF1565C0), size: 22),
          ),
          SizedBox(width: 15),
          Expanded(
            child: enabled
                ? DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(_formatearValorEnum(item)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        value != null ? _formatearValorEnum(value) : 'No especificado',
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

  Future<void> _guardarCambios() async {
    try {
      // Validar datos
      int? edad = int.tryParse(_edadController.text);
      if (edad == null || edad <= 0 || edad >= 120) {
        _mostrarSnackBar(context, "La edad debe ser un número válido entre 1 y 119", true);
        return;
      }

      // Mostrar diálogo de confirmación con contraseña
      bool? confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => _buildConfirmacionDialog(),
      );

      if (confirmado == true) {
        // Actualizar datos usando el ViewModel
        final perfilViewModel = Provider.of<PerfilViewModel>(context, listen: false);
        bool actualizado = await perfilViewModel.actualizarInformacionPersonal(
          nombre: _nombreController.text,
          primerApellido: _primerApellidoController.text,
          segundoApellido: _segundoApellidoController.text,
          edad: edad,
          genero: _generoSeleccionado!,
          estadoCivil: _estadoCivilSeleccionado,
          escolaridad: _escolaridadSeleccionada,
          ocupacion: _ocupacionController.text,
          contrasenaActual: _passwordController.text,
        );

        if (actualizado) {
          setState(() => _editandoInfo = false);
          _mostrarSnackBar(context, "Información actualizada correctamente", false);
        } else {
          _mostrarSnackBar(context, "Error al actualizar la información", true);
        }
      }
    } catch (e) {
      _mostrarSnackBar(context, "Error al guardar los cambios", true);
    }
  }

  Widget _buildConfirmacionDialog() {
    return AlertDialog(
      title: Text('Confirmar cambios'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Por favor, ingresa tu contraseña para confirmar los cambios'),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirmar'),
        ),
      ],
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