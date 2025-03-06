import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/splash_view.dart'; // Importar SplashView
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase directamente
  await Supabase.initialize(
    url: "https://hxjmzijhcmhfcrjcptge.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4am16aWpoY21oZmNyamNwdGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwODMxODgsImV4cCI6MjA1NTY1OTE4OH0.fZ1QaYkFTfJTdupOUkV7V9a7kIIVHCt_XusnNWxkyqw",
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
        ChangeNotifierProvider(create: (_) => LoginViewModel(authService)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'S.M.M - Sistema de Monitoreo de la Marcha',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/', // Ruta inicial apunta al splash
        routes: {
          '/': (context) => const SplashView(), // Ruta de splash
          '/login': (context) => LoginView(), // Ruta de login
          '/register': (context) => const RegisterView(), // Ruta de registro
          '/home': (context) => const HomeView(), // Ruta para la pantalla principal
        },
      ),
    );
  }
}