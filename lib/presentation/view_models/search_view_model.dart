import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../common/base_view_model.dart';

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
  // Search query
  String _query = '';
  String get query => _query;

  // Filters
  String _selectedCategory = 'Todas';
  String get selectedCategory => _selectedCategory;

  double _maxDistance = AppConstants.defaultCoverageRadius;
  double get maxDistance => _maxDistance;

  double _minRating = 3.0;
  double get minRating => _minRating;

  // Check if any filters are active
  bool get hasActiveFilters =>
      _selectedCategory != 'Todas' ||
      _maxDistance < AppConstants.defaultCoverageRadius ||
      _minRating > 3.0;

  // Mock data for technicians
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

  // Initialize the ViewModel
  void initialize() {
    executeSync(() {
      _filteredTechnicians = List.from(_technicians);
    });
  }

  // Update search query
  void updateQuery(String query) {
    _query = query.toLowerCase().trim();
    _filterTechnicians();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _query = '';
    _filterTechnicians();
    notifyListeners();
  }

  // Update all filters at once
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

  // Update category filter
  void updateCategory(String category) {
    _selectedCategory = category;
    _filterTechnicians();
    notifyListeners();
  }

  // Update max distance filter
  void updateMaxDistance(double distance) {
    _maxDistance = distance;
    _filterTechnicians();
    notifyListeners();
  }

  // Update min rating filter
  void updateMinRating(double rating) {
    _minRating = rating;
    _filterTechnicians();
    notifyListeners();
  }

  // Apply search and filters
  void searchTechnicians() {
    _filterTechnicians();
    notifyListeners();
  }

  // Filter technicians based on criteria
  void _filterTechnicians() {
    executeSync(() {
      _filteredTechnicians =
          _technicians.where((technician) {
            // Filter by search query
            final matchesQuery =
                _query.isEmpty ||
                technician.name.toLowerCase().contains(_query) ||
                technician.specialty.toLowerCase().contains(_query);

            // Filter by category
            final matchesCategory =
                _selectedCategory == 'Todas' ||
                technician.specialty == _selectedCategory;

            // Filter by distance
            final matchesDistance = technician.distance <= _maxDistance;

            // Filter by rating
            final matchesRating = technician.rating >= _minRating;

            return matchesQuery &&
                matchesCategory &&
                matchesDistance &&
                matchesRating;
          }).toList();
    });
  }
}
