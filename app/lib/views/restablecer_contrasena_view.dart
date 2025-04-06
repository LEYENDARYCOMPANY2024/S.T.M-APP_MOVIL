import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/restablecer_contrasena_viewmodel.dart';

class RestablecerContrasenaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestablecerContrasenaViewModel(),
      child: _RestablecerContrasenaContent(),
    );
  }
}

class _RestablecerContrasenaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RestablecerContrasenaViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono
              Container(
                height: 100,
                margin: EdgeInsets.only(bottom: 30, top: 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  _getIconForState(viewModel),
                  size: 60,
                  color: Colors.white,
                ),
              ),

              // Título
              Text(
                _getTitleForState(viewModel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 20),

              // Contenido según el estado
              if (!viewModel.usuarioEncontrado) ...[
                _buildBuscarUsuarioContent(viewModel),
              ] else if (!viewModel.codigoEnviado) ...[
                _buildUsuarioEncontradoContent(viewModel),
              ] else if (!viewModel.codigoValidado) ...[
                _buildIngresarCodigoContent(viewModel),
              ] else ...[
                _buildNuevaContrasenaContent(viewModel),
              ],

              SizedBox(height: 30),

              if (viewModel.mensajeError.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    viewModel.mensajeError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 14,
                    ),
                  ),
                ),

              // Botón de acción
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
                onPressed: viewModel.cargando
                    ? null
                    : () async {
                        if (!viewModel.usuarioEncontrado) {
                          final encontrado = await viewModel.buscarUsuario();
                          if (!encontrado) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(viewModel.mensajeError)),
                            );
                          }
                        } else if (!viewModel.codigoEnviado) {
                          final enviado = await viewModel.enviarCodigoRestablecimiento();
                          if (enviado) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Código enviado correctamente')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(viewModel.mensajeError)),
                            );
                          }
                        } else if (!viewModel.codigoValidado) {
                          final validado = await viewModel.validarCodigo();
                          if (!validado) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(viewModel.mensajeError)),
                            );
                          }
                        } else {
                          final restablecido = await viewModel.restablecerContrasena();
                          if (restablecido) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Contraseña restablecida correctamente')),
                            );
                            Navigator.pop(context); // Volver al login
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(viewModel.mensajeError)),
                            );
                          }
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (viewModel.cargando)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                        ),
                      )
                    else ...[
                      Text(
                        _getButtonTextForState(viewModel),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(_getButtonIconForState(viewModel), size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForState(RestablecerContrasenaViewModel viewModel) {
    if (viewModel.codigoValidado) return Icons.lock_open;
    if (viewModel.codigoEnviado) return Icons.code;
    if (viewModel.usuarioEncontrado) return Icons.person_outline;
    return Icons.lock_reset;
  }

  String _getTitleForState(RestablecerContrasenaViewModel viewModel) {
    if (viewModel.codigoValidado) return 'Nueva Contraseña';
    if (viewModel.codigoEnviado) return 'Ingresa el Código';
    if (viewModel.usuarioEncontrado) return 'Usuario Encontrado';
    return 'Restablecer Contraseña';
  }

  String _getButtonTextForState(RestablecerContrasenaViewModel viewModel) {
    if (viewModel.codigoValidado) return 'RESTABLECER CONTRASEÑA';
    if (viewModel.codigoEnviado) return 'VERIFICAR CÓDIGO';
    if (viewModel.usuarioEncontrado) return 'ENVIAR CÓDIGO';
    return 'BUSCAR USUARIO';
  }

  IconData _getButtonIconForState(RestablecerContrasenaViewModel viewModel) {
    if (viewModel.codigoValidado) return Icons.check_circle_outline;
    if (viewModel.codigoEnviado) return Icons.verified_user;
    if (viewModel.usuarioEncontrado) return Icons.send_outlined;
    return Icons.search;
  }

  Widget _buildBuscarUsuarioContent(RestablecerContrasenaViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Ingresa tu correo electrónico o nombre de usuario para restablecer tu contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: viewModel.usuarioCorreoController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
              hintText: 'Correo electrónico o usuario',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsuarioEncontradoContent(RestablecerContrasenaViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Se enviará un código de verificación al correo electrónico asociado a la cuenta:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 20),
        Text(
          viewModel.pacienteEncontrado?['correo_electronico_p'] ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIngresarCodigoContent(RestablecerContrasenaViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Hemos enviado un código de verificación a tu correo electrónico. Por favor, ingrésalo a continuación:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 40),
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: viewModel.codigoController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              border: InputBorder.none,
              hintText: '000000',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 24,
                letterSpacing: 8,
              ),
              counterText: '',
            ),
          ),
        ),
        SizedBox(height: 20),
        _ReenviarCodigoButton(viewModel: viewModel),
      ],
    );
  }

  Widget _buildNuevaContrasenaContent(RestablecerContrasenaViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Ingresa tu nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: viewModel.nuevaContrasenaController,
            obscureText: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
              hintText: 'Nueva contraseña',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: viewModel.confirmarContrasenaController,
            obscureText: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
              hintText: 'Confirmar contraseña',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReenviarCodigoButton extends StatelessWidget {
  final RestablecerContrasenaViewModel viewModel;

  const _ReenviarCodigoButton({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final enviado = await viewModel.enviarCodigoRestablecimiento();
        if (enviado) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nuevo código enviado')),
          );
        }
      },
      child: Text(
        'Enviar nuevo código',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
} 