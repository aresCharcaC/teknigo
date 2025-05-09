import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_drawer.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/category_view_model.dart';
import '../view_models/technician_view_model.dart';
import '../../core/constants/app_constants.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'technician/technician_mode_screen.dart';
import 'profile/profile_screen.dart';

/// Pantalla principal que contiene el BottomNavigationBar y el menú lateral
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Para controlar el BottomNavigationBar
  bool _isTechnicianMode = false; // Estado del modo técnico

  // Lista de pantallas que se mostrarán según el índice seleccionado
  late final List<Widget> _clientScreens = [
    const HomeScreen(), // Pantalla de inicio con categorías
    const SearchScreen(), // Pantalla de búsqueda
  ];

  @override
  Widget build(BuildContext context) {
    // Si está en modo técnico, mostrar la pantalla de técnico
    if (_isTechnicianMode) {
      return TechnicianModeScreen(onSwitchMode: _toggleTechnicianMode);
    }

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CategoryViewModel())],
      child: Scaffold(
        // AppBar común para todas las pantallas
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: [
            // Icono de notificaciones
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Notificaciones'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: 'Notificaciones',
            ),
          ],
        ),

        // Drawer (menú lateral)
        drawer: CustomDrawer(
          onProfileTap: _navigateToProfile,
          onTechnicianModeToggle: _toggleTechnicianMode,
          isTechnicianMode: _isTechnicianMode,
        ),

        // Contenido principal - cambia según la pestaña seleccionada
        //body: _clientScreens[_currentIndex],

        // BottomNavigationBar simplificado con solo Home y Búsqueda
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Búsqueda',
            ),
          ],
          onTap: (index) {
            // Si ya estamos en esa pestaña, no hacemos nada
            if (index == _currentIndex) return;

            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: _currentIndex == 0 ? const HomeScreen() : const SearchScreen(),
      ),
    );
  }

  // Navegar al perfil del usuario
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  // Alternar entre modo cliente y técnico
  void _toggleTechnicianMode(bool value) async {
    if (_isTechnicianMode == value) return; // Avoid unnecessary state changes

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // If switching to technician mode
      if (value) {
        // Initialize technician profile if needed
        final technicianViewModel = Provider.of<TechnicianViewModel>(
          context,
          listen: false,
        );

        // Load technician profile data
        await technicianViewModel.loadTechnicianProfile();
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Update state
      setState(() {
        _isTechnicianMode = value;
      });

      // Show confirmation after state change
      String message =
          value ? 'Modo técnico activado' : 'Modo cliente activado';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Close loading dialog if error occurs
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar de modo: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
