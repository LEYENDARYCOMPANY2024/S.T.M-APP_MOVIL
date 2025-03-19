import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_design.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: HomeDesign.buildAppBar(
        context: context,
        onProfileTap: () => Navigator.of(context).pushNamed('/perfil'),
        onRefreshTap: () => homeViewModel.recargarDatos(),
        onLogoutTap: () async {
          await loginViewModel.logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      body: homeViewModel.isLoading
          ? HomeDesign.buildLoadingView()
          : homeViewModel.errorMessage != null
              ? HomeDesign.buildErrorView(
                  errorMessage: homeViewModel.errorMessage!,
                  onRetry: () => homeViewModel.recargarDatos(),
                  context: context,
                )
              : HomeDesign.buildContentView(
                  viewModel: homeViewModel,
                ),
      bottomNavigationBar: HomeDesign.buildBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            // Ya estamos en home
          } else if (index == 1) {
            // Navegación a progreso (aún no implementada)
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/ejercicios');
          }
        },
      ),
      floatingActionButton: HomeDesign.buildFloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/sesion'),
      ),
    );
  }
}