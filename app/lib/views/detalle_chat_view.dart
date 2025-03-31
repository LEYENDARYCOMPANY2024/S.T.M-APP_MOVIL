import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/detalle_chat_viewmodel.dart';
import '../models/terapeuta.dart';

class DetalleChatView extends StatefulWidget {
  final Terapeuta terapeuta;

  const DetalleChatView({
    Key? key, 
    required this.terapeuta,
  }) : super(key: key);

  @override
  _DetalleChatViewState createState() => _DetalleChatViewState();
}

class _DetalleChatViewState extends State<DetalleChatView> {
  final TextEditingController _mensajeController = TextEditingController();
  late DetalleChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DetalleChatViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.inicializarChat(widget.terapeuta);
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Text(
          widget.terapeuta.nombreCompleto,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/perfil');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue[700],
        ),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Cargando mensajes...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            
            if (viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 60),
                      SizedBox(height: 20),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Conversación",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: viewModel.mensajes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 60
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "No hay mensajes aún",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "¡Sé el primero en escribir!",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: viewModel.mensajes.length,
                            padding: EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final mensaje = viewModel.mensajes[index];
                              return _buildMensaje(mensaje);
                            },
                          ),
                  ),
                ),
                _buildInputMensaje(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMensaje(Map<String, dynamic> mensaje) {
    final esPaciente = mensaje['remitente'] == 'paciente';
    final fecha = DateTime.parse(mensaje['enviado_en']);
    final horaFormateada = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
    
    return Card(
      color: esPaciente ? Colors.blue[300] : Colors.grey[700],
      margin: EdgeInsets.only(
        left: esPaciente ? 60 : 8,
        right: esPaciente ? 8 : 60,
        bottom: 8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje['mensaje'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              horaFormateada,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputMensaje() {
    return Container(
      color: Colors.grey[800],
      padding: EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _mensajeController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[300],
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  if (_mensajeController.text.trim().isNotEmpty) {
                    final enviado = await viewModel.enviarMensaje(_mensajeController.text);
                    if (enviado) {
                      _mensajeController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al enviar el mensaje'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 