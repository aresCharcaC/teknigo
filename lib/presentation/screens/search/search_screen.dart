import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../view_models/search_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filtros de búsqueda (valores por defecto)
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

  @override
  void initState() {
    super.initState();

    // Inicializar búsqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchViewModel = Provider.of<SearchViewModel>(
        context,
        listen: false,
      );
      searchViewModel.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        Consumer<SearchViewModel>(
                          builder: (context, searchViewModel, child) {
                            return searchViewModel.query.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    searchViewModel.clearSearch();
                                  },
                                )
                                : const SizedBox.shrink();
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
                  onChanged: (value) {
                    final searchViewModel = Provider.of<SearchViewModel>(
                      context,
                      listen: false,
                    );
                    searchViewModel.updateQuery(value);
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    final searchViewModel = Provider.of<SearchViewModel>(
                      context,
                      listen: false,
                    );
                    searchViewModel.searchTechnicians();
                  },
                ),
              ),

              // Filtros aplicados
              Consumer<SearchViewModel>(
                builder: (context, searchViewModel, child) {
                  // Mostrar chips de filtros aplicados
                  if (searchViewModel.hasActiveFilters) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              'Filtros: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (searchViewModel.selectedCategory != 'Todas')
                              _buildFilterChip(
                                label: searchViewModel.selectedCategory,
                                onRemove: () {
                                  searchViewModel.updateCategory('Todas');
                                },
                              ),
                            if (searchViewModel.maxDistance <
                                AppConstants.defaultCoverageRadius)
                              _buildFilterChip(
                                label:
                                    'Máx. ${searchViewModel.maxDistance.toStringAsFixed(1)} km',
                                onRemove: () {
                                  searchViewModel.updateMaxDistance(
                                    AppConstants.defaultCoverageRadius,
                                  );
                                },
                              ),
                            if (searchViewModel.minRating > 3.0)
                              _buildFilterChip(
                                label:
                                    'Mín. ${searchViewModel.minRating.toStringAsFixed(1)} ★',
                                onRemove: () {
                                  searchViewModel.updateMinRating(3.0);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),

        // Resultados de búsqueda
        Expanded(
          child: Consumer<SearchViewModel>(
            builder: (context, searchViewModel, child) {
              if (searchViewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildSearchResults(searchViewModel);
            },
          ),
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
  Widget _buildSearchResults(SearchViewModel searchViewModel) {
    final results = searchViewModel.filteredTechnicians;

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
  Widget _buildTechnicianCard(TechnicianSearchItem technician) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar al perfil del técnico
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ver perfil de ${technician.name}'),
              behavior: SnackBarBehavior.floating,
            ),
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
                  // Avatar o imagen de perfil
                  technician.profileImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          technician.profileImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      )
                      : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),

                  // Indicador de disponibilidad
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
                    SnackBar(
                      content: Text('Contactar a ${technician.name}'),
                      behavior: SnackBarBehavior.floating,
                    ),
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
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );

    _selectedCategory = searchViewModel.selectedCategory;
    _maxDistance = searchViewModel.maxDistance;
    _minRating = searchViewModel.minRating;

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
                    // Actualizar los filtros en el ViewModel
                    searchViewModel.updateFilters(
                      category: _selectedCategory,
                      maxDistance: _maxDistance,
                      minRating: _minRating,
                    );

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
