import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../viewmodels/ejercicios_viewmodel.dart';
import '../models/ejercicio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';  // Importación para DeviceOrientation
import 'dart:io';
import 'dart:async';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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

  // Nuevo método para limpiar videos no visibles
  void _cleanupInvisibleVideos() {
    final viewModel = Provider.of<EjerciciosViewModel>(context, listen: false);
    for (var entry in _videoControllers.entries.toList()) {
      bool isVisible = false;
      for (var nivel in viewModel.niveles) {
        if (nivel.expandido) {
          for (var ejercicio in nivel.ejercicios) {
            if (ejercicio.id.toString() == entry.key) {
              isVisible = true;
              break;
            }
          }
        }
      }
      if (!isVisible) {
        entry.value.dispose();
        _videoControllers.remove(entry.key);
      }
    }
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
      
      // Verificar si es una URL de YouTube
      bool isYoutubeUrl = videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');
      
      if (isYoutubeUrl) {
        String? videoId = YoutubePlayerController.convertUrlToId(videoUrl);
        if (videoId == null) {
          throw Exception('URL de YouTube inválida');
        }

        _isInitializing[ejercicio.id.toString()] = false;
        if (mounted) setState(() {});
        return;
      }

      // Optimización para videos no-YouTube
      if (!videoUrl.startsWith('https://')) {
        videoUrl = videoUrl.replaceAll('http://', 'https://');
      }

      final videoPlayerController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        formatHint: VideoFormat.hls,
      );

      bool initialized = false;
      int retryCount = 0;
      while (!initialized && retryCount < 3) {
        try {
          await videoPlayerController.initialize().timeout(
            Duration(seconds: 10), // Reducido a 10 segundos
            onTimeout: () {
              throw TimeoutException('Tiempo de espera agotado');
            },
          );
          initialized = true;
        } catch (e) {
          retryCount++;
          if (retryCount >= 3) throw e;
          await Future.delayed(Duration(milliseconds: 500)); // Reducido a 500ms
        }
      }

      if (!mounted) {
        videoPlayerController.dispose();
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
        maxScale: 1.0,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        placeholder: Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error al cargar el video. Por favor, intenta de nuevo.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      );

      _videoControllers[ejercicio.id.toString()] = chewieController;
      _isInitializing[ejercicio.id.toString()] = false;
      
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Error al inicializar el video: $e');
      _isInitializing[ejercicio.id.toString()] = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosViewModel = Provider.of<EjerciciosViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final isHighResolution = screenSize.width >= 1440 || screenSize.height >= 2960;

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
      body: RefreshIndicator(
        onRefresh: () => ejerciciosViewModel.cargarNivelesYEjercicios(),
        color: Colors.blue[900],
        child: Padding(
          padding: EdgeInsets.all(isHighResolution ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nota informativa con tamaño adaptativo
              Container(
                padding: EdgeInsets.all(isHighResolution ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Tienes que hacer los ejercicios en orden. Los niveles se desbloquearán cuando tu terapeuta lo indique.",
                  style: TextStyle(
                    fontSize: isHighResolution ? 16 : 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              SizedBox(height: isHighResolution ? 24 : 16),
              
              Expanded(
                child: ejerciciosViewModel.cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ejerciciosViewModel.error.isNotEmpty
                    ? Center(
                        child: Text(
                          ejerciciosViewModel.error,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: ejerciciosViewModel.niveles.length,
                        itemBuilder: (context, index) {
                          final nivel = ejerciciosViewModel.niveles[index];
                          final desbloqueado = nivel.estado == 'desbloqueado';
                          
                          return Card(
                            color: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.only(bottom: isHighResolution ? 16 : 12),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.fitness_center,
                                    color: Colors.blue[300],
                                    size: isHighResolution ? 32 : 24,
                                  ),
                                  title: Text(
                                    nivel.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isHighResolution ? 22 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    nivel.descripcion ?? 'Ejercicios de este nivel',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: isHighResolution ? 16 : 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        desbloqueado 
                                          ? Icons.lock_open 
                                          : Icons.lock,
                                        color: desbloqueado 
                                          ? Colors.green[300] 
                                          : Colors.red[300],
                                        size: isHighResolution ? 28 : 24,
                                      ),
                                      SizedBox(width: isHighResolution ? 12 : 8),
                                      IconButton(
                                        icon: Icon(
                                          nivel.expandido
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: isHighResolution ? 32 : 24,
                                        ),
                                        onPressed: desbloqueado
                                            ? () {
                                                ejerciciosViewModel.toggleExpansion(index);
                                                _cleanupInvisibleVideos();
                                                
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
                                
                                if (nivel.expandido && desbloqueado)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: nivel.ejercicios.length,
                                    itemBuilder: (context, i) {
                                      final ejercicio = nivel.ejercicios[i];
                                      return _buildEjercicioItem(ejercicio, isHighResolution);
                                    },
                                  ),
                                
                                if (nivel.expandido && !desbloqueado)
                                  Padding(
                                    padding: EdgeInsets.all(isHighResolution ? 20 : 16),
                                    child: Text(
                                      "Este nivel está bloqueado. Contacta a tu terapeuta para desbloquearlo.",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                        fontSize: isHighResolution ? 16 : 14,
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Historial Clinico"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/historial-clinico');
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed('/chat');
          }
        },
      ),
    );
  }
  
  Widget _buildEjercicioItem(Ejercicio ejercicio, bool isHighResolution) {
    final bool tieneVideo = ejercicio.videoUrl != null && ejercicio.videoUrl!.isNotEmpty;
    final String ejercicioId = ejercicio.id.toString();
    final bool isLoading = _isInitializing[ejercicioId] == true;
    final bool isYoutubeUrl = (ejercicio.videoUrl?.contains('youtube.com') == true) || 
                             (ejercicio.videoUrl?.contains('youtu.be') == true);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isHighResolution ? 20 : 16,
        vertical: isHighResolution ? 12 : 8,
      ),
      padding: EdgeInsets.all(isHighResolution ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ejercicio.nombre,
            style: TextStyle(
              color: Colors.white,
              fontSize: isHighResolution ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isHighResolution ? 12 : 8),
          Text(
            ejercicio.instrucciones,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isHighResolution ? 16 : 14,
            ),
          ),
          if (tieneVideo) ...[
            SizedBox(height: isHighResolution ? 16 : 12),
            if (isYoutubeUrl && ejercicio.videoUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[300]!,
                      width: isHighResolution ? 3 : 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController.fromVideoId(
                      videoId: YoutubePlayerController.convertUrlToId(ejercicio.videoUrl!) ?? '',
                      params: const YoutubePlayerParams(
                        mute: false,
                        showControls: true,
                        enableJavaScript: true,
                        enableKeyboard: false,
                        strictRelatedVideos: true,
                        showFullscreenButton: true,
                        pointerEvents: PointerEvents.auto,
                      ),
                    ),
                  ),
                ),
              )
            else if (_videoControllers.containsKey(ejercicioId))
              Container(
                height: isHighResolution ? 250 : 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[300]!,
                    width: isHighResolution ? 3 : 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Chewie(controller: _videoControllers[ejercicioId]!),
                ),
              )
            else if (isLoading)
              Container(
                height: isHighResolution ? 250 : 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.blue[300],
                        strokeWidth: isHighResolution ? 3 : 2,
                      ),
                      SizedBox(height: isHighResolution ? 12 : 8),
                      Text(
                        'Cargando video...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isHighResolution ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.play_circle_outline,
                    size: isHighResolution ? 32 : 24,
                  ),
                  label: Text(
                    "Ver video",
                    style: TextStyle(
                      fontSize: isHighResolution ? 16 : 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isHighResolution ? 24 : 20,
                      vertical: isHighResolution ? 16 : 12,
                    ),
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