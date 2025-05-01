import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../../auth/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0; // Para controlar el BottomNavigationBar

  // Lista de pantallas que se mostrarán según el índice seleccionado
  final List<Widget> _screens = [
    const HomeScreen(), // Pantalla de inicio con categorías
    const SearchScreen(), // Pantalla de búsqueda
  ];

  @override
  Widget build(BuildContext context) {
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
      drawer: const CustomDrawer(),

      // Contenido principal - cambia según la pestaña seleccionada
      body: _screens[_currentIndex],

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
}
