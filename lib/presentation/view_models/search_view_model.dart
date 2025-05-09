import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../common/base_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/technician_search_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/search_repository.dart';

/// Model for technician search results
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

/// ViewModel for the search screen
class SearchViewModel extends BaseViewModel {
  final SearchRepository _searchRepository = SearchRepository();
  final AuthRepository _authRepository = AuthRepository();

  // Datos para la búsqueda
  String _userCity = '';
  String get userCity => _userCity;

  String _searchText = '';
  String get searchText => _searchText;

  List<String> _selectedCategories = [];
  List<String> get selectedCategories => _selectedCategories;

  double _minRating = 0.0;
  double get minRating => _minRating;

  bool _onlyAvailable = false;
  bool get onlyAvailable => _onlyAvailable;

  bool? _onlyBusiness;
  bool? get onlyBusiness => _onlyBusiness;

  // Resultados
  List<TechnicianSearchModel> _searchResults = [];
  List<TechnicianSearchModel> get searchResults => _searchResults;

  // Control de paginación
  DocumentSnapshot? _lastDocument;
  bool _hasMoreResults = true;
  bool get hasMoreResults => _hasMoreResults;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // Inicializar con la ciudad del usuario
  Future<void> initialize() async {
    return executeAsync<void>(() async {
      // Obtener datos del usuario
      final userData = await _authRepository.getUserData();

      // Obtener la ciudad (con valor por defecto)
      _userCity = userData?['city'] ?? 'Arequipa';

      // Realizar búsqueda inicial
      await searchTechnicians();
    });
  }

  // Actualizar texto de búsqueda
  void updateSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  // Realizar búsqueda con filtros actuales
  Future<void> searchTechnicians({bool reset = true}) async {
    return executeAsync<void>(() async {
      // Si es una nueva búsqueda, reiniciar paginación
      if (reset) {
        _lastDocument = null;
        _hasMoreResults = true;
        _searchResults = [];
      }

      // No buscar si ya no hay más resultados
      if (!_hasMoreResults && !reset) {
        return;
      }

      // Marcar como cargando más si es paginación
      if (!reset) {
        _isLoadingMore = true;
        notifyListeners();
      }

      // Realizar la búsqueda
      final results = await _searchRepository.searchTechnicians(
        city: _userCity,
        searchTerm: _searchText,
        categoryFilter:
            _selectedCategories.isNotEmpty ? _selectedCategories : null,
        ratingFilter: _minRating > 0 ? _minRating : null,
        availableNowFilter: _onlyAvailable ? true : null,
        businessFilter: _onlyBusiness,
        lastDocument: _lastDocument,
      );

      // Si no hay resultados y es la primera página, no hay más
      if (results.isEmpty && reset) {
        _hasMoreResults = false;
        return;
      }

      // Si hay menos resultados que el límite en paginación, no hay más
      if (results.length < 10 && !reset) {
        _hasMoreResults = false;
      }

      // Actualizar resultados
      if (reset) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
        _isLoadingMore = false;
      }

      // Actualizar último documento para próxima paginación
      if (results.isNotEmpty) {
        _lastDocument = await _searchRepository.getLastDocumentForPagination(
          _userCity,
          reset ? results.length : _searchResults.length,
        );
      }
    });
  }

  // Cargar más resultados (paginación)
  Future<void> loadMoreResults() async {
    if (_isLoadingMore || !_hasMoreResults) return;

    await searchTechnicians(reset: false);
  }

  // Actualizar filtros de categoría
  void updateCategoryFilter(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  // Actualizar filtro de valoración mínima
  void updateRatingFilter(double rating) {
    _minRating = rating;
    notifyListeners();
  }

  // Actualizar filtro de disponibilidad
  void updateAvailabilityFilter(bool onlyAvailable) {
    _onlyAvailable = onlyAvailable;
    notifyListeners();
  }

  // Actualizar filtro de tipo de cuenta
  void updateBusinessFilter(bool? onlyBusiness) {
    _onlyBusiness = onlyBusiness;
    notifyListeners();
  }

  // Aplicar todos los filtros y realizar búsqueda
  Future<void> applyFilters() async {
    await searchTechnicians();
  }

  // Limpiar todos los filtros
  Future<void> clearFilters() async {
    _selectedCategories = [];
    _minRating = 0.0;
    _onlyAvailable = false;
    _onlyBusiness = null;
    notifyListeners();

    await searchTechnicians();
  }
}
