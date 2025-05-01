import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/custom_drawer.dart';
import 'profile_screen.dart';

class TechnicianModeScreen extends StatefulWidget {
  final Function(bool)? onSwitchMode;

  const TechnicianModeScreen({Key? key, this.onSwitchMode}) : super(key: key);

  @override
  _TechnicianModeScreenState createState() => _TechnicianModeScreenState();
}

class _TechnicianModeScreenState extends State<TechnicianModeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  // Opciones seleccionadas
  final List<String> _selectedCategories = [];
  bool _isIndividual = true; // Por defecto: Individual

  // Datos estáticos de ejemplo
  final List<Map<String, dynamic>> _availableCategories = [
    {'id': '1', 'name': 'Electricista'},
    {'id': '2', 'name': 'Plomero'},
    {'id': '3', 'name': 'Técnico PC'},
    {'id': '4', 'name': 'Refrigeración'},
    {'id': '5', 'name': 'Cerrajero'},
    {'id': '6', 'name': 'Carpintero'},
  ];

  // Solicitudes de servicio (datos simulados)
  final List<Map<String, dynamic>> _serviceRequests = [
    {
      'id': '1',
      'clientName': 'María González',
      'category': 'Electricista',
      'description': 'No funciona la luz en la cocina',
      'distance': 2.3,
      'time': 'Hace 10 minutos',
    },
    {
      'id': '2',
      'clientName': 'Pedro Ramírez',
      'category': 'Electricista',
      'description': 'Necesito instalar lámparas en mi sala',
      'distance': 4.1,
      'time': 'Hace 22 minutos',
    },
    {
      'id': '3',
      'clientName': 'Ana Suárez',
      'category': 'Electricista',
      'description': 'Cortocircuito en el dormitorio',
      'distance': 1.8,
      'time': 'Hace 35 minutos',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario
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
      print('Error al cargar datos del usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Alternar categoría seleccionada
  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  // Cambiar entre modo individual y negocio
  void _toggleTechnicianType(bool isIndividual) {
    setState(() {
      _isIndividual = isIndividual;
    });
  }

  // Responder a una solicitud de servicio
  void _respondToServiceRequest(String requestId, bool accept) {
    // En una implementación real, aquí enviarías la respuesta al servidor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accept
              ? 'Has aceptado la solicitud de servicio'
              : 'Has rechazado la solicitud de servicio',
        ),
        backgroundColor: accept ? Colors.green : Colors.grey,
      ),
    );
  }

  // Navegar al perfil de usuario
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      // Usar el mismo drawer pero con modo técnico activado
      drawer: CustomDrawer(
        onProfileTap: _navigateToProfile,
        onTechnicianModeToggle: widget.onSwitchMode,
        isTechnicianMode: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de perfil
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            _userData?['name']?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData?['name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _userData?['email'] ?? '',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "4.8", // Valoración (estática por ahora)
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    " (32 reseñas)",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a edición de perfil
                            _navigateToProfile();
                          },
                          child: const Text('Editar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Tipo de técnico',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Selector de tipo de técnico
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _toggleTechnicianType(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _isIndividual
                                        ? Colors.blue.shade50
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      _isIndividual
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                  width: _isIndividual ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color:
                                        _isIndividual
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Individual',
                                    style: TextStyle(
                                      color:
                                          _isIndividual
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade700,
                                      fontWeight:
                                          _isIndividual
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _toggleTechnicianType(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    !_isIndividual
                                        ? Colors.blue.shade50
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      !_isIndividual
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                  width: !_isIndividual ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color:
                                        !_isIndividual
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Negocio',
                                    style: TextStyle(
                                      color:
                                          !_isIndividual
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade700,
                                      fontWeight:
                                          !_isIndividual
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Categorías
            const Text(
              'Mis categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              'Selecciona las categorías en las que ofreces servicios',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Lista de categorías disponibles
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(
                      category['id'],
                    );
                    return FilterChip(
                      label: Text(category['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        _toggleCategory(category['id']);
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Botón para habilitar/deshabilitar servicios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedCategories.isEmpty
                        ? null
                        : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '¡Servicios habilitados! Ahora puedes recibir solicitudes.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'HABILITAR SERVICIOS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Solicitudes de servicio
            const Text(
              'Solicitudes de servicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Lista de solicitudes
            _serviceRequests.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay solicitudes de servicio',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cuando alguien solicite tus servicios, aparecerá aquí',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _serviceRequests.length,
                  itemBuilder: (context, index) {
                    final request = _serviceRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(
                                    request['clientName'].substring(0, 1),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request['clientName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        request['category'],
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      request['time'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${request['distance']} km',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Descripción:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(request['description']),

                            const SizedBox(height: 16),

                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        () => _respondToServiceRequest(
                                          request['id'],
                                          false,
                                        ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Rechazar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _respondToServiceRequest(
                                          request['id'],
                                          true,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Aceptar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
