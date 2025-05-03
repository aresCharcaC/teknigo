import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/technician_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

/// ViewModel para gestionar el perfil y datos del técnico
class TechnicianViewModel extends BaseViewModel {
  final TechnicianRepository _repository = TechnicianRepository();

  // Estado del técnico
  bool _isIndividual = true;
  bool get isIndividual => _isIndividual;

  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  bool _isServicesActive = false;
  bool get isServicesActive => _isServicesActive;

  // Datos del técnico
  Map<String, dynamic> _technicianData = {};
  Map<String, dynamic> get technicianData => _technicianData;

  // Archivos temporales de imagen
  File? _profileImageFile;
  File? get profileImageFile => _profileImageFile;

  File? _businessImageFile;
  File? get businessImageFile => _businessImageFile;

  // Ubicación
  LatLng? _location;
  LatLng? get location => _location;

  String? _address;
  String? get address => _address;

  double _coverageRadius = AppConstants.defaultCoverageRadius;
  double get coverageRadius => _coverageRadius;

  // Categorías seleccionadas
  List<String> _selectedCategories = [];
  List<String> get selectedCategories => _selectedCategories;

  // Habilidades
  List<String> _skills = [];
  List<String> get skills => _skills;

  // Cargar datos del técnico
  Future<void> loadTechnicianProfile() async {
    return executeAsync<void>(() async {
      final data = await _repository.getTechnicianProfile();
      if (data != null) {
        _technicianData = data;
        _isIndividual = data['isIndividual'] ?? true;
        _isServicesActive = data['isServicesActive'] ?? false;
        _isAvailable = data['isAvailable'] ?? true;

        // Extraer ubicación
        if (data['location'] != null) {
          final locationData = data['location'];
          if (locationData is Map<String, dynamic>) {
            // Si location viene como un Map
            if (locationData.containsKey('latitude') &&
                locationData.containsKey('longitude')) {
              _location = LatLng(
                locationData['latitude'] as double,
                locationData['longitude'] as double,
              );
            }
          } else if (locationData.runtimeType.toString() == 'GeoPoint') {
            // Si es un GeoPoint de Firestore
            _location = LatLng(
              (locationData as dynamic).latitude as double,
              (locationData as dynamic).longitude as double,
            );
          }
        }

        _address = data['address'] as String?;
        _coverageRadius =
            data['coverageRadius'] as double? ??
            AppConstants.defaultCoverageRadius;

        // Extraer categorías
        if (data['categories'] != null && data['categories'] is List) {
          _selectedCategories = List<String>.from(data['categories']);
        }

        // Extraer habilidades
        if (data['skills'] != null && data['skills'] is List) {
          _skills = List<String>.from(data['skills']);
        }
      }
    });
  }

  // Actualizar perfil de técnico
  Future<Resource<bool>> updateTechnicianProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      setLoading();

      final success = await _repository.updateTechnicianProfile(data);

      if (success) {
        // Actualizar datos locales
        _technicianData = {..._technicianData, ...data};

        // Actualizar estados si están incluidos
        if (data.containsKey('isIndividual')) {
          _isIndividual = data['isIndividual'];
        }
        if (data.containsKey('isServicesActive')) {
          _isServicesActive = data['isServicesActive'];
        }
        if (data.containsKey('isAvailable')) {
          _isAvailable = data['isAvailable'];
        }
        if (data.containsKey('categories')) {
          _selectedCategories = List<String>.from(data['categories']);
        }
        if (data.containsKey('skills')) {
          _skills = List<String>.from(data['skills']);
        }
      }

      setLoaded();
      return Resource.success(success);
    } catch (e) {
      final errorMessage = 'Error al actualizar perfil: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Establecer imagen de perfil temporal
  void setProfileImageFile(File? file) {
    _profileImageFile = file;
    notifyListeners();
  }

  // Establecer imagen de negocio temporal
  void setBusinessImageFile(File? file) {
    _businessImageFile = file;
    notifyListeners();
  }

  // Subir imagen de perfil
  Future<Resource<String?>> uploadProfileImage(File imageFile) async {
    try {
      setLoading();

      final url = await _repository.uploadProfileImage(imageFile);

      if (url != null) {
        _technicianData['profileImage'] = url;
        _profileImageFile = null;
      }

      setLoaded();
      return Resource.success(url);
    } catch (e) {
      final errorMessage = 'Error al subir imagen de perfil: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Subir imagen de negocio
  Future<Resource<String?>> uploadBusinessImage(File imageFile) async {
    try {
      setLoading();

      final url = await _repository.uploadBusinessImage(imageFile);

      if (url != null) {
        _technicianData['businessImage'] = url;
        _businessImageFile = null;
      }

      setLoaded();
      return Resource.success(url);
    } catch (e) {
      final errorMessage = 'Error al subir imagen de negocio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Actualizar ubicación
  Future<Resource<bool>> updateLocation(
    LatLng location,
    String address,
    double radius,
  ) async {
    try {
      setLoading();

      final success = await _repository.updateLocation(
        location,
        address,
        radius,
      );

      if (success) {
        _location = location;
        _address = address;
        _coverageRadius = radius;
        _technicianData['address'] = address;
        _technicianData['coverageRadius'] = radius;
      }

      setLoaded();
      return Resource.success(success);
    } catch (e) {
      final errorMessage = 'Error al actualizar ubicación: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Actualizar categorías seleccionadas
  void updateSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  // Actualizar habilidades
  void updateSkills(List<String> skills) {
    _skills = skills;
    notifyListeners();
  }

  // Actualizar tipo de técnico (individual o empresa)
  void updateTechnicianType(bool isIndividual) {
    _isIndividual = isIndividual;
    notifyListeners();
  }

  // Actualizar disponibilidad
  void updateAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
    notifyListeners();
  }

  // Activar/desactivar servicios
  void updateServicesActive(bool isActive) {
    _isServicesActive = isActive;
    notifyListeners();
  }
}
