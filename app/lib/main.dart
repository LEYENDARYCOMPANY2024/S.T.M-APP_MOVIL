import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/splash_view.dart';
import 'views/perfil_view.dart';  // Importa el PerfilView
import 'views/ejercicios_view.dart'; // Importa la nueva vista de ejercicios
import 'views/sesion_view.dart'; // Importa la vista de sesión
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart'; // Importar el HomeViewModel
import 'viewmodels/perfil_viewmodel.dart'; // Importa el PerfilViewModel
import 'viewmodels/ejercicios_viewmodel.dart'; // Importa el EjerciciosViewModel
import 'viewmodels/sesiones_viewmodels.dart'; // Importa el SesionViewModel
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase directamente
  await Supabase.initialize(
    url: "https://hxjmzijhcmhfcrjcptge.supabase.co", // Coloca aquí tu URL de Supabase
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4am16aWpoY21oZmNyamNwdGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwODMxODgsImV4cCI6MjA1NTY1OTE4OH0.fZ1QaYkFTfJTdupOUkV7V9a7kIIVHCt_XusnNWxkyqw", // Coloca aquí tu Key de Supabase
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear una instancia única del AuthService
    final authService = AuthService();
    
    return MultiProvider(
      providers: [
        // Proveedores de ChangeNotifier para la gestión de estados
        ChangeNotifierProvider(create: (_) => LoginViewModel(authService)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authService)),
        ChangeNotifierProvider(create: (_) => HomeViewModel()), // Proveedor del HomeViewModel
        ChangeNotifierProvider(create: (_) => PerfilViewModel()), // Proveedor del PerfilViewModel
        ChangeNotifierProvider(create: (_) => EjerciciosViewModel()), // Proveedor del EjerciciosViewModel
        ChangeNotifierProvider(create: (_) => SesionesViewModel()), // Proveedor del SesionViewModel
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'S.M.M - Sistema de Monitoreo de la Marcha',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/', // Ruta inicial apunta al Splash
        routes: {
          '/': (context) => const SplashView(), // Ruta de splash
          '/login': (context) => LoginView(), // Ruta de login
          '/register': (context) => const RegisterView(), // Ruta de registro
          '/home': (context) => const HomeView(), // Ruta para la pantalla principal
          '/perfil': (context) => const PerfilView(), // Ruta para el perfil
          '/ejercicios': (context) => const EjerciciosView(), // Nueva ruta para ejercicios
          '/sesion': (context) => const SesionesView(), // Ruta para la nueva vista de sesión
        },
      ),
    );
  }
}
