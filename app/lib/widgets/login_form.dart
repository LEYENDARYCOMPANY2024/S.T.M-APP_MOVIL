import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/register_view.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo o imagen
          Container(
            height: 100,
            margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Icon(
              Icons.directions_walk,
              size: 60,
              color: Colors.white,
            ),
          ),

          // Título
          Text(
            'Bienvenido a',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'S.M.M',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            'Sistema de Monitoreo de la Marcha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 40),

          // Campos de texto
          _buildTextField(
            controller: viewModel.usernameController,
            label: 'Usuario',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: viewModel.passwordController,
            label: 'Contraseña',
            isPassword: true,
            icon: Icons.lock_outline,
          ),

          // Link para recuperar contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Implementar recuperación de contraseña
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Botón de inicio de sesión
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[800],
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              bool success = await viewModel.login();

              if (success) {
                // Redirigir solo si el login es exitoso
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Usuario o contraseña incorrectos")),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),

          // Separador
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.white.withOpacity(0.5), thickness: 0.5),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'O',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.white.withOpacity(0.5), thickness: 0.5),
                ),
              ],
            ),
          ),

          // Botón de registro
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white, width: 1.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterView()),
              );
            },
            child: Text(
              'CREAR CUENTA NUEVA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(Icons.visibility, color: Colors.white.withOpacity(0.7)),
                  onPressed: () {
                    // Implementar toggle para mostrar/ocultar contraseña
                  },
                )
              : null,
        ),
      ),
    );
  }
}
