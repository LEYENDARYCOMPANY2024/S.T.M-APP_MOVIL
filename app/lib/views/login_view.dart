// login_view.dart
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: LoginForm(), // Aquí usamos el widget LoginForm que contiene el diseño
      ),
    );
  }
}
