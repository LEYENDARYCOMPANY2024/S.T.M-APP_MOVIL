import 'package:flutter/material.dart';
import '../models/paciente.dart';

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
                      TextField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          labelText: 'Nuevo Usuario',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF1565C0)),
                        ),
                      ),
                      if (_showPasswordField)
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña Actual',
                            prefixIcon: Icon(Icons.lock, color: Color(0xFF1565C0)),
                          ),
                        ),
                      TextField(
                        controller: _correoController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email, color: Color(0xFF1565C0)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showPasswordField = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
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