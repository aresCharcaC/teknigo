import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  // Filtros de búsqueda
  String _selectedCategory = 'Todas';
  double _maxDistance = 10.0; // km
  double _minRating = 3.0; // estrellas

  // Lista de categorías para el filtro
  final List<String> _categories = [
    'Todas',
    'Electricista',
    'Plomero',
    'Técnico PC',
    'Refrigeración',
    'Cerrajero',
    'Carpintero',
  ];

  // Lista de técnicos (datos simulados)
  final List<SearchTechnicianItem> _technicians = [
    SearchTechnicianItem(
      id: '1',
      name: 'Carlos Rodríguez',
      specialty: 'Electricista',
      rating: 4.8,
      reviews: 124,
      distance: 2.1,
      available: true,
    ),
    SearchTechnicianItem(
      id: '2',
      name: 'María López',
      specialty: 'Técnico PC',
      rating: 4.7,
      reviews: 98,
      distance: 3.4,
      available: true,
    ),
    SearchTechnicianItem(
      id: '3',
      name: 'Juan Pérez',
      specialty: 'Plomero',
      rating: 4.9,
      reviews: 203,
      distance: 1.8,
      available: false,
    ),
    SearchTechnicianItem(
      id: '4',
      name: 'Ana Martínez',
      specialty: 'Refrigeración',
      rating: 4.6,
      reviews: 87,
      distance: 4.2,
      available: true,
    ),
    SearchTechnicianItem(
      id: '5',
      name: 'Roberto Gómez',
      specialty: 'Cerrajero',
      rating: 4.5,
      reviews: 76,
      distance: 5.1,
      available: true,
    ),
    SearchTechnicianItem(
      id: '6',
      name: 'Laura Torres',
      specialty: 'Electricista',
      rating: 4.4,
      reviews: 62,
      distance: 6.3,
      available: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Actualizar la consulta de búsqueda
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Filtrar técnicos según los criterios
  List<SearchTechnicianItem> get _filteredTechnicians {
    return _technicians.where((technician) {
      // Filtrar por texto de búsqueda
      final matchesQuery =
          _searchQuery.isEmpty ||
          technician.name.toLowerCase().contains(_searchQuery) ||
          technician.specialty.toLowerCase().contains(_searchQuery);

      // Filtrar por categoría
      final matchesCategory =
          _selectedCategory == 'Todas' ||
          technician.specialty == _selectedCategory;

      // Filtrar por distancia
      final matchesDistance = technician.distance <= _maxDistance;

      // Filtrar por valoración
      final matchesRating = technician.rating >= _minRating;

      return matchesQuery &&
          matchesCategory &&
          matchesDistance &&
          matchesRating;
    }).toList();
  }

  // Mostrar los filtros de búsqueda
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => _buildFilterForm(setModalState),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo de búsqueda
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
                    hintText: 'Buscar técnicos...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: _showFilterDialog,
                          tooltip: 'Filtros',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filtros aplicados
              if (_selectedCategory != 'Todas' ||
                  _maxDistance < 10.0 ||
                  _minRating > 3.0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Filtros: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_selectedCategory != 'Todas')
                        _buildFilterChip(
                          label: _selectedCategory,
                          onRemove: () {
                            setState(() {
                              _selectedCategory = 'Todas';
                            });
                          },
                        ),
                      if (_maxDistance < 10.0)
                        _buildFilterChip(
                          label: 'Máx. ${_maxDistance.toStringAsFixed(1)} km',
                          onRemove: () {
                            setState(() {
                              _maxDistance = 10.0;
                            });
                          },
                        ),
                      if (_minRating > 3.0)
                        _buildFilterChip(
                          label: 'Mín. ${_minRating.toStringAsFixed(1)} ★',
                          onRemove: () {
                            setState(() {
                              _minRating = 3.0;
                            });
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Resultados de búsqueda
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSearchResults(),
        ),
      ],
    );
  }

  // Construir chip de filtro
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.blue.shade50,
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
      ),
    );
  }

  // Construir resultados de búsqueda
  Widget _buildSearchResults() {
    final results = _filteredTechnicians;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron técnicos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Intenta con otros términos de búsqueda o ajusta los filtros',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final technician = results[index];
        return _buildTechnicianCard(technician);
      },
    );
  }

  // Construir tarjeta de técnico
  Widget _buildTechnicianCard(SearchTechnicianItem technician) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar al perfil del técnico
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ver perfil de ${technician.name}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar del técnico
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.grey,
                    ),
                  ),
                  if (technician.available)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Información del técnico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technician.specialty,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Valoración
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${technician.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${technician.reviews})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Distancia
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${technician.distance} km',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de contacto
              IconButton(
                icon: const Icon(Icons.message, color: Colors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contactar a ${technician.name}')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir formulario de filtros
  Widget _buildFilterForm(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de arrastre
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título
          const Text(
            'Filtros de búsqueda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Filtro de categoría
          const Text(
            'Categoría',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filtro de distancia máxima
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distancia máxima',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '${_maxDistance.toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _maxDistance,
            min: 1.0,
            max: 10.0,
            divisions: 9,
            onChanged: (value) {
              setModalState(() {
                _maxDistance = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Filtro de valoración mínima
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valoración mínima',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    '${_minRating.toStringAsFixed(1)} ★',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: _minRating,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            onChanged: (value) {
              setModalState(() {
                _minRating = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              // Botón para restablecer filtros
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setModalState(() {
                      _selectedCategory = 'Todas';
                      _maxDistance = 10.0;
                      _minRating = 3.0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Restablecer'),
                ),
              ),
              const SizedBox(width: 16),
              // Botón para aplicar filtros
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Actualizar los filtros en el estado principal
                      _selectedCategory = _selectedCategory;
                      _maxDistance = _maxDistance;
                      _minRating = _minRating;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Clase para los datos de un técnico en la búsqueda
class SearchTechnicianItem {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final double distance;
  final bool available;

  SearchTechnicianItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.available,
  });
}
