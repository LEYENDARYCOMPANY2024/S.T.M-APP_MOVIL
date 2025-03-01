import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/register_view.dart'; // Asegúrate de importar RegisterView
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart'; // Importar RegisterViewModel
import 'services/auth_services.dart';
import 'views/home_view.dart'; // Importar HomeView

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(AuthService())), // Proveedor para Login
        ChangeNotifierProvider(create: (_) => RegisterViewModel(AuthService())), // Proveedor para Register
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Ruta inicial
        routes: {
          '/login': (context) => LoginView(), // Ruta de login
          '/register': (context) => const RegisterView(), // Ruta de registro
          '/home': (context) => HomeView(), // Nueva ruta para la pantalla principal
        },
      ),
    );
  }
}
