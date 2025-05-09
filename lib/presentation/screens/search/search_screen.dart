// lib/presentation/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/technician_search_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/search_view_model.dart';
import '../../view_models/category_view_model.dart';
import '../../widgets/technician_list_item.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory; // Para cuando se llega desde una categoría

  const SearchScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Inicializar la búsqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchViewModel = Provider.of<SearchViewModel>(
        context,
        listen: false,
      );
      searchViewModel.initialize().then((_) {
        // Si hay categoría inicial, aplicarla
        if (widget.initialCategory != null) {
          searchViewModel.updateCategoryFilter([widget.initialCategory!]);
          searchViewModel.applyFilters();
        }
      });

      // Cargar categorías para el filtro
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      categoryViewModel.loadCategories();
    });

    // Listener para el scroll para implementar la paginación
    _scrollController.addListener(_onScroll);

    // Listener para la búsqueda en tiempo real
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Detectar cuando el usuario llega al final de la lista
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final searchViewModel = Provider.of<SearchViewModel>(
        context,
        listen: false,
      );
      if (!searchViewModel.isLoading &&
          !searchViewModel.isLoadingMore &&
          searchViewModel.hasMoreResults) {
        searchViewModel.loadMoreResults();
      }
    }
  }

  // Manejar cambios en el texto de búsqueda
  void _onSearchChanged() {
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );
    searchViewModel.updateSearchText(_searchController.text);

    // Debounce para no realizar búsquedas con cada tecla
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == searchViewModel.searchText) {
        searchViewModel.searchTechnicians();
      }
    });
  }

  // Mostrar diálogo de filtros
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) => _buildFilterDialog(setState),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Técnicos'), centerTitle: true),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                  suffixIcon: Consumer<SearchViewModel>(
                    builder: (context, searchViewModel, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchViewModel.searchText.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                searchViewModel.updateSearchText('');
                                searchViewModel.searchTechnicians();
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showFilterDialog,
                            tooltip: 'Filtros',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Indicadores de filtros activos
          Consumer<SearchViewModel>(
            builder: (context, searchViewModel, child) {
              // Mostrar chips con filtros activos
              return _buildActiveFilters(searchViewModel);
            },
          ),

          // Lista de resultados
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, searchViewModel, child) {
                // Indicador de carga
                if (searchViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Sin resultados
                if (searchViewModel.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron técnicos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos o filtros',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Lista de resultados
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount:
                      searchViewModel.searchResults.length +
                      (searchViewModel.isLoadingMore ||
                              searchViewModel.hasMoreResults
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    // Indicador de carga al final
                    if (index == searchViewModel.searchResults.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child:
                              searchViewModel.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : const Text('Desplaza para cargar más'),
                        ),
                      );
                    }

                    // Item de técnico
                    return TechnicianListItem(
                      technician: searchViewModel.searchResults[index],
                      onTap:
                          () => _navigateToTechnicianProfile(
                            searchViewModel.searchResults[index].id,
                          ),
                      onContact:
                          () => _contactTechnician(
                            searchViewModel.searchResults[index].id,
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Navegar al perfil del técnico
  void _navigateToTechnicianProfile(String technicianId) {
    // Implementar navegación al perfil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver perfil de técnico: $technicianId'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Más adelante navegarás a la pantalla de perfil del técnico
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TechnicianProfileScreen(id: technicianId),
    //   ),
    // );
  }

  // Contactar al técnico
  void _contactTechnician(String technicianId) {
    // Implementar inicio de chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactar al técnico: $technicianId'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Más adelante navegarás a la pantalla de chat
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatScreen(technicianId: technicianId),
    //   ),
    // );
  }

  // Construir chips de filtros activos
  Widget _buildActiveFilters(SearchViewModel viewModel) {
    // Si no hay filtros activos, no mostrar nada
    if (viewModel.selectedCategories.isEmpty &&
        viewModel.minRating == 0.0 &&
        !viewModel.onlyAvailable &&
        viewModel.onlyBusiness == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Filtros de categoría
          ...viewModel.selectedCategories.map((category) {
            // Obtener nombre de categoría
            String categoryName = category;

            // Si tenemos acceso al CategoryViewModel, obtenemos el nombre real
            try {
              final categoryViewModel = Provider.of<CategoryViewModel>(
                context,
                listen: false,
              );
              final cat = categoryViewModel.categories.firstWhere(
                (c) => c.id == category,
                orElse: () => null,
              );
              if (cat != null) {
                categoryName = cat.name;
              }
            } catch (_) {}

            return Chip(
              label: Text(categoryName),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                final categories = List<String>.from(
                  viewModel.selectedCategories,
                );
                categories.remove(category);
                viewModel.updateCategoryFilter(categories);
                viewModel.applyFilters();
              },
            );
          }).toList(),

          // Filtro de valoración
          if (viewModel.minRating > 0.0)
            Chip(
              label: Text('${viewModel.minRating.toStringAsFixed(1)}+ ★'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                viewModel.updateRatingFilter(0.0);
                viewModel.applyFilters();
              },
            ),

          // Filtro de disponibilidad
          if (viewModel.onlyAvailable)
            Chip(
              label: const Text('Disponible ahora'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                viewModel.updateAvailabilityFilter(false);
                viewModel.applyFilters();
              },
            ),

          // Filtro de tipo
          if (viewModel.onlyBusiness != null)
            Chip(
              label: Text(
                viewModel.onlyBusiness! ? 'Solo empresas' : 'Solo individuales',
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                viewModel.updateBusinessFilter(null);
                viewModel.applyFilters();
              },
            ),

          // Botón para limpiar todos los filtros
          ActionChip(
            avatar: const Icon(Icons.clear_all, size: 16),
            label: const Text('Limpiar filtros'),
            onPressed: () {
              viewModel.clearFilters();
            },
          ),
        ],
      ),
    );
  }

  // Construir el diálogo de filtros
  Widget _buildFilterDialog(StateSetter setModalState) {
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );

    // Variables locales para el estado del diálogo
    List<String> selectedCategories = List.from(
      searchViewModel.selectedCategories,
    );
    double minRating = searchViewModel.minRating;
    bool onlyAvailable = searchViewModel.onlyAvailable;
    bool? onlyBusiness = searchViewModel.onlyBusiness;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
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

              const SizedBox(height: 16),

              // Título
              const Text(
                'Filtros de búsqueda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // Filtro por categorías
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    categoryViewModel.categories.map((category) {
                      final isSelected = selectedCategories.contains(
                        category.id,
                      );
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add(category.id);
                            } else {
                              selectedCategories.remove(category.id);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 24),

              // Filtro por valoración
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Valoración mínima',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        minRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ],
              ),
              Slider(
                value: minRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                onChanged: (value) {
                  setModalState(() {
                    minRating = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Filtro por disponibilidad
              SwitchListTile(
                title: const Text(
                  'Solo disponibles ahora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                value: onlyAvailable,
                onChanged: (value) {
                  setModalState(() {
                    onlyAvailable = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Filtro por tipo
              const Text(
                'Tipo de cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<bool?>(
                    title: const Text('Todos'),
                    value: null,
                    groupValue: onlyBusiness,
                    onChanged: (value) {
                      setModalState(() {
                        onlyBusiness = value;
                      });
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Individuales'),
                    value: false,
                    groupValue: onlyBusiness,
                    onChanged: (value) {
                      setModalState(() {
                        onlyBusiness = value;
                      });
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Empresas'),
                    value: true,
                    groupValue: onlyBusiness,
                    onChanged: (value) {
                      setModalState(() {
                        onlyBusiness = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Actualizar filtros en ViewModel
                        searchViewModel.updateCategoryFilter(
                          selectedCategories,
                        );
                        searchViewModel.updateRatingFilter(minRating);
                        searchViewModel.updateAvailabilityFilter(onlyAvailable);
                        searchViewModel.updateBusinessFilter(onlyBusiness);

                        // Aplicar filtros
                        searchViewModel.applyFilters();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
