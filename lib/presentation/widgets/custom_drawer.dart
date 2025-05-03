import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Menú lateral personalizado para la aplicación
class CustomDrawer extends StatelessWidget {
  final Function()? onProfileTap;
  final Function(bool)? onTechnicianModeToggle;
  final bool isTechnicianMode;

  const CustomDrawer({
    Key? key,
    this.onProfileTap,
    this.onTechnicianModeToggle,
    this.isTechnicianMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;

    // Extraer nombre y email seguros contra nulos
    final String userName = user?.displayName ?? 'Usuario';
    final String userEmail = user?.email ?? '';

    // Extraer foto de perfil si existe
    final String? photoURL = user?.photoURL;

    // Obtener primera letra del nombre para avatar por defecto
    String firstLetter = 'U';
    if (userName.isNotEmpty) {
      firstLetter = userName[0].toUpperCase();
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado del drawer optimizado para nombres largos
          _buildDrawerHeader(
            context,
            userName,
            userEmail,
            photoURL,
            firstLetter,
          ),

          // Elementos del menú
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de Servicios'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegación al historial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Historial de servicios'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // Separador
          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegar al perfil
              if (onProfileTap != null) {
                onProfileTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Perfil de usuario'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegación a configuración
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Configuración'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // Separador
          const Divider(),

          // Botón de Modo Técnico
          SwitchListTile(
            secondary: const Icon(Icons.handyman),
            title: const Text('Modo Técnico'),
            subtitle: Text(
              isTechnicianMode
                  ? 'Activo: Estás ofreciendo servicios'
                  : 'Inactivo: Estás como cliente',
            ),
            value: isTechnicianMode,
            activeColor: AppColors.success,
            onChanged: (bool value) {
              Navigator.pop(context); // Cerrar el drawer

              if (onTechnicianModeToggle != null) {
                onTechnicianModeToggle!(value);
              } else {
                // Fallback si no se proporciona el callback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Cambiando a modo técnico...'
                          : 'Cambiando a modo cliente...',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          // Separador
          const Divider(),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda y Soporte'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegación a ayuda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Ayuda y soporte'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Mostrar diálogo de información
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Acerca de TekniGo'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TekniGo v1.0.0'),
                          SizedBox(height: 8),
                          Text(
                            'Plataforma para conectar usuarios con técnicos especializados.',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CERRAR'),
                        ),
                      ],
                    ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.error),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context); // Cerrar el drawer

              // Confirmar cierre de sesión
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Estás seguro que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('CANCELAR'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('CERRAR SESIÓN'),
                        ),
                      ],
                    ),
              );

              // Si el usuario confirmó, cerrar sesión
              if (confirmed == true) {
                await authViewModel.signOut();
                // No es necesario navegar, el StreamBuilder lo hará automáticamente
              }
            },
          ),
        ],
      ),
    );
  }

  // Construir el encabezado del drawer (optimizado contra desbordamientos)
  Widget _buildDrawerHeader(
    BuildContext context,
    String name,
    String email,
    String? photoURL,
    String firstLetter,
  ) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del usuario (con foto o letra)
          photoURL != null && photoURL.isNotEmpty
              ? Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage(photoURL),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Si hay error al cargar la imagen, mostrará la letra
                      print('Error al cargar la imagen de perfil: $exception');
                    },
                  ),
                ),
              )
              : CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

          const SizedBox(height: 10),

          // Nombre del usuario con protección contra desbordamiento
          Container(
            width: double.infinity, // Usar todo el ancho disponible
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1, // Limitar a una línea
              overflow: TextOverflow.ellipsis, // Usar ... si es muy largo
            ),
          ),

          // Email del usuario con protección contra desbordamiento
          Container(
            width: double.infinity, // Usar todo el ancho disponible
            child: Text(
              email,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 1, // Limitar a una línea
              overflow: TextOverflow.ellipsis, // Usar ... si es muy largo
            ),
          ),
        ],
      ),
    );
  }
}
