import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_drawer.dart';
import '../../auth/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario al iniciar
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Cerrar sesión
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // No es necesario navegar, el StreamBuilder lo hará automáticamente
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TekniGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildHomeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí iría la navegación a la pantalla de búsqueda de técnicos
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente: Búsqueda de técnicos')),
          );
        },
        child: const Icon(Icons.search),
        tooltip: 'Buscar técnicos',
      ),
    );
  }

  // Contenido principal de la pantalla de inicio
  Widget _buildHomeContent() {
    final userName = _userData?['name'] ?? 'Usuario';
    final userType = _userData?['userType'] ?? 'regular';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido, $userName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userType == 'regular'
                        ? 'Encuentra técnicos cerca de ti para solucionar tus problemas.'
                        : userType == 'technician'
                        ? 'Administra tus servicios y conecta con clientes.'
                        : 'Administra tu negocio y equipo técnico.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sección de servicios populares
          const Text(
            'Servicios Populares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Grid de servicios populares
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: const [
              _ServiceCard(
                icon: Icons.electrical_services,
                title: 'Electricista',
                color: Colors.amber,
              ),
              _ServiceCard(
                icon: Icons.plumbing,
                title: 'Plomero',
                color: Colors.blue,
              ),
              _ServiceCard(
                icon: Icons.devices,
                title: 'Técnico de PCs',
                color: Colors.green,
              ),
              _ServiceCard(
                icon: Icons.ac_unit,
                title: 'Refrigeración',
                color: Colors.cyan,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de "Conviértete en técnico" si es usuario regular
          if (userType == 'regular')
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.handyman, color: Colors.blue, size: 28),
                        SizedBox(width: 8),
                        Text(
                          '¿Eres técnico?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ofrece tus servicios en TekniGo y aumenta tus ingresos conectando con clientes en tu zona.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla de registro como técnico
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Próximamente: Registro como técnico',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('CONVERTIRME EN TÉCNICO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Sección de técnicos cercanos
          const Text(
            'Técnicos Cercanos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Lista de técnicos cercanos simulados
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Mostrar solo 3 técnicos como ejemplo
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> technicians = [
                {
                  'name': 'Carlos Rodríguez',
                  'specialty': 'Electricista',
                  'rating': 4.8,
                  'distance': '2.1 km',
                },
                {
                  'name': 'María López',
                  'specialty': 'Técnico en PCs',
                  'rating': 4.5,
                  'distance': '3.4 km',
                },
                {
                  'name': 'Juan Pérez',
                  'specialty': 'Plomero',
                  'rating': 4.7,
                  'distance': '1.8 km',
                },
              ];

              final technician = technicians[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(technician['name']),
                  subtitle: Text(technician['specialty']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            '${technician['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${technician['distance']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navegar a la pantalla de detalles del técnico
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ver detalles de ${technician['name']}'),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Botón para ver más técnicos
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Navegar a la pantalla de búsqueda de técnicos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Ver más técnicos'),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('VER MÁS TÉCNICOS'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Widget para las tarjetas de servicios
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ServiceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la búsqueda filtrada por esta categoría
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Buscar $title')));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
