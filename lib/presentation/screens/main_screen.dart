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
        body: _clientScreens[_currentIndex],

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
            setState(() {
              _currentIndex = index;
            });
          },
        ),
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
  void _toggleTechnicianMode(bool value) {
    try {
      // Crear el perfil de técnico si no existe (solo la primera vez)
      if (value) {
        // Aquí podrías mostrar un diálogo de carga mientras se verifica y crea
        // el perfil de técnico si no existe

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambiando a modo técnico...'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambiando a modo cliente...'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Cambiar el estado después de la notificación
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _isTechnicianMode = value;
        });
      });
    } catch (e) {
      print('Error al cambiar al modo técnico: $e');

      // Mostrar mensaje de error
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
