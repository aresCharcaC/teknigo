import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../view_models/technician_view_model.dart';
import '../../widgets/custom_drawer.dart';
import 'profile/technician_profile_screen.dart';
import 'chats/technician_chats_screen.dart';
import 'requests/technician_requests_screen.dart';

/// Pantalla principal del modo técnico
///
/// Esta pantalla es el punto de entrada al modo técnico y
/// contiene la navegación entre las diferentes secciones.
class TechnicianModeScreen extends StatefulWidget {
  final Function(bool)? onSwitchMode;

  const TechnicianModeScreen({Key? key, this.onSwitchMode}) : super(key: key);

  @override
  _TechnicianModeScreenState createState() => _TechnicianModeScreenState();
}

class _TechnicianModeScreenState extends State<TechnicianModeScreen> {
  int _currentIndex = 0; // Para controlar el BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TechnicianViewModel(),
      child: Consumer<TechnicianViewModel>(
        builder: (context, technicianViewModel, _) {
          // Lista de pantallas del técnico
          final List<Widget> _technicianScreens = [
            const TechnicianProfileScreen(),
            const TechnicianChatsScreen(),
            const TechnicianRequestsScreen(),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Modo Técnico'),
              actions: [
                // Switch para regresar al modo cliente
                Switch(
                  value: true, // Siempre activo en esta pantalla
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.secondary.withOpacity(0.5),
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
            body:
                technicianViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _technicianScreens[_currentIndex],

            // BottomNavigationBar para navegar entre las pantallas del técnico
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work),
                  label: 'Solicitudes',
                ),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
