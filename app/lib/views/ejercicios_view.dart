import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../viewmodels/ejercicios_viewmodel.dart';
import '../models/ejercicio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EjerciciosView extends StatefulWidget {
  const EjerciciosView({Key? key}) : super(key: key);

  @override
  State<EjerciciosView> createState() => _EjerciciosViewState();
}

class _EjerciciosViewState extends State<EjerciciosView> {
  final Map<String, ChewieController> _videoControllers = {};
  final Map<String, bool> _isInitializing = {};  // Nuevo mapa para controlar el estado de inicialización
  
  @override
  void initState() {
    super.initState();
    // Cargar los datos automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EjerciciosViewModel>(context, listen: false);
      viewModel.cargarNivelesYEjercicios();
    });
  }

  @override
  void dispose() {
    _disposeAllVideoControllers();
    super.dispose();
  }

  void _disposeAllVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _isInitializing.clear();  // Limpiar el mapa de estados
  }

  Future<void> _initializeVideoController(Ejercicio ejercicio) async {
    if (ejercicio.videoUrl == null || 
        ejercicio.videoUrl!.isEmpty || 
        _videoControllers.containsKey(ejercicio.id.toString()) ||
        _isInitializing[ejercicio.id.toString()] == true) return;

    try {
      _isInitializing[ejercicio.id.toString()] = true;
      if (mounted) setState(() {});

      String videoUrl = ejercicio.videoUrl!;
      
      if (kIsWeb) {
        if (!videoUrl.startsWith('https://')) {
          videoUrl = videoUrl.replaceAll('http://', 'https://');
        }
        
        if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Los videos de YouTube no son soportados directamente en web. Por favor, usa la app móvil.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          _isInitializing[ejercicio.id.toString()] = false;
          if (mounted) setState(() {});
          return;
        }
      }

      final videoPlayerController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Intentar inicializar con timeout
      bool initialized = false;
      try {
        await Future.wait([
          videoPlayerController.initialize(),
        ]).timeout(Duration(seconds: 15)); // Aumentamos el timeout a 15 segundos
        initialized = true;
      } catch (e) {
        print('⚠️ Error al inicializar video: $e');
        // Solo mostramos el mensaje si el error no es por disposición del widget
        if (mounted && e is! StateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('No se pudo cargar el video. Intente nuevamente.'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () => _retryLoadVideo(ejercicio),
              ),
            ),
          );
        }
      }

      if (!mounted) return;

      if (!initialized) {
        videoPlayerController.dispose();
        _isInitializing[ejercicio.id.toString()] = false;
        if (mounted) setState(() {});
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        allowPlaybackSpeedChanging: true,
        placeholder: Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 30),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error al reproducir el video',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _retryLoadVideo(ejercicio),
                  icon: Icon(Icons.refresh),
                  label: Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          );
        },
      );
      
      _videoControllers[ejercicio.id.toString()] = chewieController;
      _isInitializing[ejercicio.id.toString()] = false;
      
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Error al inicializar el reproductor de video: $e');
      _isInitializing[ejercicio.id.toString()] = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _retryLoadVideo(Ejercicio ejercicio) async {
    final String ejercicioId = ejercicio.id.toString();
    if (_videoControllers.containsKey(ejercicioId)) {
      _videoControllers[ejercicioId]?.dispose();
      _videoControllers.remove(ejercicioId);
    }
    _isInitializing[ejercicioId] = false;
    if (mounted) setState(() {});
    await _initializeVideoController(ejercicio);
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosViewModel = Provider.of<EjerciciosViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          "Ejercicios",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nota informativa sobre desbloqueo de ejercicios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Tienes que hacer los ejercicios en orden. Los niveles se desbloquearán cuando tu terapeuta lo indique.",
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Estado de carga
            if (ejerciciosViewModel.cargando)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              
            // Mensaje de error
            if (ejerciciosViewModel.error.isNotEmpty)
              Center(
                child: Text(
                  ejerciciosViewModel.error,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              
            // Lista de niveles
            if (!ejerciciosViewModel.cargando && ejerciciosViewModel.error.isEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: ejerciciosViewModel.niveles.length,
                  itemBuilder: (context, index) {
                    final nivel = ejerciciosViewModel.niveles[index];
                    final desbloqueado = nivel.estado == 'desbloqueado';
                    
                    return Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          // Cabecera del nivel (siempre visible)
                          ListTile(
                            leading: Icon(
                              Icons.fitness_center,
                              color: Colors.blue[300],
                            ),
                            title: Text(
                              nivel.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              nivel.descripcion ?? 'Ejercicios de este nivel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icono de estado
                                Icon(
                                  desbloqueado 
                                    ? Icons.lock_open 
                                    : Icons.lock,
                                  color: desbloqueado 
                                    ? Colors.green[300] 
                                    : Colors.red[300],
                                ),
                                const SizedBox(width: 8),
                                // Flecha desplegable (solo activa si está desbloqueado)
                                IconButton(
                                  icon: Icon(
                                    nivel.expandido
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                  onPressed: desbloqueado
                                      ? () {
                                          ejerciciosViewModel.toggleExpansion(index);
                                          
                                          // Inicializar los controladores de video si el nivel se expande
                                          if (!nivel.expandido && desbloqueado) {
                                            for (var ejercicio in nivel.ejercicios) {
                                              if (ejercicio.videoUrl != null && ejercicio.videoUrl!.isNotEmpty) {
                                                _initializeVideoController(ejercicio);
                                              }
                                            }
                                          }
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          
                          // Contenido desplegable (ejercicios)
                          if (nivel.expandido && desbloqueado)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: nivel.ejercicios.length,
                              itemBuilder: (context, i) {
                                final ejercicio = nivel.ejercicios[i];
                                return _buildEjercicioItem(ejercicio);
                              },
                            ),
                          
                          // Mensaje cuando el nivel está bloqueado
                          if (nivel.expandido && !desbloqueado)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Este nivel está bloqueado. Contacta a tu terapeuta para desbloquearlo.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Historial Clinico"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/historial-clinico');
          }
        },
      ),
    );
  }
  
  // Widget para mostrar un ejercicio individual con reproductor de video
  Widget _buildEjercicioItem(Ejercicio ejercicio) {
    final bool tieneVideo = ejercicio.videoUrl != null && ejercicio.videoUrl!.isNotEmpty;
    final String ejercicioId = ejercicio.id.toString();
    final bool isLoading = _isInitializing[ejercicioId] == true;
    
    if (tieneVideo && kIsWeb) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              ejercicio.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ejercicio.instrucciones,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            if (tieneVideo) ...[
              const SizedBox(height: 12),
              if (_videoControllers.containsKey(ejercicioId))
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Chewie(controller: _videoControllers[ejercicioId]!),
                  ),
                )
              else if (isLoading)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue[300]),
                        SizedBox(height: 8),
                        Text(
                          'Cargando video...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text("Ver video"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _initializeVideoController(ejercicio),
                  ),
                ),
            ],
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para una mejor experiencia con los videos, te recomendamos usar la aplicación móvil.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ejercicio.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ejercicio.instrucciones,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          if (tieneVideo) ...[
            const SizedBox(height: 12),
            if (_videoControllers.containsKey(ejercicioId))
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Chewie(controller: _videoControllers[ejercicioId]!),
                ),
              )
            else if (isLoading)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue[300]),
                      SizedBox(height: 8),
                      Text(
                        'Cargando video...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text("Ver video"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => _initializeVideoController(ejercicio),
                ),
              ),
          ],
        ],
      ),
    );
  }
}