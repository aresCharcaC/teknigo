import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado del drawer
          _buildDrawerHeader(
            context,
            user?.displayName ?? 'Usuario',
            user?.email ?? '',
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
            leading: const Icon(Icons.search),
            title: const Text('Buscar Técnicos'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegación a la pantalla de búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Búsqueda de técnicos'),
                ),
              );
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
              // Navegación al perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Perfil de usuario'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegación a configuración
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Configuración')),
              );
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
                const SnackBar(content: Text('Próximamente: Ayuda y soporte')),
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
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
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
                await authService.signOut();
                // No es necesario navegar, el StreamBuilder lo hará automáticamente
              }
            },
          ),
        ],
      ),
    );
  }

  // Construir el encabezado del drawer
  Widget _buildDrawerHeader(BuildContext context, String name, String email) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nombre del usuario
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email del usuario
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
