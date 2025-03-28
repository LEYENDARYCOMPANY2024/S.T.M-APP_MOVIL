import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/splash_view.dart';
import 'views/perfil_view.dart';  // Importa el PerfilView
import 'views/ejercicios_view.dart'; // Importa la nueva vista de ejercicios
import 'views/sesion_view.dart'; // Importa la vista de sesión
import 'views/historial_clinico_view.dart'; // Importa la vista del historial clínico
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart'; // Importar el HomeViewModel
import 'viewmodels/perfil_viewmodel.dart'; // Importa el PerfilViewModel
import 'viewmodels/ejercicios_viewmodel.dart'; // Importa el EjerciciosViewModel
import 'viewmodels/sesiones_viewmodels.dart'; // Importa el SesionViewModel
import 'services/ejercicios_services.dart'; // Importa el servicio de ejercicios
import 'services/auth_services.dart';
import 'viewmodels/historial_clinico_viewmodel.dart';
import 'services/historial_clinico_service.dart';
import 'viewmodels/detalle_sesion_viewmodel.dart';
import 'views/detalle_sesion_view.dart';
import 'views/chat_view.dart'; // Importa la vista de chat
import 'viewmodels/chat_viewmodel.dart'; // Importa el ViewModel de chat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: "assets/.env");

  // Inicializar Supabase con variables seguras
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
        ChangeNotifierProvider(create: (_) => EjerciciosViewModel(EjerciciosService(Supabase.instance.client, AuthService()),),), // Proveedor del EjerciciosViewModel
        ChangeNotifierProvider(create: (_) => SesionesViewModel()), // Proveedor del SesionViewModel
        ChangeNotifierProvider(create: (_) => HistorialClinicoViewModel(HistorialClinicoService(Supabase.instance.client, authService),authService,),),
        ChangeNotifierProvider(create: (_) => DetalleSesionViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()), // Proveedor del ChatViewModel
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
          '/historial-clinico': (context) => const HistorialClinicoReadOnlyView(), // Nueva ruta para historial clínico
          '/detalle-sesion': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return DetalleSesionView(sesion: args['sesion']);
          },
          '/chat': (context) => ChatView(), // Ruta para la vista de chat
        },
      ),
    );
  }
}
