// lib/presentation/screens/home/components/service_request_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../view_models/category_view_model.dart';
import '../../../view_models/service_request_view_model.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../../screens/technician/location_picker_screen.dart';
import 'category_selector.dart';
import 'location_input.dart';
import 'photo_picker.dart';

class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm({Key? key}) : super(key: key);

  @override
  _ServiceRequestFormState createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  late final LocationService _locationService;
  late final MapsService _mapsService;

  // Use ValueNotifier instead of setState for each field that needs to be reactive
  final _selectedCategories = ValueNotifier<List<String>>([]);
  final _isUrgent = ValueNotifier<bool>(false);
  final _inClientLocation = ValueNotifier<bool>(true);
  final _scheduledDate = ValueNotifier<DateTime?>(null);
  final _scheduledTime = ValueNotifier<TimeOfDay?>(null);
  final _photoUrls = ValueNotifier<List<String>>([]);
  final _photoFiles = ValueNotifier<List<File>>([]);
  final _selectedLocation = ValueNotifier<LatLng?>(null);
  final _isSubmitting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _mapsService = MapsService();
  }

  @override
  void dispose() {
    // Clean up all controllers and listeners
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();

    // Dispose all value notifiers
    _selectedCategories.dispose();
    _isUrgent.dispose();
    _inClientLocation.dispose();
    _scheduledDate.dispose();
    _scheduledTime.dispose();
    _photoUrls.dispose();
    _photoFiles.dispose();
    _selectedLocation.dispose();
    _isSubmitting.dispose();

    super.dispose();
  }

  // Submit the form - No setState calls
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields based on location
      if (_inClientLocation.value && _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ingresa una dirección para el servicio en tu ubicación',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedCategories.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos una categoría'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      _isSubmitting.value = true;

      try {
        // Get current user
        final authViewModel = Provider.of<AuthViewModel>(
          context,
          listen: false,
        );
        final currentUser = authViewModel.currentUser;
        final userId = currentUser?.uid ?? '';

        if (userId.isEmpty) {
          throw Exception('Usuario no autenticado');
        }

        // Create service request object
        final serviceRequest = ServiceRequestModel.create(
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryIds: _selectedCategories.value,
          isUrgent: _isUrgent.value,
          inClientLocation: _inClientLocation.value,
          address:
              _inClientLocation.value ? _addressController.text.trim() : null,
          location: _inClientLocation.value ? _selectedLocation.value : null,
          scheduledDate: _scheduledDate.value,
          photos: _photoUrls.value.isEmpty ? null : _photoUrls.value,
        );

        // Access the ViewModel to create the request
        final requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );

        // Send request with photos
        final result = await requestViewModel.createServiceRequest(
          serviceRequest,
          _photoFiles.value.isEmpty
              ? null
              : _photoFiles.value, // Pass photo files
        );

        if (result.isSuccess) {
          // Reset form
          _resetForm();

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud creada correctamente'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${result.error}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear la solicitud: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          _isSubmitting.value = false;
        }
      }
    }
  }

  // Reset form - No setState calls
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();

    _selectedCategories.value = [];
    _isUrgent.value = false;
    _inClientLocation.value = true;
    _scheduledDate.value = null;
    _scheduledTime.value = null;
    _photoUrls.value = [];
    _photoFiles.value = [];
    _selectedLocation.value = null;
  }

  // Get current location - No setState calls
  Future<void> _getCurrentLocation() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get current location
      final location = await _mapsService.getCurrentLocation();

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (location != null && mounted) {
        _selectedLocation.value = location;

        // Get address from coordinates
        final address = await _locationService.getAddressFromLatLng(location);
        if (address != null && mounted) {
          _addressController.text = address;
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener tu ubicación actual'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator on error
      if (mounted) Navigator.pop(context);

      print('Error al obtener ubicación: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Open location picker - No setState calls
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationPickerScreen(
              initialPosition: _selectedLocation.value,
              coverageRadius: 5.0, // Default radius for clients
            ),
      ),
    );

    if (result != null &&
        result.containsKey('position') &&
        result.containsKey('address') &&
        mounted) {
      final position = result['position'];
      final address = result['address'] as String;

      if (position is LatLng) {
        _selectedLocation.value = position;
        _addressController.text = address;
      }
    }
  }

  // Handle photo selection - No setState calls
  void _handlePhotosSelected(List<File> photos) {
    if (mounted) {
      _photoFiles.value = photos;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using ValueListenableBuilder to rebuild only the parts that change
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Solicitar Servicio Técnico',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Reparación de refrigerador',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (value.length < 5) {
                    return 'El título debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del problema',
                  hintText: 'Describe tu problema con detalle',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category selector with ValueListenableBuilder
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ValueListenableBuilder<List<String>>(
                valueListenable: _selectedCategories,
                builder: (context, selectedCategories, child) {
                  return CategorySelector(
                    selectedCategories: selectedCategories,
                    onCategoriesChanged: (categories) {
                      _selectedCategories.value = categories;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Urgency checkbox with ValueListenableBuilder
              ValueListenableBuilder<bool>(
                valueListenable: _isUrgent,
                builder: (context, isUrgent, child) {
                  return CheckboxListTile(
                    title: const Text('Urgente (solicito servicio para hoy)'),
                    value: isUrgent,
                    onChanged: (value) {
                      _isUrgent.value = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Service location selector
              const Text(
                'Ubicación del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Location radio buttons with ValueListenableBuilder
              ValueListenableBuilder<bool>(
                valueListenable: _inClientLocation,
                builder: (context, inClientLocation, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('En tu ubicación'),
                          value: true,
                          groupValue: inClientLocation,
                          onChanged: (value) {
                            _inClientLocation.value = value!;
                          },
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('En local del técnico'),
                          value: false,
                          groupValue: inClientLocation,
                          onChanged: (value) {
                            _inClientLocation.value = value!;
                            // Clear address if switched to technician location
                            if (value == false) {
                              _addressController.clear();
                            }
                          },
                          dense: true,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Show address field if service location is client location
              ValueListenableBuilder<bool>(
                valueListenable: _inClientLocation,
                builder: (context, inClientLocation, child) {
                  if (inClientLocation) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: LocationInput(
                        controller: _addressController,
                        onGetLocation: _getCurrentLocation,
                        onOpenMap: _openLocationPicker,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 16),

              // Photos with ValueListenableBuilder
              ValueListenableBuilder<List<String>>(
                valueListenable: _photoUrls,
                builder: (context, photoUrls, child) {
                  return PhotoPicker(
                    photoUrls: photoUrls,
                    onPhotosChanged: (urls) {
                      _photoUrls.value = urls;
                    },
                    onFilesSelected: _handlePhotosSelected,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Submit button with ValueListenableBuilder for isSubmitting
              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    return ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isSubmitting
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'PUBLICAR SOLICITUD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
