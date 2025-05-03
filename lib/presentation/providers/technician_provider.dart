// lib/presentation/providers/technician_provider.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../../data/repositories/technician_repository.dart';

class TechnicianProvider extends ChangeNotifier {
  final TechnicianRepository _repository = TechnicianRepository();

  bool _isLoading = false;
  Map<String, dynamic> _technicianData = {};
  File? _profileImageFile;
  File? _businessImageFile;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic> get technicianData => _technicianData;
  File? get profileImageFile => _profileImageFile;
  File? get businessImageFile => _businessImageFile;

  // Constructor
  TechnicianProvider() {
    loadTechnicianData();
  }

  // Cargar datos del técnico
  Future<void> loadTechnicianData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _repository.getTechnicianProfile();
      if (data != null) {
        _technicianData = data;
      }
    } catch (e) {
      print('Error al cargar datos del técnico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar datos del técnico
  Future<bool> updateTechnicianProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.updateTechnicianProfile(data);

      if (success) {
        // Actualizar datos locales
        _technicianData = {..._technicianData, ...data};
      }

      return success;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
  Future<bool> uploadProfileImage() async {
    if (_profileImageFile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final url = await _repository.uploadProfileImage(_profileImageFile!);

      if (url != null) {
        _technicianData['profileImage'] = url;
        _profileImageFile = null;
        return true;
      }

      return false;
    } catch (e) {
      print('Error al subir imagen de perfil: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subir imagen de negocio
  Future<bool> uploadBusinessImage() async {
    if (_businessImageFile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final url = await _repository.uploadBusinessImage(_businessImageFile!);

      if (url != null) {
        _technicianData['businessImage'] = url;
        _businessImageFile = null;
        return true;
      }

      return false;
    } catch (e) {
      print('Error al subir imagen de negocio: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar ubicación
  Future<bool> updateLocation(
    LatLng location,
    String address,
    double radius,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.updateLocation(
        location,
        address,
        radius,
      );

      if (success) {
        _technicianData['location'] = {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
        _technicianData['address'] = address;
        _technicianData['coverageRadius'] = radius;
      }

      return success;
    } catch (e) {
      print('Error al actualizar ubicación: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
