// lib/presentation/view_models/technician_view_model.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/working_hours.dart';
import '../../core/models/social_link.dart';
import '../../data/repositories/technician_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

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

  // Tipo de servicio
  bool _serviceAtHome = true;
  bool get serviceAtHome => _serviceAtHome;

  bool _serviceAtOffice = false;
  bool get serviceAtOffice => _serviceAtOffice;

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

  List<SocialLink> _socialLinks = [];
  List<SocialLink> get socialLinks => _socialLinks;

  // Horario de trabajo
  List<WorkingHours> _workingHours = [];
  List<WorkingHours> get workingHours => _workingHours;

  // Cargar datos del técnico
  Future<void> loadTechnicianProfile() async {
    return executeAsync<void>(() async {
      final data = await _repository.getTechnicianProfile();
      if (data != null) {
        _technicianData = data;
        _isIndividual = data['isIndividual'] ?? true;
        _isServicesActive = data['isServicesActive'] ?? false;
        _isAvailable = data['isAvailable'] ?? true;
        _serviceAtHome = data['serviceAtHome'] ?? true;
        _serviceAtOffice = data['serviceAtOffice'] ?? false;

        // Extraer ubicación
        if (data['location'] != null) {
          // Si location es un GeoPoint de Firestore
          try {
            if (data['location'] is Map) {
              final double lat =
                  data['location']['latitude'] is num
                      ? (data['location']['latitude'] as num).toDouble()
                      : 0.0;
              final double lng =
                  data['location']['longitude'] is num
                      ? (data['location']['longitude'] as num).toDouble()
                      : 0.0;
              _location = LatLng(lat, lng);
            } else if (data['location'].toString().contains('GeoPoint')) {
              // Si es un GeoPoint directamente
              final lat = data['location'].latitude;
              final lng = data['location'].longitude;
              _location = LatLng(lat, lng);
            }
          } catch (e) {
            print('Error extracting location: $e');
            _location = null;
          }
        }

        _address = data['address'] as String?;
        _coverageRadius =
            data['coverageRadius'] as double? ??
            AppConstants.defaultCoverageRadius;

        // Extraer categorías
        if (data['categories'] != null && data['categories'] is List) {
          _selectedCategories = List<String>.from(data['categories']);
        } else {
          _selectedCategories = [];
        }

        // Extraer habilidades
        if (data['skills'] != null && data['skills'] is List) {
          _skills = List<String>.from(data['skills']);
        } else {
          _skills = [];
        }

        // Extraer redes sociales
        if (data['socialLinks'] != null && data['socialLinks'] is List) {
          try {
            _socialLinks =
                (data['socialLinks'] as List)
                    .map(
                      (item) =>
                          SocialLink.fromMap(Map<String, dynamic>.from(item)),
                    )
                    .toList();
          } catch (e) {
            print('Error extracting social links: $e');
            _socialLinks = [];
          }
        } else {
          _socialLinks = [];
        }

        // Extraer horario de trabajo
        if (data['workingHours'] != null && data['workingHours'] is List) {
          try {
            _workingHours =
                (data['workingHours'] as List)
                    .map(
                      (item) =>
                          WorkingHours.fromMap(Map<String, dynamic>.from(item)),
                    )
                    .toList();
          } catch (e) {
            print('Error extracting working hours: $e');
            _initDefaultWorkingHours();
          }
        } else {
          _initDefaultWorkingHours();
        }
      }
    });
  }

  // Inicializar horario de trabajo por defecto
  void _initDefaultWorkingHours() {
    _workingHours = [
      WorkingHours(day: 'Lunes', timeRange: '8:00 - 18:00', isAvailable: true),
      WorkingHours(day: 'Martes', timeRange: '8:00 - 18:00', isAvailable: true),
      WorkingHours(
        day: 'Miércoles',
        timeRange: '8:00 - 18:00',
        isAvailable: true,
      ),
      WorkingHours(day: 'Jueves', timeRange: '8:00 - 18:00', isAvailable: true),
      WorkingHours(
        day: 'Viernes',
        timeRange: '8:00 - 18:00',
        isAvailable: true,
      ),
      WorkingHours(day: 'Sábado', timeRange: '9:00 - 13:00', isAvailable: true),
      WorkingHours(day: 'Domingo', timeRange: '', isAvailable: false),
    ];
  }

  // Actualizar perfil de técnico
  Future<Resource<bool>> updateTechnicianProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      setLoading();

      // Convertir horarios a Map si corresponde
      if (data.containsKey('workingHours') &&
          data['workingHours'] is List<WorkingHours>) {
        data['workingHours'] =
            (data['workingHours'] as List<WorkingHours>)
                .map((h) => h.toMap())
                .toList();
      }

      // Añadir campos adicionales
      if (!data.containsKey('serviceAtHome')) {
        data['serviceAtHome'] = _serviceAtHome;
      }
      if (!data.containsKey('serviceAtOffice')) {
        data['serviceAtOffice'] = _serviceAtOffice;
      }

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
        if (data.containsKey('serviceAtHome')) {
          _serviceAtHome = data['serviceAtHome'];
        }
        if (data.containsKey('serviceAtOffice')) {
          _serviceAtOffice = data['serviceAtOffice'];
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

  // Eliminar imagen de perfil
  Future<Resource<bool>> removeProfileImage() async {
    try {
      setLoading();

      bool success = false;
      if (_technicianData.containsKey('profileImage') &&
          _technicianData['profileImage'] != null) {
        success = await _repository.removeProfileImage();
        if (success) {
          _technicianData['profileImage'] = null;
        }
      }

      setLoaded();
      return Resource.success(success);
    } catch (e) {
      final errorMessage = 'Error al eliminar imagen de perfil: $e';
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

  // Eliminar imagen de negocio
  Future<Resource<bool>> removeBusinessImage() async {
    try {
      setLoading();

      bool success = false;
      if (_technicianData.containsKey('businessImage') &&
          _technicianData['businessImage'] != null) {
        success = await _repository.removeBusinessImage();
        if (success) {
          _technicianData['businessImage'] = null;
        }
      }

      setLoaded();
      return Resource.success(success);
    } catch (e) {
      final errorMessage = 'Error al eliminar imagen de negocio: $e';
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

      // Actualizar primero los datos locales para evitar problemas de sincronización
      _location = location;
      _address = address;
      _coverageRadius = radius;

      // Actualizar también en technicianData (mantenemos el formato como Map por consistencia)
      _technicianData['location'] = {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
      _technicianData['address'] = address;
      _technicianData['coverageRadius'] = radius;

      // Luego enviar al repositorio
      final success = await _repository.updateLocation(
        location,
        address,
        radius,
      );

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

  // Actualizar redes sociales
  void updateSocialLinks(List<SocialLink> links) {
    _socialLinks = links;
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

  // Activar/desactivar servicio a domicilio
  void toggleServiceAtHome(bool value) {
    _serviceAtHome = value;
    notifyListeners();
  }

  // Activar/desactivar servicio en local
  void toggleServiceAtOffice(bool value) {
    _serviceAtOffice = value;
    notifyListeners();
  }

  // Actualizar horario de trabajo
  void updateWorkingHours(List<WorkingHours> hours) {
    _workingHours = hours;
    notifyListeners();
  }

  // Actualizar un día específico del horario
  void updateWorkingDay(int index, WorkingHours updatedDay) {
    if (index >= 0 && index < _workingHours.length) {
      _workingHours[index] = updatedDay;
      notifyListeners();
    }
  }
}
