import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../../auth/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'technician_mode_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
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

    return Scaffold(
      // AppBar común para todas las pantallas
      appBar: AppBar(
        title: const Text('TekniGo'),
        actions: [
          // Icono de notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Notificaciones')),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Búsqueda'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
    setState(() {
      _isTechnicianMode = value;
    });
  }
}
