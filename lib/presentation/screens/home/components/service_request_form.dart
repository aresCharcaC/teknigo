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
import '../../technician/profile/location_picker_screen.dart';
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

  // ESTADO INTERNO USANDO VARIABLES EN LUGAR DE VALUENOTIFIER
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

  // REFERENCIAS SEGURAS
  ScaffoldMessengerState? _scaffoldMessenger;
  AuthViewModel? _authViewModel;
  ServiceRequestViewModel? _serviceRequestViewModel;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _mapsService = MapsService();
    print('ServiceRequestForm initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // GUARDAR REFERENCIAS SEGURAS
    if (!_isDisposed && mounted) {
      try {
        _scaffoldMessenger = ScaffoldMessenger.of(context);
        _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        _serviceRequestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );
      } catch (e) {
        print('Error obteniendo referencias en ServiceRequestForm: $e');
      }
    }
  }

  @override
  void dispose() {
    print('ServiceRequestForm dispose()');
    _isDisposed = true;

    // Limpiar controladores
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();

    // Limpiar referencias
    _scaffoldMessenger = null;
    _authViewModel = null;
    _serviceRequestViewModel = null;

    super.dispose();
  }

  // MÉTODO SEGURO PARA MOSTRAR SNACKBAR
  void _showSafeSnackBar(String message, {Color? backgroundColor}) {
    final messenger = _scaffoldMessenger;
    if (messenger != null && !_isDisposed) {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        print('Error mostrando SnackBar en ServiceRequestForm: $e');
      }
    }
  }

  // MÉTODO SEGURO PARA MOSTRAR DIALOGO
  void _showSafeDialog(Widget dialog) {
    if (!_isDisposed && mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => dialog,
        );
      } catch (e) {
        print('Error mostrando diálogo: $e');
      }
    }
  }

  // MÉTODO SEGURO PARA CERRAR DIALOGO
  void _safePopDialog() {
    if (!_isDisposed && mounted && Navigator.canPop(context)) {
      try {
        Navigator.pop(context);
      } catch (e) {
        print('Error cerrando diálogo: $e');
      }
    }
  }

  // Submit del formulario - TOTALMENTE SEGURO
  Future<void> _submitForm() async {
    if (_isDisposed || !mounted) return;

    if (!_formKey.currentState!.validate()) return;

    // Validar según ubicación
    if (_inClientLocation && _addressController.text.trim().isEmpty) {
      _showSafeSnackBar(
        'Ingresa una dirección para el servicio en tu ubicación',
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showSafeSnackBar('Selecciona al menos una categoría');
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Obtener usuario actual
      final authViewModel = _authViewModel;
      if (authViewModel == null) {
        throw Exception('AuthViewModel no disponible');
      }

      final currentUser = authViewModel.currentUser;
      final userId = currentUser?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Crear objeto de solicitud
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
        photos: _photoUrls.isEmpty ? null : _photoUrls,
      );

      // Acceder al ViewModel
      final requestViewModel = _serviceRequestViewModel;
      if (requestViewModel == null) {
        throw Exception('ServiceRequestViewModel no disponible');
      }

      // Enviar solicitud
      final result = await requestViewModel.createServiceRequest(
        serviceRequest,
        _photoFiles.isEmpty ? null : _photoFiles,
      );

      // Verificar que el widget siga montado
      if (_isDisposed || !mounted) return;

      if (result.isSuccess) {
        // Resetear formulario
        _resetForm();

        // Mostrar mensaje de éxito
        _showSafeSnackBar(
          'Solicitud creada correctamente',
          backgroundColor: Colors.green,
        );
      } else {
        // Mostrar mensaje de error
        _showSafeSnackBar(
          'Error: ${result.error}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        _showSafeSnackBar(
          'Error al crear la solicitud: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Reset del formulario
  void _resetForm() {
    if (_isDisposed) return;

    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();

    if (mounted) {
      setState(() {
        _selectedCategories = [];
        _isUrgent = false;
        _inClientLocation = true;
        _scheduledDate = null;
        _scheduledTime = null;
        _photoUrls = [];
        _photoFiles = [];
        _selectedLocation = null;
      });
    }
  }

  // Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    if (_isDisposed || !mounted) return;

    try {
      // Mostrar indicador de carga
      _showSafeDialog(const Center(child: CircularProgressIndicator()));

      // Obtener ubicación
      final location = await _mapsService.getCurrentLocation();

      // Cerrar indicador
      _safePopDialog();

      if (location != null && !_isDisposed && mounted) {
        setState(() {
          _selectedLocation = location;
        });

        // Obtener dirección
        final address = await _locationService.getAddressFromLatLng(location);
        if (address != null && !_isDisposed && mounted) {
          _addressController.text = address;
        }
      } else {
        if (!_isDisposed) {
          _showSafeSnackBar('No se pudo obtener tu ubicación actual');
        }
      }
    } catch (e) {
      _safePopDialog();
      print('Error al obtener ubicación: $e');

      if (!_isDisposed) {
        _showSafeSnackBar('Error al obtener ubicación: $e');
      }
    }
  }

  // Abrir selector de ubicación
  Future<void> _openLocationPicker() async {
    if (_isDisposed || !mounted) return;

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder:
              (context) => LocationPickerScreen(
                initialPosition: _selectedLocation,
                coverageRadius: 5.0,
              ),
        ),
      );

      if (result != null &&
          result.containsKey('position') &&
          result.containsKey('address') &&
          !_isDisposed &&
          mounted) {
        final position = result['position'];
        final address = result['address'] as String;

        if (position is LatLng) {
          setState(() {
            _selectedLocation = position;
          });
          _addressController.text = address;
        }
      }
    } catch (e) {
      print('Error en selector de ubicación: $e');
      if (!_isDisposed) {
        _showSafeSnackBar('Error al abrir selector de ubicación: $e');
      }
    }
  }

  // Manejar selección de fotos
  void _handlePhotosSelected(List<File> photos) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _photoFiles = photos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

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
              // Título
              const Text(
                'Solicitar Servicio Técnico',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Campo título
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

              // Campo descripción
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

              // Selector de categorías
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              CategorySelector(
                selectedCategories: _selectedCategories,
                onCategoriesChanged: (categories) {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _selectedCategories = categories;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Checkbox urgencia
              CheckboxListTile(
                title: const Text('Urgente (solicito servicio para hoy)'),
                value: _isUrgent,
                onChanged: (value) {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _isUrgent = value ?? false;
                    });
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

              const SizedBox(height: 16),

              // Ubicación del servicio
              const Text(
                'Ubicación del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Radio buttons ubicación
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('En tu ubicación'),
                      value: true,
                      groupValue: _inClientLocation,
                      onChanged: (value) {
                        if (!_isDisposed && mounted) {
                          setState(() {
                            _inClientLocation = value!;
                          });
                        }
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
                        if (!_isDisposed && mounted) {
                          setState(() {
                            _inClientLocation = value!;
                            if (value == false) {
                              _addressController.clear();
                            }
                          });
                        }
                      },
                      dense: true,
                    ),
                  ),
                ],
              ),

              // Campo dirección si es necesario
              if (_inClientLocation) ...[
                const SizedBox(height: 16),
                LocationInput(
                  controller: _addressController,
                  onGetLocation: _getCurrentLocation,
                  onOpenMap: _openLocationPicker,
                ),
              ],

              const SizedBox(height: 16),

              // Selector de fotos
              PhotoPicker(
                photoUrls: _photoUrls,
                onPhotosChanged: (urls) {
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _photoUrls = urls;
                    });
                  }
                },
                onFilesSelected: _handlePhotosSelected,
              ),

              const SizedBox(height: 24),

              // Botón submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_isSubmitting || _isDisposed) ? null : _submitForm,
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
