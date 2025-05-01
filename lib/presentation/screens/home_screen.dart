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

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _searchQuery = '';

  // Lista de categorías simplificada
  List<CategoryItem> _categories = [];
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

      // Cargar categorías directamente desde Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      print('Documentos encontrados: ${snapshot.docs.length}');

      List<CategoryItem> categories = [];

      if (snapshot.docs.isEmpty) {
        // Si no hay categorías, crear algunas por defecto
        await _createDefaultCategories();

        // Cargar categorías nuevamente
        final newSnapshot =
            await FirebaseFirestore.instance.collection('categories').get();

        for (var doc in newSnapshot.docs) {
          final data = doc.data();
          categories.add(
            CategoryItem(
              id: doc.id,
              name: data['name'] ?? 'Sin nombre',
              tags: List<String>.from(data['tags'] ?? []),
            ),
          );
        }
      } else {
        // Convertir documentos a categorías
        for (var doc in snapshot.docs) {
          final data = doc.data();
          categories.add(
            CategoryItem(
              id: doc.id,
              name: data['name'] ?? 'Sin nombre',
              tags: List<String>.from(data['tags'] ?? []),
            ),
          );
        }
      }

      setState(() {
        _userData = userData;
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;

        // Usar categorías por defecto en caso de error
        _categories = [
          CategoryItem(id: '1', name: 'Electricista', tags: ['electricidad']),
          CategoryItem(id: '2', name: 'Plomero', tags: ['agua', 'tuberías']),
          CategoryItem(id: '3', name: 'Técnico PC', tags: ['computadora']),
          CategoryItem(
            id: '4',
            name: 'Refrigeración',
            tags: ['aire acondicionado'],
          ),
          CategoryItem(id: '5', name: 'Cerrajero', tags: ['llaves', 'puertas']),
          CategoryItem(
            id: '6',
            name: 'Carpintero',
            tags: ['madera', 'muebles'],
          ),
        ];

        _filteredCategories = _categories;
      });
    }
  }

  // Crear categorías por defecto en Firestore
  Future<void> _createDefaultCategories() async {
    try {
      print('Creando categorías por defecto...');

      final batch = FirebaseFirestore.instance.batch();

      // Lista de categorías predeterminadas
      final defaultCategories = [
        {
          'name': 'Electricista',
          'tags': ['electricidad', 'instalación', 'cableado'],
        },
        {
          'name': 'Plomero',
          'tags': ['agua', 'tuberías', 'grifos'],
        },
        {
          'name': 'Técnico PC',
          'tags': ['computadora', 'laptop', 'software'],
        },
        {
          'name': 'Refrigeración',
          'tags': ['aire acondicionado', 'heladera', 'congelador'],
        },
        {
          'name': 'Cerrajero',
          'tags': ['llaves', 'cerraduras', 'puertas'],
        },
        {
          'name': 'Carpintero',
          'tags': ['madera', 'muebles', 'armarios'],
        },
      ];

      // Agregar cada categoría al batch
      for (var category in defaultCategories) {
        final docRef =
            FirebaseFirestore.instance.collection('categories').doc();
        batch.set(docRef, {
          'name': category['name'],
          'tags': category['tags'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Ejecutar el batch
      await batch.commit();
      print('Categorías predeterminadas creadas');
    } catch (e) {
      print('Error al crear categorías por defecto: $e');
    }
  }

  // Agregar una nueva categoría
  Future<void> _addCategory(String name, dynamic tagsInput) async {
    try {
      // Convertir la entrada dinámica a List<String>
      List<String> tags;
      if (tagsInput is List<dynamic>) {
        tags = tagsInput.map((tag) => tag.toString()).toList();
      } else if (tagsInput is List<String>) {
        tags = tagsInput;
      } else {
        tags = [];
      }

      await FirebaseFirestore.instance.collection('categories').add({
        'name': name,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Recargar datos
      _loadData();
    } catch (e) {
      print('Error al agregar categoría: $e');
    }
  }

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

                    // Agregar categoría
                    _addCategory(name, tags);

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
          // ELIMINADO: Sección de bienvenida

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

          // Lista horizontal de técnicos mejor valorados (en lugar de vertical)
          SizedBox(
            height: 160, // Altura fija para la lista horizontal
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
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
                            const Spacer(),
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
    // Elegir un icono basado en el nombre de la categoría (simplificado)
    IconData iconData = Icons.category;

    // Asignar iconos específicos para ciertas categorías conocidas
    final String categoryName = category.name.toLowerCase();
    if (categoryName.contains('electric'))
      iconData = Icons.electrical_services;
    else if (categoryName.contains('plom'))
      iconData = Icons.plumbing;
    else if (categoryName.contains('técnico') ||
        categoryName.contains('comput'))
      iconData = Icons.computer;
    else if (categoryName.contains('refri') || categoryName.contains('aire'))
      iconData = Icons.ac_unit;
    else if (categoryName.contains('cerraj'))
      iconData = Icons.key;
    else if (categoryName.contains('carpinter'))
      iconData = Icons.carpenter;

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
            mainAxisSize: MainAxisSize.min, // AÑADIDO: Usar MainAxisSize.min
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono por defecto (posteriormente podría ser una imagen)
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Icon(iconData, color: Colors.blue, size: 24),
              ),
              const SizedBox(height: 8),
              // CAMBIO: Uso de Flexible para texto adaptable
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
              // CAMBIO: Uso de Flexible para tags también
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

  CategoryItem({required this.id, required this.name, required this.tags});
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
