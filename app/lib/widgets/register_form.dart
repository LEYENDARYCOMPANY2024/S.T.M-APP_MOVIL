import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_viewmodel.dart';
import './terminos_condiciones_dialog.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isPasswordVisible = false;
  bool _termsAccepted = false;
  String? _codigoError;
  String? _usuarioError;

  @override
  Widget build(BuildContext context) {
    final registerViewModel = Provider.of<RegisterViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 70, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "Crear Cuenta Nueva",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Por favor, complete los siguientes campos para registrarse como paciente en el sistema",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
              ),
            ],
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildTextField(
                  controller: registerViewModel.codigoController,
                  label: "Código de Paciente",
                  icon: Icons.badge_outlined,
                  hint: "Ingrese su código único de paciente",
                  errorText: _codigoError,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: registerViewModel.usuarioController,
                  label: "Nombre de Usuario",
                  icon: Icons.person_outline,
                  hint: "Elija un nombre de usuario",
                  errorText: _usuarioError,
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      final validationResult = await registerViewModel.validateUsername();
                      setState(() {
                        _usuarioError = validationResult['isValid'] ? null : validationResult['message'];
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: registerViewModel.passwordController,
                  label: "Contraseña",
                  icon: Icons.lock_outline,
                  hint: "Cree una contraseña segura",
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "La contraseña debe tener al menos 8 caracteres",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const TerminosCondicionesDialog(),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'He leído y aceptado los ',
                            children: [
                              TextSpan(
                                text: 'términos y condiciones',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        registerViewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _termsAccepted 
                    ? () async {
                        final validationResult = await registerViewModel.validateCodigo();
                        setState(() {
                            _codigoError = validationResult['isValid'] 
                                ? null 
                                : validationResult['message'];
                        });
                        if (validationResult['isValid']) {
                            registerViewModel.register(context);
                        }
                    } 
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'COMPLETAR REGISTRO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_outline, size: 18),
                  ],
                ),
              ),
        const SizedBox(height: 20),
        Text(
          "Al registrarse, acepta nuestros términos y política de privacidad",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(String strength) {
    if (strength.isEmpty) return const SizedBox.shrink();

    Color color;
    String message;
    
    switch (strength.toLowerCase()) {
      case 'baja':
        color = Colors.red;
        message = 'Débil';
        break;
      case 'media':
        color = Colors.orange;
        message = 'Media';
        break;
      case 'alta':
        color = Colors.green;
        message = 'Fuerte';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: strength == 'baja' ? 0.33 : 
                         strength == 'media' ? 0.66 : 1.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    final viewModel = Provider.of<RegisterViewModel>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            onChanged: (value) {
              if (isPassword) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!mounted) return;
                  viewModel.validatePasswordStrength(value);
                });
              } else if (onChanged != null) {
                onChanged(value);
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: errorText != null ? Colors.red : Colors.blue[800]),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (isPassword)
          Consumer<RegisterViewModel>(
            builder: (context, viewModel, _) => 
              viewModel.passwordStrength.isNotEmpty
                ? _buildPasswordStrengthIndicator(viewModel.passwordStrength)
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
