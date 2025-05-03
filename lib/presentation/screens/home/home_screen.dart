import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/category_view_model.dart';
import '../../widgets/category_grid_item.dart';
import '../../widgets/technician_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    // Cargar categorías al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      categoryViewModel.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Filtrar categorías cuando se busca
  void _onSearchChanged() {
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );
    categoryViewModel.searchCategories(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de técnicos mejor valorados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Técnicos mejor valorados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de todos los técnicos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Ver todos los técnicos'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lista horizontal de técnicos mejor valorados
          SizedBox(
            height: 130, // Altura reducida
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topTechnicians.length,
              itemBuilder: (context, index) {
                return TechnicianCard(technician: _topTechnicians[index]);
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
                suffixIcon: Consumer<CategoryViewModel>(
                  builder: (context, categoryViewModel, child) {
                    return categoryViewModel.searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            categoryViewModel.clearSearch();
                          },
                        )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título de categorías
          const Text(
            'Categorías',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Grid de categorías
          Consumer<CategoryViewModel>(
            builder: (context, categoryViewModel, child) {
              if (categoryViewModel.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (categoryViewModel.filteredCategories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron categorías',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otra búsqueda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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
                  childAspectRatio: 0.75, // Hacer las tarjetas más altas
                ),
                itemCount: categoryViewModel.filteredCategories.length,
                itemBuilder: (context, index) {
                  return CategoryGridItem(
                    category: categoryViewModel.filteredCategories[index],
                    onTap: () {
                      // Navegar a la pantalla de búsqueda con esta categoría
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Categoría: ${categoryViewModel.filteredCategories[index].name}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
