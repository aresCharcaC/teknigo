import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/category_view_model.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/category_grid_item.dart';
import '../../widgets/technician_card.dart';
import '../../screens//search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Cargar categorías y técnicos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      categoryViewModel.loadCategories();

      // Cargar algunos técnicos disponibles
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.loadLocalTechnicians(); // Cambiar este método
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
                'Los más valorados',
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
          Consumer<HomeViewModel>(
            builder: (context, homeViewModel, child) {
              if (homeViewModel.isLoading) {
                return SizedBox(
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }

              if (homeViewModel.hasError) {
                return SizedBox(
                  height: 130,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 36,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar técnicos',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (homeViewModel.topTechnicians.isEmpty) {
                return SizedBox(
                  height: 130,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.handyman_outlined,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay técnicos disponibles en tu ciudad',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 130, // Altura reducida
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeViewModel.topTechnicians.length,
                  itemBuilder: (context, index) {
                    return TechnicianCard(
                      technician: homeViewModel.topTechnicians[index],
                      onTap: () {
                        // Acción al tocar la tarjeta
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ver perfil de ${homeViewModel.topTechnicians[index].name}',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SearchScreen(
                                initialCategory:
                                    categoryViewModel
                                        .filteredCategories[index]
                                        .id,
                              ),
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
