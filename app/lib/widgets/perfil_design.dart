import 'package:flutter/material.dart';
import '../models/paciente.dart';

class PerfilDesign extends StatelessWidget {
  final Paciente paciente;

  const PerfilDesign({Key? key, required this.paciente}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD), // Fondo suave (color azul claro en hex)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF1976D2), // Azul fuerte (hex)
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              // Nombre de usuario y Edad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2), // Azul fuerte (hex)
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      paciente.nombreUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${paciente.edad} años',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Nombre completo
              Text(
                '${paciente.nombre} ${paciente.primerApellido} ${paciente.segundoApellido ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                color: Color(0xFF1976D2), // Azul para el divisor (hex)
                thickness: 2,
                indent: 50,
                endIndent: 50,
              ),
              const SizedBox(height: 20),
              // Datos adicionales
              _buildInfoRow('Género', paciente.genero),
              const SizedBox(height: 20),
              _buildInfoRow(
                'Estado Civil',
                paciente.estadoCivil ?? 'No disponible',
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                'Escolaridad',
                paciente.escolaridad ?? 'No disponible',
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                'Ocupación',
                paciente.ocupacion.isNotEmpty ? paciente.ocupacion : 'No disponible',
              ),
              const SizedBox(height: 20),
              // Estado del paciente (Activo/Inactivo)
              _buildStatusIndicator(paciente.estadoPaciente),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir una fila con el texto y el valor
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2), // Azul fuerte (hex)
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Método para mostrar el estado activo/inactivo con un contorno de color
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
