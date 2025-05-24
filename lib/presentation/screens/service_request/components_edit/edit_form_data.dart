// lib/presentation/screens/service_request/components_edit/edit_form_data.dart
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

  // Estados del formulario
  List<String> selectedCategories = [];
  bool isUrgent = false;
  bool inClientLocation = true;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  List<String> photoUrls = [];
  List<File> photoFiles = [];
  LatLng? selectedLocation;
  bool isSubmitting = false;

  // Constructor desde ServiceRequestModel
  EditFormData.fromRequest(ServiceRequestModel request) {
    titleController.text = request.title;
    descriptionController.text = request.description;
    selectedCategories = List.from(request.categoryIds);
    isUrgent = request.isUrgent;
    inClientLocation = request.inClientLocation;
    scheduledDate = request.scheduledDate;
    addressController.text = request.address ?? '';
    selectedLocation = request.location;

    // Hacer una copia profunda de las fotos para evitar referencias compartidas
    photoUrls =
        request.photos != null ? List<String>.from(request.photos!) : [];

    if (request.scheduledDate != null) {
      scheduledTime = TimeOfDay.fromDateTime(request.scheduledDate!);
    }
  }

  // Métodos para actualizar estado - Ahora más seguros
  void updateCategories(List<String> categories) {
    selectedCategories = List<String>.from(categories); // Copia profunda
  }

  void updateUrgency(bool urgent) {
    isUrgent = urgent;
  }

  void updateLocation(bool clientLocation) {
    inClientLocation = clientLocation;
    if (!clientLocation) {
      addressController.clear();
      selectedLocation = null;
    }
  }

  void updateAddress(String address) {
    // Solo actualizar si es diferente
    if (addressController.text != address) {
      addressController.text = address;
    }
  }

  void updateSelectedLocation(LatLng? location) {
    selectedLocation = location;
  }

  void updatePhotoUrls(List<String> urls) {
    // Hacer copia profunda para evitar referencias compartidas
    photoUrls = List<String>.from(urls);
  }

  void updatePhotoFiles(List<File> files) {
    // Hacer copia profunda para evitar referencias compartidas
    photoFiles = List<File>.from(files);
  }

  void setSubmitting(bool submitting) {
    isSubmitting = submitting;
  }

  // Validaciones
  String? validate() {
    if (inClientLocation && addressController.text.trim().isEmpty) {
      return 'Ingresa una dirección para el servicio en tu ubicación';
    }

    if (selectedCategories.isEmpty) {
      return 'Selecciona al menos una categoría';
    }

    return null; // Sin errores
  }

  // Convertir a ServiceRequestModel
  ServiceRequestModel toServiceRequest(ServiceRequestModel original) {
    return original.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      categoryIds: List<String>.from(selectedCategories), // Copia profunda
      isUrgent: isUrgent,
      inClientLocation: inClientLocation,
      address: inClientLocation ? addressController.text.trim() : null,
      location: inClientLocation ? selectedLocation : null,
      scheduledDate: scheduledDate,
      photos:
          photoUrls.isEmpty
              ? null
              : List<String>.from(photoUrls), // Copia profunda
    );
  }

  // Limpiar recursos
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
  }
}
