import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/detalle_chat_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white),
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
      body: chatViewModel.isLoading
          ? _buildLoadingView()
          : chatViewModel.errorMessage != null
              ? _buildErrorView(chatViewModel.errorMessage!)
              : _buildContentView(chatViewModel),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Indicar que estamos en la pantalla de Chat
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Historial Clinico"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Ejercicios"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamed('/inicio');
          } else if (index == 1) {
            Navigator.of(context).pushNamed('/historial-clinico');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/ejercicios');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/chat');
          }
        },
      ),
    );
  }

  // Vista de carga
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            "Cargando chats...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Vista de error
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 60),
            SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Vista de contenido principal
  Widget _buildContentView(ChatViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.recargarDatos(),
      color: Colors.blue[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida con nombre de usuario
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Mis Chats",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Lista de terapeutas con chats
            Expanded(
              child: viewModel.terapeutas.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: _buildNoChatsView(),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: viewModel.terapeutas.length,
                    itemBuilder: (context, index) {
                      final terapeuta = viewModel.terapeutas[index];
                      return _buildChatCard(terapeuta);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de chat con terapeuta
  Widget _buildChatCard(terapeuta) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[300],
          child: Text(
            terapeuta.nombre.substring(0, 1) + terapeuta.primerApellido.substring(0, 1),
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          terapeuta.nombreCompleto,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Último mensaje...',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleChatView(
                terapeuta: terapeuta,
              ),
            ),
          );
        },
      ),
    );
  }

  // Vista cuando no hay chats
  Widget _buildNoChatsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white, size: 60),
          SizedBox(height: 20),
          Text(
            "No tienes chats disponibles",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            "Aún no se han iniciado conversaciones con tus terapeutas",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}