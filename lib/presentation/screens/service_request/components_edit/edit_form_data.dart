// lib/presentation/screens/service_request/components_edit/edit_form_data.dart - TOTALMENTE CORREGIDO
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/service_request_model.dart';

/// Clase para manejar todos los datos del formulario de edición
/// Evita setState durante build y centraliza la lógica
class EditFormData {
  // Controladores de texto
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Estados del formulario - USANDO VARIABLES PRIVADAS CON GETTERS/SETTERS SEGUROS
  List<String> _selectedCategories = [];
  bool _isUrgent = false;
  bool _inClientLocation = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  List<String> _photoUrls = [];
  List<File> _photoFiles = [];
  LatLng? _selectedLocation;
  bool _isSubmitting = false;
  bool _isDisposed = false;

  // GETTERS SEGUROS
  List<String> get selectedCategories => List<String>.from(_selectedCategories);
  bool get isUrgent => _isUrgent;
  bool get inClientLocation => _inClientLocation;
  DateTime? get scheduledDate => _scheduledDate;
  TimeOfDay? get scheduledTime => _scheduledTime;
  List<String> get photoUrls => List<String>.from(_photoUrls);
  List<File> get photoFiles => List<File>.from(_photoFiles);
  LatLng? get selectedLocation => _selectedLocation;
  bool get isSubmitting => _isSubmitting;
  bool get isDisposed => _isDisposed;

  // Constructor desde ServiceRequestModel
  EditFormData.fromRequest(ServiceRequestModel request) {
    print('EditFormData: Creando desde request ${request.id}');

    titleController.text = request.title;
    descriptionController.text = request.description;

    // COPIAS PROFUNDAS SEGURAS
    _selectedCategories = List<String>.from(request.categoryIds);
    _isUrgent = request.isUrgent;
    _inClientLocation = request.inClientLocation;
    _scheduledDate = request.scheduledDate;
    addressController.text = request.address ?? '';
    _selectedLocation = request.location;

    // Copia profunda de fotos para evitar referencias compartidas
    _photoUrls =
        request.photos != null
            ? List<String>.from(request.photos!)
            : <String>[];
    _photoFiles = <File>[]; // Siempre inicia vacío

    if (request.scheduledDate != null) {
      _scheduledTime = TimeOfDay.fromDateTime(request.scheduledDate!);
    }

    print(
      'EditFormData: Inicializado con ${_selectedCategories.length} categorías y ${_photoUrls.length} fotos',
    );
  }

  // MÉTODOS DE ACTUALIZACIÓN SEGUROS
  void updateCategories(List<String> categories) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updateCategories - disposed');
      return;
    }

    print('EditFormData: Actualizando categorías: ${categories.length}');
    _selectedCategories = List<String>.from(categories);
  }

  void updateUrgency(bool urgent) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updateUrgency - disposed');
      return;
    }

    print('EditFormData: Actualizando urgencia: $urgent');
    _isUrgent = urgent;
  }

  void updateLocation(bool clientLocation) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updateLocation - disposed');
      return;
    }

    print('EditFormData: Actualizando ubicación: $clientLocation');
    _inClientLocation = clientLocation;
    if (!clientLocation) {
      addressController.clear();
      _selectedLocation = null;
    }
  }

  void updateAddress(String address) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updateAddress - disposed');
      return;
    }

    // Solo actualizar si es diferente para evitar bucles
    if (addressController.text != address) {
      print('EditFormData: Actualizando dirección: $address');
      addressController.text = address;
    }
  }

  void updateSelectedLocation(LatLng? location) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updateSelectedLocation - disposed');
      return;
    }

    print('EditFormData: Actualizando ubicación seleccionada: $location');
    _selectedLocation = location;
  }

  void updatePhotoUrls(List<String> urls) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updatePhotoUrls - disposed');
      return;
    }

    print('EditFormData: Actualizando URLs de fotos: ${urls.length}');
    // Copia profunda para evitar referencias compartidas
    _photoUrls = List<String>.from(urls);
  }

  void updatePhotoFiles(List<File> files) {
    if (_isDisposed) {
      print('EditFormData: Ignorando updatePhotoFiles - disposed');
      return;
    }

    print('EditFormData: Actualizando archivos de fotos: ${files.length}');
    // Copia profunda para evitar referencias compartidas
    _photoFiles = List<File>.from(files);
  }

  void setSubmitting(bool submitting) {
    if (_isDisposed && submitting) {
      print('EditFormData: Ignorando setSubmitting(true) - disposed');
      return;
    }

    print('EditFormData: Actualizando submitting: $submitting');
    _isSubmitting = submitting;
  }

  // MÉTODO PARA MARCAR COMO DISPOSED
  void markDisposed() {
    print('EditFormData: Marcando como disposed');
    _isDisposed = true;
  }

  // Validaciones
  String? validate() {
    if (_isDisposed) {
      return 'Formulario no disponible';
    }

    if (_inClientLocation && addressController.text.trim().isEmpty) {
      return 'Ingresa una dirección para el servicio en tu ubicación';
    }

    if (_selectedCategories.isEmpty) {
      return 'Selecciona al menos una categoría';
    }

    return null; // Sin errores
  }

  // Convertir a ServiceRequestModel - MÉTODO SEGURO
  ServiceRequestModel toServiceRequest(ServiceRequestModel original) {
    if (_isDisposed) {
      print(
        'EditFormData: Intentando convertir un FormData disposed, retornando original',
      );
      return original;
    }

    print('EditFormData: Convirtiendo a ServiceRequestModel');

    try {
      return original.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        categoryIds: List<String>.from(_selectedCategories), // Copia profunda
        isUrgent: _isUrgent,
        inClientLocation: _inClientLocation,
        address: _inClientLocation ? addressController.text.trim() : null,
        location: _inClientLocation ? _selectedLocation : null,
        scheduledDate: _scheduledDate,
        photos:
            _photoUrls.isEmpty
                ? null
                : List<String>.from(_photoUrls), // Copia profunda
      );
    } catch (e) {
      print('EditFormData: Error convirtiendo a ServiceRequestModel: $e');
      return original;
    }
  }

  // Limpiar recursos - MÉTODO MEJORADO
  void dispose() {
    print('EditFormData: Iniciando dispose()');

    // Marcar como disposed PRIMERO
    _isDisposed = true;

    try {
      // Limpiar controladores de forma segura
      titleController.dispose();
      descriptionController.dispose();
      addressController.dispose();

      // Limpiar listas
      _selectedCategories.clear();
      _photoUrls.clear();
      _photoFiles.clear();

      print('EditFormData: Dispose completado exitosamente');
    } catch (e) {
      print('EditFormData: Error durante dispose: $e');
    }
  }
}
