import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/service_request_model.dart';
import '../../view_models/category_view_model.dart';
import '../../view_models/service_request_view_model.dart';
import '../service_request/service_request_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  List<String> _selectedCategories = [];
  bool _isUrgent = false;
  bool _inClientLocation = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  List<String> _photoUrls = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Load categories for the service request form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      categoryViewModel.loadCategories();

      // Load existing service requests
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      requestViewModel.loadUserServiceRequests();
    });
  }

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
      // Validate required fields based on location
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
        // Create service request object
        final serviceRequest = ServiceRequestModel.create(
          userId: 'current_user_id', // Replace with actual user ID
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryIds: _selectedCategories,
          isUrgent: _isUrgent,
          inClientLocation: _inClientLocation,
          address: _inClientLocation ? _addressController.text.trim() : null,
          scheduledDate: _scheduledDate,
          photos: _photoUrls,
        );

        // Access view model to create request
        final requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );

        // Submit request
        await requestViewModel.createServiceRequest(serviceRequest);

        // Reset form
        _resetForm();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud creada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        // Show error message
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
    });
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

  // Method to pick images
  Future<void> _pickImages() async {
    // TODO: Implement image picking and uploading
    // Will use existing code for image picking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Agregar imágenes'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Request Form Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Consumer<CategoryViewModel>(
                      builder: (context, categoryViewModel, child) {
                        if (categoryViewModel.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (categoryViewModel.categories.isEmpty) {
                          return const Center(
                            child: Text('No hay categorías disponibles'),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              categoryViewModel.categories.map((category) {
                                final isSelected = _selectedCategories.contains(
                                  category.id,
                                );

                                return FilterChip(
                                  label: Text(category.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category.id);
                                      } else {
                                        _selectedCategories.remove(category.id);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: category.iconColor.withOpacity(
                                    0.2,
                                  ),
                                  checkmarkColor: category.iconColor,
                                  avatar: CircleAvatar(
                                    backgroundColor:
                                        isSelected
                                            ? category.iconColor
                                            : Colors.grey.shade300,
                                    child: Icon(
                                      category.getIcon(),
                                      size: 14,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Dirección',
                          hintText: 'Ingresa tu dirección completa',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: () {
                              // TODO: Implement getting current location
                              // Will use existing location code
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Próximamente: Usar ubicación actual',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        validator:
                            _inClientLocation
                                ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La dirección es obligatoria para servicios en tu ubicación';
                                  }
                                  return null;
                                }
                                : null,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Photos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fotos (Opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),

                    // Show selected photos if any
                    if (_photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  Image.network(
                                    _photoUrls[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _photoUrls.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        color: Colors.red,
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

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
          ),

          const SizedBox(height: 24),

          // Recent requests section
          const Text(
            'Mis solicitudes recientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // List of recent requests
          Consumer<ServiceRequestViewModel>(
            builder: (context, requestViewModel, child) {
              if (requestViewModel.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (requestViewModel.userRequests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes solicitudes recientes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea una solicitud para encontrar técnicos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requestViewModel.userRequests.length,
                itemBuilder: (context, index) {
                  final request = requestViewModel.userRequests[index];
                  return _buildRequestCard(context, request, requestViewModel);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Build card for each service request
  Widget _buildRequestCard(
    BuildContext context,
    ServiceRequestModel request,
    ServiceRequestViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to request detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ServiceRequestDetailScreen(requestId: request.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title and urgency
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon (using the first category)
                  Consumer<CategoryViewModel>(
                    builder: (context, categoryViewModel, child) {
                      CategoryModel? category;
                      if (request.categoryIds.isNotEmpty) {
                        category = categoryViewModel.categories.firstWhere(
                          (c) => c.id == request.categoryIds.first,
                          orElse: () => categoryViewModel.categories.first,
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category?.iconColor ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category?.getIcon() ?? Icons.build,
                          color: Colors.white,
                          size: 16,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          request.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Urgency and location
              Row(
                children: [
                  if (request.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'URGENTE',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (request.isUrgent) const SizedBox(width: 8),

                  Icon(
                    request.inClientLocation ? Icons.home : Icons.store,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    request.inClientLocation
                        ? 'En tu ubicación'
                        : 'En local del técnico',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  const Spacer(),

                  // Delete button
                  if (request.status == 'pending')
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed:
                          () => _confirmDelete(context, request.id, viewModel),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm deletion of request
  Future<void> _confirmDelete(
    BuildContext context,
    String requestId,
    ServiceRequestViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar solicitud'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar esta solicitud?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('SÍ, CANCELAR'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await viewModel.cancelServiceRequest(requestId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada correctamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la solicitud: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper methods for UI elements
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'accepted':
        return 'ACEPTADO';
      case 'completed':
        return 'COMPLETADO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }
}
