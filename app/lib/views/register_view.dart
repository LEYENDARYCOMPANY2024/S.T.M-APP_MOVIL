import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final registerViewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Paciente")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: registerViewModel.codigoController,
              decoration: const InputDecoration(labelText: "Código de Paciente"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: registerViewModel.usuarioController,
              decoration: const InputDecoration(labelText: "Nombre de Usuario"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: registerViewModel.passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            registerViewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => registerViewModel.register(context),
                    child: const Text("Registrar"),
                  ),
          ],
        ),
      ),
    );
  }
}
