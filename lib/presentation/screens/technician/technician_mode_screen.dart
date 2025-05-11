// lib/presentation/screens/technician/technician_mode_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../view_models/technician_view_model.dart';
import '../../view_models/technician_request_view_model.dart';
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

class _TechnicianModeScreenState extends State<TechnicianModeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas de técnico
    final List<Widget> _technicianScreens = [
      const TechnicianProfileScreen(),
      const TechnicianChatsScreen(),
      const TechnicianRequestsScreen(), // Ahora sí usamos esta pantalla
    ];

    return FadeTransition(
      opacity: _animation,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TechnicianViewModel()),
          // Añadimos el provider para la vista de solicitudes
          ChangeNotifierProvider(create: (_) => TechnicianRequestViewModel()),
        ],
        child: Consumer<TechnicianViewModel>(
          builder: (context, technicianViewModel, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Modo Técnico'),
                actions: [
                  // Switch para volver al modo cliente
                  Switch(
                    value: true,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.secondary.withOpacity(0.5),
                    onChanged: (value) {
                      if (!value) {
                        _animationController.reverse().then((_) {
                          if (widget.onSwitchMode != null) {
                            widget.onSwitchMode!(false);
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              drawer: CustomDrawer(
                onTechnicianModeToggle: (value) {
                  if (!value) {
                    _animationController.reverse().then((_) {
                      if (widget.onSwitchMode != null) {
                        widget.onSwitchMode!(false);
                      }
                    });
                  }
                },
                isTechnicianMode: true,
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: _technicianScreens,
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chats',
                  ),
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
      ),
    );
  }
}
