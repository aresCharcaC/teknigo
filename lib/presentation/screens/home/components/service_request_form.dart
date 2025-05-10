// lib/presentation/screens/home/components/service_request_form.dart
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
  final LocationService _locationService = LocationService();
  final MapsService _mapsService = MapsService();

  List<String> _selectedCategories = [];
  bool _isUrgent = false;
  bool _inClientLocation = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  List<String> _photoUrls = [];
  LatLng? _selectedLocation;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validar campos requeridos según la ubicación
      if (_inClientLocation && _addressController.text.trim().isEmpty) {
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

      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos una categoría'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Obtener usuario actual
        final authViewModel = Provider.of<AuthViewModel>(
          context,
          listen: false,
        );
        final currentUser = authViewModel.currentUser;
        final userId = currentUser?.uid ?? '';

        if (userId.isEmpty) {
          throw Exception('Usuario no autenticado');
        }

        // Crear objeto de solicitud de servicio
        final serviceRequest = ServiceRequestModel.create(
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryIds: _selectedCategories,
          isUrgent: _isUrgent,
          inClientLocation: _inClientLocation,
          address: _inClientLocation ? _addressController.text.trim() : null,
          location: _inClientLocation ? _selectedLocation : null,
          scheduledDate: _scheduledDate,
          photos: _photoUrls,
        );

        // Acceder al ViewModel para crear la solicitud
        final requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );

        // Enviar solicitud
        final result = await requestViewModel.createServiceRequest(
          serviceRequest,
        );

        if (result.isSuccess) {
          // Resetear formulario
          _resetForm();

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud creada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la solicitud: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Reset form
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();
    setState(() {
      _selectedCategories = [];
      _isUrgent = false;
      _inClientLocation = true;
      _scheduledDate = null;
      _scheduledTime = null;
      _photoUrls = [];
      _selectedLocation = null;
    });
  }

  // Método para obtener la ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Obtener ubicación actual
      final location = await _mapsService.getCurrentLocation();

      // Cerrar indicador de carga
      if (mounted) Navigator.pop(context);

      if (location != null) {
        setState(() {
          _selectedLocation = location;
        });

        // Obtener dirección a partir de coordenadas
        final address = await _locationService.getAddressFromLatLng(location);
        if (address != null && mounted) {
          setState(() {
            _addressController.text = address;
          });
        }
      } else {
        // Mostrar mensaje de error
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
      // Cerrar indicador de carga si hay error
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

  // Método para abrir el selector de ubicación
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationPickerScreen(
              initialPosition: _selectedLocation,
              coverageRadius: 5.0, // Radio predeterminado para clientes
            ),
      ),
    );

    if (result != null &&
        result.containsKey('position') &&
        result.containsKey('address')) {
      final position = result['position'];
      final address = result['address'] as String;

      // Verificar que position es un objeto LatLng
      if (position is LatLng) {
        setState(() {
          _selectedLocation = position;
          _addressController.text = address;
        });
      }
    }
  }

  // Method to select date if needed
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });

      await _selectTime(context);
    }
  }

  // Method to select time if needed
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _scheduledTime) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Category selector
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              CategorySelector(
                selectedCategories: _selectedCategories,
                onCategoriesChanged: (categories) {
                  setState(() {
                    _selectedCategories = categories;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Urgency checkbox
              CheckboxListTile(
                title: const Text('Urgente (solicito servicio para hoy)'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

              const SizedBox(height: 16),

              // Service location selector
              const Text(
                'Ubicación del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('En tu ubicación'),
                      value: true,
                      groupValue: _inClientLocation,
                      onChanged: (value) {
                        setState(() {
                          _inClientLocation = value!;
                        });
                      },
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('En local del técnico'),
                      value: false,
                      groupValue: _inClientLocation,
                      onChanged: (value) {
                        setState(() {
                          _inClientLocation = value!;
                          // Clear address if switched to technician location
                          if (value == false) {
                            _addressController.clear();
                          }
                        });
                      },
                      dense: true,
                    ),
                  ),
                ],
              ),

              // Show address field if service location is client location
              if (_inClientLocation) ...[
                const SizedBox(height: 16),
                LocationInput(
                  controller: _addressController,
                  onGetLocation: _getCurrentLocation,
                  onOpenMap: _openLocationPicker,
                ),
              ],

              const SizedBox(height: 16),

              // Photos
              PhotoPicker(
                photoUrls: _photoUrls,
                onPhotosChanged: (urls) {
                  setState(() {
                    _photoUrls = urls;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
