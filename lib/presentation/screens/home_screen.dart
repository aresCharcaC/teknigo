import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  String _searchQuery = '';

  // Lista de categorías predeterminadas
  final List<CategoryItem> _categories = [
    // Servicios eléctricos
    CategoryItem(
      id: '1',
      name: 'Electricista',
      tags: [
        'electricidad',
        'instalación',
        'cableado',
        'corto circuito',
        'enchufes',
        'iluminación',
        'mantenimiento',
      ],
      iconName: 'electrical_services',
      iconColor: Colors.amber,
    ),
    CategoryItem(
      id: '2',
      name: 'Técnico en Iluminación',
      tags: [
        'luces',
        'iluminación',
        'led',
        'decoración',
        'instalación',
        'reparación',
      ],
      iconName: 'lightbulb',
      iconColor: Colors.yellow,
    ),

    // Servicios de plomería
    CategoryItem(
      id: '3',
      name: 'Plomero',
      tags: [
        'agua',
        'tuberías',
        'grifos',
        'inodoro',
        'ducha',
        'fugas',
        'desagües',
      ],
      iconName: 'plumbing',
      iconColor: Colors.blue,
    ),
    CategoryItem(
      id: '4',
      name: 'Técnico en Calefacción',
      tags: [
        'calefacción',
        'caldera',
        'radiadores',
        'termostato',
        'reparación',
      ],
      iconName: 'thermostat',
      iconColor: Colors.red,
    ),

    // Servicios de tecnología
    CategoryItem(
      id: '5',
      name: 'Técnico PC',
      tags: [
        'computadora',
        'ordenador',
        'laptop',
        'software',
        'virus',
        'formateo',
        'mantenimiento',
      ],
      iconName: 'computer',
      iconColor: Colors.green,
    ),
    CategoryItem(
      id: '6',
      name: 'Reparador de Móviles',
      tags: [
        'celular',
        'móvil',
        'pantalla',
        'batería',
        'reparación',
        'software',
      ],
      iconName: 'smartphone',
      iconColor: Colors.lightBlue,
    ),
    CategoryItem(
      id: '7',
      name: 'Técnico en Redes',
      tags: [
        'internet',
        'wifi',
        'redes',
        'routers',
        'instalación',
        'configuración',
      ],
      iconName: 'wifi',
      iconColor: Colors.teal,
    ),

    // Servicios de climatización
    CategoryItem(
      id: '8',
      name: 'Refrigeración',
      tags: [
        'aire acondicionado',
        'heladera',
        'congelador',
        'frío',
        'climatización',
        'reparación',
      ],
      iconName: 'ac_unit',
      iconColor: Colors.cyan,
    ),
    CategoryItem(
      id: '9',
      name: 'Técnico en Ventilación',
      tags: [
        'ventiladores',
        'extractores',
        'conductos',
        'instalación',
        'mantenimiento',
      ],
      iconName: 'air',
      iconColor: Colors.lightGreen,
    ),

    // Servicios de seguridad
    CategoryItem(
      id: '10',
      name: 'Cerrajero',
      tags: [
        'llaves',
        'cerraduras',
        'puertas',
        'seguridad',
        'candados',
        'emergencia',
      ],
      iconName: 'key',
      iconColor: Colors.brown,
    ),
    CategoryItem(
      id: '11',
      name: 'Técnico en Alarmas',
      tags: ['alarmas', 'seguridad', 'instalación', 'sensores', 'monitoreo'],
      iconName: 'security',
      iconColor: Colors.redAccent,
    ),

    // Servicios de carpintería
    CategoryItem(
      id: '12',
      name: 'Carpintero',
      tags: [
        'madera',
        'muebles',
        'puertas',
        'armarios',
        'reparación',
        'fabricación',
      ],
      iconName: 'carpenter',
      iconColor: Colors.orange,
    ),
    CategoryItem(
      id: '13',
      name: 'Ebanista',
      tags: ['muebles', 'madera', 'diseño', 'restauración', 'artesanía'],
      iconName: 'chair',
      iconColor: Colors.brown,
    ),

    // Servicios de construcción
    CategoryItem(
      id: '14',
      name: 'Albañil',
      tags: [
        'construcción',
        'reparación',
        'paredes',
        'cemento',
        'obra',
        'reformas',
      ],
      iconName: 'build',
      iconColor: Colors.grey,
    ),
    CategoryItem(
      id: '15',
      name: 'Yesero',
      tags: ['yeso', 'paredes', 'techos', 'reformas', 'decoración'],
      iconName: 'construction',
      iconColor: Colors.grey,
    ),

    // Servicios de pintura
    CategoryItem(
      id: '16',
      name: 'Pintor',
      tags: [
        'pintura',
        'paredes',
        'decoración',
        'interior',
        'exterior',
        'reformas',
      ],
      iconName: 'format_paint',
      iconColor: Colors.purple,
    ),

    // Servicios de jardinería
    CategoryItem(
      id: '17',
      name: 'Jardinero',
      tags: [
        'jardín',
        'plantas',
        'césped',
        'poda',
        'paisajismo',
        'mantenimiento',
      ],
      iconName: 'grass',
      iconColor: Colors.lightGreen,
    ),
    CategoryItem(
      id: '18',
      name: 'Paisajista',
      tags: ['paisajismo', 'diseño', 'jardines', 'decoración', 'exterior'],
      iconName: 'park',
      iconColor: Colors.green,
    ),

    // Servicios de limpieza
    CategoryItem(
      id: '19',
      name: 'Limpieza',
      tags: [
        'hogar',
        'oficina',
        'profesional',
        'desinfección',
        'limpieza profunda',
      ],
      iconName: 'cleaning_services',
      iconColor: Colors.lightBlue,
    ),
    CategoryItem(
      id: '20',
      name: 'Limpieza de Alfombras',
      tags: [
        'alfombras',
        'tapetes',
        'limpieza',
        'desinfección',
        'especializada',
      ],
      iconName: 'clean_hands',
      iconColor: Colors.blueGrey,
    ),

    // Servicios automotrices
    CategoryItem(
      id: '21',
      name: 'Mecánico',
      tags: [
        'automóvil',
        'motor',
        'reparación',
        'mantenimiento',
        'diagnóstico',
        'frenos',
      ],
      iconName: 'car_repair',
      iconColor: Colors.red,
    ),
    CategoryItem(
      id: '22',
      name: 'Técnico en Neumáticos',
      tags: ['neumáticos', 'llantas', 'reparación', 'alineación', 'balanceo'],
      iconName: 'tire_repair',
      iconColor: Colors.black,
    ),

    // Servicios electrónicos
    CategoryItem(
      id: '23',
      name: 'Electrónica',
      tags: [
        'reparación',
        'televisión',
        'audio',
        'dispositivos',
        'circuitos',
        'electrodomésticos',
      ],
      iconName: 'memory',
      iconColor: Colors.teal,
    ),
    CategoryItem(
      id: '24',
      name: 'Técnico en Electrodomésticos',
      tags: ['lavadora', 'secadora', 'nevera', 'microondas', 'reparación'],
      iconName: 'microwave',
      iconColor: Colors.grey,
    ),

    // Servicios de mudanzas
    CategoryItem(
      id: '25',
      name: 'Mudanzas',
      tags: ['transporte', 'mudanza', 'empaque', 'muebles', 'traslado'],
      iconName: 'local_shipping',
      iconColor: Colors.orange,
    ),

    // Servicios de decoración
    CategoryItem(
      id: '26',
      name: 'Decorador de Interiores',
      tags: ['decoración', 'interiores', 'diseño', 'hogar', 'muebles'],
      iconName: 'home',
      iconColor: Colors.pink,
    ),

    // Servicios de fontanería avanzada
    CategoryItem(
      id: '27',
      name: 'Técnico en Piscinas',
      tags: ['piscinas', 'mantenimiento', 'limpieza', 'reparación', 'químicos'],
      iconName: 'pool',
      iconColor: Colors.blue,
    ),

    // Servicios de costura
    CategoryItem(
      id: '28',
      name: 'Costurero',
      tags: ['costura', 'ropa', 'arreglos', 'confección', 'sastrería'],
      iconName: 'checkroom',
      iconColor: Colors.purple,
    ),

    // Servicios de vidriería
    CategoryItem(
      id: '29',
      name: 'Vidriero',
      tags: ['vidrios', 'ventanas', 'espejos', 'instalación', 'reparación'],
      iconName: 'window',
      iconColor: Colors.cyan,
    ),

    // Servicios de techos
    CategoryItem(
      id: '30',
      name: 'Técnico en Tejados',
      tags: ['techos', 'tejados', 'reparación', 'impermeabilización', 'gotera'],
      iconName: 'roofing',
      iconColor: Colors.brown,
    ),

    // Servicios de control de plagas
    CategoryItem(
      id: '31',
      name: 'Control de Plagas',
      tags: ['plagas', 'fumigación', 'insectos', 'roedores', 'desinfección'],
      iconName: 'pest_control',
      iconColor: Colors.red,
    ),

    // Servicios de energía alternativa
    CategoryItem(
      id: '32',
      name: 'Técnico en Paneles Solares',
      tags: [
        'paneles solares',
        'energía',
        'instalación',
        'mantenimiento',
        'sostenibilidad',
      ],
      iconName: 'solar_power',
      iconColor: Colors.yellow,
    ),

    // Servicios de gas
    CategoryItem(
      id: '33',
      name: 'Técnico en Gas',
      tags: ['gas', 'instalación', 'reparación', 'fugas', 'cocina'],
      iconName: 'gas_meter',
      iconColor: Colors.orange,
    ),

    // Servicios de tapicería
    CategoryItem(
      id: '34',
      name: 'Tapicero',
      tags: ['tapicería', 'muebles', 'sofás', 'sillas', 'reparación'],
      iconName: 'weekend',
      iconColor: Colors.brown,
    ),

    // Servicios de cuidado de personas
    CategoryItem(
      id: '35',
      name: 'Cuidador de Ancianos',
      tags: ['cuidado', 'ancianos', 'asistencia', 'salud', 'acompañamiento'],
      iconName: 'elderly',
      iconColor: Colors.purple,
    ),

    // Servicios de estética
    CategoryItem(
      id: '36',
      name: 'Esteticista',
      tags: ['estética', 'uñas', 'depilación', 'maquillaje', 'faciales'],
      iconName: 'spa',
      iconColor: Colors.pink,
    ),

    // Servicios de eventos
    CategoryItem(
      id: '37',
      name: 'Organizador de Eventos',
      tags: ['eventos', 'fiestas', 'bodas', 'decoración', 'planificación'],
      iconName: 'celebration',
      iconColor: Colors.yellow,
    ),

    // Categoría genérica "Otro"
    CategoryItem(
      id: '38',
      name: 'Otro',
      tags: ['otros', 'servicios', 'especiales', 'varios', 'misceláneos'],
      iconName: 'more_horiz',
      iconColor: Colors.grey,
    ),
  ];

  List<CategoryItem> _filteredCategories = [];

  // Lista de técnicos mejor valorados (datos simulados)
  final List<TechnicianItem> _topTechnicians = [
    TechnicianItem(
      id: '1',
      name: 'Carlos Rodríguez',
      specialty: 'Electricista',
      rating: 4.8,
      distance: 2.1,
    ),
    TechnicianItem(
      id: '2',
      name: 'María López',
      specialty: 'Técnico PC',
      rating: 4.7,
      distance: 3.4,
    ),
    TechnicianItem(
      id: '3',
      name: 'Juan Pérez',
      specialty: 'Plomero',
      rating: 4.9,
      distance: 1.8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
    _filteredCategories = _categories;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Cargar datos
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar datos del usuario
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

  // Agregar una nueva categoría

  // Filtrar categorías cuando se busca
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterCategories();
    });
  }

  // Filtrar categorías según búsqueda
  void _filterCategories() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredCategories = _categories;
      });
      return;
    }

    setState(() {
      _filteredCategories =
          _categories.where((category) {
            // Buscar en nombre
            if (category.name.toLowerCase().contains(_searchQuery)) {
              return true;
            }

            // Buscar en tags
            for (final tag in category.tags) {
              if (tag.toLowerCase().contains(_searchQuery)) {
                return true;
              }
            }

            return false;
          }).toList();
    });
  }

  // Mostrar diálogo para agregar categoría
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar categoría'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    hintText: 'Ej: Carpintero',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (separados por coma)',
                    hintText: 'Ej: madera, muebles, puertas',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    // Procesar tags
                    final tagsString = tagsController.text.trim();
                    final tags =
                        tagsString.isEmpty
                            ? []
                            : tagsString
                                .split(',')
                                .map((tag) => tag.trim())
                                .toList();

                    Navigator.pop(context);
                  }
                },
                child: const Text('GUARDAR'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildHomeContent();
  }

  // Construir el contenido principal
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de técnicos mejor valorados
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Técnicos mejor valorados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Ver todos',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lista horizontal de técnicos mejor valorados (REDISEÑADA para eliminar espacio sin usar)
          SizedBox(
            height: 130, // Altura reducida
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topTechnicians.length,
              itemBuilder: (context, index) {
                final technician = _topTechnicians[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ver perfil de ${technician.name}'),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0), // Padding reducido
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila superior con foto y nombre (más compacta)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18, // Tamaño reducido
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 18, // Tamaño reducido
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        technician.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        technician.specialty,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Espacio reducido
                            const SizedBox(height: 10),

                            // Información adicional (podemos agregar más contenido)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Disponible ahora',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Fila inferior con valoración y distancia
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      technician.rating.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${technician.distance} km',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Buscador de categorías
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar categoría...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título y botón de categorías
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid de categorías
          _buildCategoriesGrid(),
        ],
      ),
    );
  }

  // Grid de categorías
  Widget _buildCategoriesGrid() {
    if (_filteredCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'No se encontraron categorías',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // AJUSTADO: Hacer las tarjetas más altas
      ),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  // Tarjeta de categoría - CORREGIDO para evitar desbordamiento
  Widget _buildCategoryCard(CategoryItem category) {
    // Determinar icono basado en el nombre de la categoría
    IconData iconData = Icons.category;

    // Si la categoría tiene un nombre de icono específico, usarlo
    if (category.iconName != null && category.iconName!.isNotEmpty) {
      switch (category.iconName) {
        case 'electrical_services':
          iconData = Icons.electrical_services;
          break;
        case 'plumbing':
          iconData = Icons.plumbing;
          break;
        case 'computer':
          iconData = Icons.computer;
          break;
        case 'ac_unit':
          iconData = Icons.ac_unit;
          break;
        case 'key':
          iconData = Icons.key;
          break;
        case 'carpenter':
          iconData = Icons.carpenter;
          break;
        case 'format_paint':
          iconData = Icons.format_paint;
          break;
        case 'build':
          iconData = Icons.build;
          break;
        case 'grass':
          iconData = Icons.grass;
          break;
        case 'cleaning_services':
          iconData = Icons.cleaning_services;
          break;
        case 'car_repair':
          iconData = Icons.car_repair;
          break;
        case 'memory':
          iconData = Icons.memory;
          break;
        default:
          iconData = Icons.category;
      }
    }

    // Color del icono
    Color iconColor = category.iconColor ?? Colors.blue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la pantalla de búsqueda con esta categoría
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoría: ${category.name}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category.tags.isNotEmpty)
                Flexible(
                  child: Text(
                    category.tags.join(', '),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase para los datos de una categoría (simplificada)
class CategoryItem {
  final String id;
  final String name;
  final List<String> tags;
  final String? iconName;
  final Color? iconColor;

  CategoryItem({
    required this.id,
    required this.name,
    required this.tags,
    this.iconName,
    this.iconColor,
  });
}

// Clase para los datos de un técnico
class TechnicianItem {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final double distance;

  TechnicianItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
  });
}
