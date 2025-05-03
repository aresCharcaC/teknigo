// lib/presentation/screens/technician_mode_screen.dart
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/custom_drawer.dart';
import 'technician/technician_profile_screen.dart';
import 'technician/technician_chats_screen.dart';
import 'technician/technician_requests_screen.dart';

class TechnicianModeScreen extends StatefulWidget {
  final Function(bool)? onSwitchMode;

  const TechnicianModeScreen({Key? key, this.onSwitchMode}) : super(key: key);

  @override
  _TechnicianModeScreenState createState() => _TechnicianModeScreenState();
}

class _TechnicianModeScreenState extends State<TechnicianModeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0; // Para controlar el BottomNavigationBar

  // Lista de pantallas del técnico
  late final List<Widget> _technicianScreens = [
    const TechnicianProfileScreen(),
    const TechnicianChatsScreen(),
    const TechnicianRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Técnico'),
        actions: [
          Switch(
            value: true, // Siempre activo en esta pantalla
            activeColor: Colors.white,
            onChanged: (value) {
              if (!value) {
                // Regresar a modo cliente
                if (widget.onSwitchMode != null) {
                  widget.onSwitchMode!(false);
                }
              }
            },
          ),
        ],
      ),

      // Drawer personalizado para técnico
      drawer: CustomDrawer(
        onTechnicianModeToggle: widget.onSwitchMode,
        isTechnicianMode: true,
      ),

      // El contenido principal cambia según la pestaña seleccionada
      body: _technicianScreens[_currentIndex],

      // BottomNavigationBar para navegar entre las pantallas del técnico
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Solicitudes'),
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
