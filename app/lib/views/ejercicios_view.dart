import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../viewmodels/ejercicios_viewmodel.dart';
import '../models/ejercicio.dart';

class EjerciciosView extends StatefulWidget {
  const EjerciciosView({Key? key}) : super(key: key);

  @override
  State<EjerciciosView> createState() => _EjerciciosViewState();
}

class _EjerciciosViewState extends State<EjerciciosView> {
  // Mapa para almacenar los controladores de video
  final Map<String, ChewieController> _videoControllers = {};
  
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
    // Liberar los controladores de video
    _disposeAllVideoControllers();
    super.dispose();
  }

  void _disposeAllVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  void _initializeVideoController(Ejercicio ejercicio) {
    if (ejercicio.videoUrl == null || ejercicio.videoUrl!.isEmpty) return;
    
    // Evitar inicializar varias veces el mismo controlador
    if (_videoControllers.containsKey(ejercicio.id.toString())) return;
    
    try {
      final videoPlayerController = VideoPlayerController.network(ejercicio.videoUrl!);
      
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        placeholder: Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error al cargar el video: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      
      _videoControllers[ejercicio.id.toString()] = chewieController;
      
      // Notificar a la UI para actualizar
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Error al inicializar el reproductor de video: $e');
    }
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
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progreso"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/progreso');
          }
        },
      ),
    );
  }
  
  // Widget para mostrar un ejercicio individual con reproductor de video
  Widget _buildEjercicioItem(Ejercicio ejercicio) {
    final bool tieneVideo = ejercicio.videoUrl != null && ejercicio.videoUrl!.isNotEmpty;
    final String ejercicioId = ejercicio.id.toString();
    
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
            // Reproductor de video
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
            else
              // Botón para inicializar el video
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text("Ver video"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
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