import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Pequeño retraso para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));
    
    final authService = AuthService();
    final bool isAuthenticated = await authService.verifyToken();
    
    if (mounted) {
      if (isAuthenticated) {
        // Si hay token válido, ir a Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Si no hay token o no es válido, ir a Login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o imagen
            Container(
              height: 120,
              width: 120,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.directions_walk,
                size: 80,
                color: Colors.white,
              ),
            ),
            
            // Título de la app
            const Text(
              'S.M.M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Sistema de Monitoreo de la Marcha',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}