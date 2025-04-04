import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../viewmodels/perfil_viewmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../viewmodels/login_viewmodel.dart';

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
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            // Header con el perfil
            Container(
              padding: EdgeInsets.only(top: 60, bottom: 30),
              color: Colors.blue[700],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.paciente.nombreUsuario[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.paciente.nombreUsuario,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Paciente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoCard(),
                    SizedBox(height: 16),
                    _buildStatusCard(),
                    SizedBox(height: 16),
                    _buildCodeCard(),
                    SizedBox(height: 16),
                    _buildUpdateCard(),
                    SizedBox(height: 16),
                    _buildLogoutButton(context),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue[700], size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Información Personal",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[700]!.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _editandoInfo ? Icons.save : Icons.edit,
                      color: Colors.blue[700],
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
      color: Colors.grey[300],
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
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[700]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[700]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[600],
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

  String _formatearValorEnum(String? valor) {
    // Si el valor es null o vacío, retornar un valor por defecto
    if (valor == null || valor.isEmpty) {
      return 'No especificado';
    }

    // Convertir 'union_libre' a 'Unión Libre', etc.
    return valor
        .split('_')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1)
            : '')
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
    final bool valueInItems = value != null && items.contains(value);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[700]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: enabled
                ? DropdownButtonFormField<String>(
                    value: valueInItems ? value : null,
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[700]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          _formatearValorEnum(item),
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    hint: Text(
                      'Seleccione una opción',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        valueInItems ? _formatearValorEnum(value) : 'No especificado',
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
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.check_circle : Icons.cancel_outlined,
                color: statusColor,
                size: 32,
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
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[700]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.lock_clock : Icons.qr_code,
                color: Colors.blue[700],
                size: 32,
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
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (isActive)
                    Text(
                      'El código se mostrará cuando termine tu tratamiento con el terapeuta',
                      style: TextStyle(
                        color: Colors.grey[700],
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[700]!.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: Colors.blue[700],
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
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue[700], size: 24),
                SizedBox(width: 10),
                Text(
                  "Actualizar Datos",
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _actualizarDatos(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
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
        color: Colors.blue[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Colors.blue[300],
          ),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () => onToggleVisibility(),
                )
              : null,
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
          await loginViewModel.logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.red,
                size: 28,
              ),
            ],
          ),
        ),
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
          // Mostrar mensaje específico según el tipo de error
          if (perfilViewModel.errorType == PerfilErrorType.password) {
            _mostrarSnackBar(context, "Contraseña incorrecta", true);
          } else if (perfilViewModel.errorType == PerfilErrorType.connection) {
            _mostrarSnackBar(context, "Error de conexión. Por favor, verifica tu conexión a internet", true);
          } else {
            _mostrarSnackBar(context, "Error al actualizar la información", true);
          }
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
}

// Custom painter for geometric pattern
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw triangles
    for (int i = 0; i < 10; i++) {
      final path = Path();
      final x = size.width * (i / 10);
      final y = size.height * 0.2;
      
      path.moveTo(x, y);
      path.lineTo(x + 50, y + 50);
      path.lineTo(x, y + 100);
      path.close();
      
      canvas.drawPath(path, paint);
    }

    // Draw circles
    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8);
      final y = size.height * 0.6;
      
      canvas.drawCircle(
        Offset(x, y),
        20,
        paint,
      );
    }

    // Draw squares
    for (int i = 0; i < 6; i++) {
      final x = size.width * (i / 6);
      final y = size.height * 0.8;
      
      final rect = Rect.fromLTWH(x, y, 40, 40);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}