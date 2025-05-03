import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../common/base_view_model.dart';

/// Modelo de datos para un técnico en búsqueda
class TechnicianSearchItem {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final double distance;
  final bool available;
  final String? profileImage;

  TechnicianSearchItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.available,
    this.profileImage,
  });
}

/// ViewModel para manejar la búsqueda de técnicos
class SearchViewModel extends BaseViewModel {
  // Estado de búsqueda
  String _query = '';
  String get query => _query;

  // Filtros
  String _selectedCategory = 'Todas';
  String get selectedCategory => _selectedCategory;

  double _maxDistance = AppConstants.defaultCoverageRadius;
  double get maxDistance => _maxDistance;

  double _minRating = 3.0;
  double get minRating => _minRating;

  // Verificar si hay filtros activos
  bool get hasActiveFilters =>
      _selectedCategory != 'Todas' ||
      _maxDistance < AppConstants.defaultCoverageRadius ||
      _minRating > 3.0;

  // Lista de técnicos (datos simulados)
  final List<TechnicianSearchItem> _technicians = [
    TechnicianSearchItem(
      id: '1',
      name: 'Carlos Rodríguez',
      specialty: 'Electricista',
      rating: 4.8,
      reviews: 124,
      distance: 2.1,
      available: true,
    ),
    TechnicianSearchItem(
      id: '2',
      name: 'María López',
      specialty: 'Técnico PC',
      rating: 4.7,
      reviews: 98,
      distance: 3.4,
      available: true,
    ),
    TechnicianSearchItem(
      id: '3',
      name: 'Juan Pérez',
      specialty: 'Plomero',
      rating: 4.9,
      reviews: 203,
      distance: 1.8,
      available: false,
    ),
    TechnicianSearchItem(
      id: '4',
      name: 'Ana Martínez',
      specialty: 'Refrigeración',
      rating: 4.6,
      reviews: 87,
      distance: 4.2,
      available: true,
    ),
    TechnicianSearchItem(
      id: '5',
      name: 'Roberto Gómez',
      specialty: 'Cerrajero',
      rating: 4.5,
      reviews: 76,
      distance: 5.1,
      available: true,
    ),
    TechnicianSearchItem(
      id: '6',
      name: 'Laura Torres',
      specialty: 'Electricista',
      rating: 4.4,
      reviews: 62,
      distance: 6.3,
      available: true,
    ),
  ];

  List<TechnicianSearchItem> _filteredTechnicians = [];
  List<TechnicianSearchItem> get filteredTechnicians => _filteredTechnicians;

  // Inicializar el ViewModel
  void initialize() {
    executeSync(() {
      _filteredTechnicians = List.from(_technicians);
    });
  }

  // Actualizar consulta de búsqueda
  void updateQuery(String query) {
    _query = query.toLowerCase().trim();
    notifyListeners();
  }

  // Limpiar búsqueda
  void clearSearch() {
    _query = '';
    _filterTechnicians();
    notifyListeners();
  }

  // Actualizar filtros
  void updateFilters({
    required String category,
    required double maxDistance,
    required double minRating,
  }) {
    _selectedCategory = category;
    _maxDistance = maxDistance;
    _minRating = minRating;
    _filterTechnicians();
    notifyListeners();
  }

  // Actualizar categoría
  void updateCategory(String category) {
    _selectedCategory = category;
    _filterTechnicians();
    notifyListeners();
  }

  // Actualizar distancia máxima
  void updateMaxDistance(double distance) {
    _maxDistance = distance;
    _filterTechnicians();
    notifyListeners();
  }

  // Actualizar valoración mínima
  void updateMinRating(double rating) {
    _minRating = rating;
    _filterTechnicians();
    notifyListeners();
  }

  // Realizar búsqueda de técnicos
  void searchTechnicians() {
    _filterTechnicians();
    notifyListeners();
  }

  // Filtrar técnicos según criterios
  void _filterTechnicians() {
    executeSync(() {
      _filteredTechnicians =
          _technicians.where((technician) {
            // Filtrar por texto de búsqueda
            final matchesQuery =
                _query.isEmpty ||
                technician.name.toLowerCase().contains(_query) ||
                technician.specialty.toLowerCase().contains(_query);

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
    });
  }
}
