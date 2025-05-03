import 'package:flutter/material.dart';
import '../../data/repositories/category_repository.dart';
import '../../core/models/category_model.dart';
import '../common/base_view_model.dart';

/// ViewModel para gestionar las categorías de servicios
class CategoryViewModel extends BaseViewModel {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<CategoryModel> _filteredCategories = [];
  List<CategoryModel> get filteredCategories => _filteredCategories;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Cargar categorías desde el repositorio
  Future<void> loadCategories() async {
    return executeAsync<void>(() async {
      final result = await _repository.getCategories();
      _categories = result;
      _filteredCategories = List.from(_categories);
    });
  }

  // Obtener categorías como stream (para actualización en tiempo real)
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _repository.getCategoriesStream();
  }

  // Buscar categorías por nombre o tags
  void searchCategories(String query) {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _filteredCategories = List.from(_categories);
      notifyListeners();
      return;
    }

    // Filtrar localmente
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

    notifyListeners();
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchQuery = '';
    _filteredCategories = List.from(_categories);
    notifyListeners();
  }

  // Obtener una categoría por su ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      setLoading();

      final category = await _repository.getCategoryById(id);

      setLoaded();
      return category;
    } catch (e) {
      setError('Error al obtener categoría: $e');
      return null;
    }
  }

  // Obtener un icono de Flutter basado en el nombre
  IconData getIconFromName(String iconName) {
    switch (iconName) {
      case 'electrical_services':
        return Icons.electrical_services;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'plumbing':
        return Icons.plumbing;
      case 'thermostat':
        return Icons.thermostat;
      case 'computer':
        return Icons.computer;
      case 'smartphone':
        return Icons.smartphone;
      case 'wifi':
        return Icons.wifi;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'air':
        return Icons.air;
      case 'key':
        return Icons.key;
      case 'security':
        return Icons.security;
      case 'carpenter':
        return Icons.carpenter;
      case 'chair':
        return Icons.chair;
      case 'build':
        return Icons.build;
      case 'construction':
        return Icons.construction;
      case 'format_paint':
        return Icons.format_paint;
      case 'grass':
        return Icons.grass;
      case 'park':
        return Icons.park;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'clean_hands':
        return Icons.clean_hands;
      case 'car_repair':
        return Icons.car_repair;
      case 'tire_repair':
        return Icons.tire_repair;
      case 'memory':
        return Icons.memory;
      case 'microwave':
        return Icons.microwave;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'home':
        return Icons.home;
      case 'pool':
        return Icons.pool;
      case 'checkroom':
        return Icons.checkroom;
      case 'window':
        return Icons.window;
      case 'roofing':
        return Icons.roofing;
      case 'pest_control':
        return Icons.pest_control;
      case 'solar_power':
        return Icons.solar_power;
      case 'gas_meter':
        return Icons.gas_meter;
      case 'weekend':
        return Icons.weekend;
      case 'elderly':
        return Icons.elderly;
      case 'spa':
        return Icons.spa;
      case 'celebration':
        return Icons.celebration;
      default:
        return Icons.category; // Icono por defecto
    }
  }
}
