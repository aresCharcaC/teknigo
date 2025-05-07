// lib/presentation/screens/technician/profile/technician_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/social_link.dart';
import '../../../../core/models/working_hours.dart';
import '../../../view_models/technician_view_model.dart';
import '../../../view_models/category_view_model.dart';
import '../components/profile_section.dart';
import '../components/account_type_selector.dart';
import '../components/personal_info_section.dart';
import '../components/services_section.dart';
import '../components/location_section.dart';
import '../components/availability_section.dart';
import '../components/social_links_section.dart';
import '../location_picker_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({Key? key}) : super(key: key);

  @override
  _TechnicianProfileScreenState createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

  bool _isEditing = false;
  File? _profileImageFile;
  File? _businessImageFile;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    // Cargar datos del perfil del técnico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final technicianViewModel = Provider.of<TechnicianViewModel>(
        context,
        listen: false,
      );
      technicianViewModel.loadTechnicianProfile().then((_) {
        _updateControllersFromViewModel(technicianViewModel);
      });

      // Cargar categorías
      Provider.of<CategoryViewModel>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    // Liberar los controladores al destruir el widget
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  // Método para actualizar controladores cuando se carguen los datos
  // Este método NO usa setState() y es seguro de llamar fuera del ciclo de build
  void _updateControllersFromViewModel(TechnicianViewModel viewModel) {
    if (viewModel.technicianData.isEmpty) return;

    // Actualizar los controladores sin llamar a setState
    _nameController.text = viewModel.technicianData['name'] ?? '';
    _phoneController.text = viewModel.technicianData['phone'] ?? '';
    _descriptionController.text = viewModel.technicianData['description'] ?? '';
    _experienceController.text = viewModel.technicianData['experience'] ?? '';
    _businessNameController.text =
        viewModel.technicianData['businessName'] ?? '';
    _businessDescriptionController.text =
        viewModel.technicianData['businessDescription'] ?? '';

    // Marcamos que los controladores fueron inicializados
    _controllersInitialized = true;
  }

  // Método para cambiar a modo edición
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        // Si cancelamos la edición, restaurar valores originales
        final technicianViewModel = Provider.of<TechnicianViewModel>(
          context,
          listen: false,
        );
        _updateControllersFromViewModel(technicianViewModel);
        _profileImageFile = null;
        _businessImageFile = null;
      }
    });
  }

  // lib/presentation/screens/technician/profile/technician_profile_screen.dart

  // Método para seleccionar imagen de perfil
  void _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final technicianViewModel =
                        Provider.of<TechnicianViewModel>(
                          context,
                          listen: false,
                        );
                    final image =
                        await technicianViewModel.pickImageFromCamera();
                    if (image != null) {
                      setState(() {
                        _profileImageFile = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    final technicianViewModel =
                        Provider.of<TechnicianViewModel>(
                          context,
                          listen: false,
                        );
                    final image =
                        await technicianViewModel.pickImageFromGallery();
                    if (image != null) {
                      setState(() {
                        _profileImageFile = image;
                      });
                    }
                  },
                ),
                if (Provider.of<TechnicianViewModel>(
                      context,
                      listen: false,
                    ).technicianData['profileImage'] !=
                    null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Eliminar foto actual',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Eliminar foto'),
                              content: const Text(
                                '¿Estás seguro de eliminar tu foto de perfil?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'ELIMINAR',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        // Eliminar imagen
                        final technicianViewModel =
                            Provider.of<TechnicianViewModel>(
                              context,
                              listen: false,
                            );
                        await technicianViewModel.removeProfileImage();
                        setState(() {});
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  // Método para seleccionar imagen de negocio
  void _pickBusinessImage() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final technicianViewModel =
                        Provider.of<TechnicianViewModel>(
                          context,
                          listen: false,
                        );
                    final image =
                        await technicianViewModel.pickImageFromCamera();
                    if (image != null) {
                      setState(() {
                        _businessImageFile = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    final technicianViewModel =
                        Provider.of<TechnicianViewModel>(
                          context,
                          listen: false,
                        );
                    final image =
                        await technicianViewModel.pickImageFromGallery();
                    if (image != null) {
                      setState(() {
                        _businessImageFile = image;
                      });
                    }
                  },
                ),
                if (Provider.of<TechnicianViewModel>(
                      context,
                      listen: false,
                    ).technicianData['businessImage'] !=
                    null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Eliminar imagen actual',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Eliminar imagen'),
                              content: const Text(
                                '¿Estás seguro de eliminar esta imagen?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'ELIMINAR',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        // Eliminar imagen
                        final technicianViewModel =
                            Provider.of<TechnicianViewModel>(
                              context,
                              listen: false,
                            );
                        await technicianViewModel.removeBusinessImage();
                        setState(() {});
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  // Método para guardar cambios del perfil
  Future<void> _saveProfile() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate())
      return;

    final technicianViewModel = Provider.of<TechnicianViewModel>(
      context,
      listen: false,
    );

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Crear mapa con todos los datos actualizados
      final updatedData = {
        // Datos básicos
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'description': _descriptionController.text.trim(),
        'experience': _experienceController.text.trim(),

        // Tipo de cuenta
        'isIndividual': technicianViewModel.isIndividual,

        // Disponibilidad
        'isServicesActive': technicianViewModel.isServicesActive,
        'isAvailable': technicianViewModel.isAvailable,

        // Datos de empresa (si corresponde)
        'businessName': _businessNameController.text.trim(),
        'businessDescription': _businessDescriptionController.text.trim(),

        // Tipos de servicio
        'serviceAtHome': technicianViewModel.serviceAtHome,
        'serviceAtOffice': technicianViewModel.serviceAtOffice,

        // Categorías y habilidades
        'categories': technicianViewModel.selectedCategories,
        'skills': technicianViewModel.skills,

        // Enlaces sociales
        'socialLinks':
            technicianViewModel.socialLinks
                .map((link) => link.toMap())
                .toList(),

        // Horarios
        'workingHours':
            technicianViewModel.workingHours
                .map((hour) => hour.toMap())
                .toList(),
      };

      // Si hay imagen nueva de perfil, procesarla
      if (_profileImageFile != null) {
        await technicianViewModel.uploadProfileImage(_profileImageFile!);
      }

      // Si hay imagen nueva de negocio, procesarla
      if (_businessImageFile != null) {
        await technicianViewModel.uploadBusinessImage(_businessImageFile!);
      }

      // Actualizar perfil con todos los datos
      final result = await technicianViewModel.updateTechnicianProfile(
        updatedData,
      );

      // Cerrar diálogo de carga
      if (context.mounted) Navigator.of(context).pop();

      if (result.isSuccess) {
        setState(() {
          _isEditing = false;
          _profileImageFile = null;
          _businessImageFile = null;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicianViewModel>(
      builder: (context, technicianViewModel, _) {
        // Actualizar controladores solo si no se han inicializado aún
        // y no estamos en modo edición y no está cargando
        if (!_controllersInitialized &&
            !_isEditing &&
            !technicianViewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllersFromViewModel(technicianViewModel);
          });
        }

        if (technicianViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de perfil superior (foto, nombre, disponibilidad)
                  _buildProfileHeader(technicianViewModel),

                  const SizedBox(height: 16),

                  // Selector de tipo de cuenta (Individual/Negocio)
                  AccountTypeSelector(
                    isIndividual: technicianViewModel.isIndividual,
                    isEditing: _isEditing,
                    onTypeChanged: (isIndividual) {
                      technicianViewModel.updateTechnicianType(isIndividual);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sección de información personal
                  PersonalInfoSection(
                    isIndividual: technicianViewModel.isIndividual,
                    userData: technicianViewModel.technicianData,
                    isEditing: _isEditing,
                    descriptionController: _descriptionController,
                    experienceController: _experienceController,
                    businessNameController: _businessNameController,
                    businessDescriptionController:
                        _businessDescriptionController,
                    profileImageFile: _profileImageFile,
                    onPickProfileImage: _pickProfileImage,
                    businessImageFile: _businessImageFile,
                    onPickBusinessImage: _pickBusinessImage,
                  ),

                  const SizedBox(height: 16),

                  // Sección de servicios y especialidades
                  ServicesSection(
                    isEditing: _isEditing,
                    selectedCategories: technicianViewModel.selectedCategories,
                    skills: technicianViewModel.skills,
                    onUpdateCategories: (categories) {
                      technicianViewModel.updateSelectedCategories(categories);
                    },
                    onUpdateSkills: (skills) {
                      technicianViewModel.updateSkills(skills);
                    },
                    serviceAtHome: technicianViewModel.serviceAtHome,
                    serviceAtOffice: technicianViewModel.serviceAtOffice,
                    onToggleServiceAtHome: (value) {
                      technicianViewModel.toggleServiceAtHome(value);
                    },
                    onToggleServiceAtOffice: (value) {
                      technicianViewModel.toggleServiceAtOffice(value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sección de ubicación
                  LocationSection(
                    isEditing: _isEditing,
                    location: technicianViewModel.location,
                    address: technicianViewModel.address,
                    coverageRadius: technicianViewModel.coverageRadius,
                    onSelectLocation: () async {
                      if (_isEditing) {
                        final result =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LocationPickerScreen(
                                      initialPosition:
                                          technicianViewModel.location,
                                      coverageRadius:
                                          technicianViewModel.coverageRadius,
                                    ),
                              ),
                            );

                        if (result != null &&
                            result.containsKey('position') &&
                            result.containsKey('address')) {
                          final position = result['position'];
                          final address = result['address'] as String;
                          final coverageRadius =
                              result['coverageRadius'] as double;

                          // Verificar que position es un objeto LatLng
                          if (position is LatLng) {
                            // Actualizar la ubicación en el ViewModel
                            await technicianViewModel.updateLocation(
                              position,
                              address,
                              coverageRadius,
                            );
                          }
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sección de disponibilidad
                  AvailabilitySection(
                    isEditing: _isEditing,
                    isServicesActive: technicianViewModel.isServicesActive,
                    isAvailable: technicianViewModel.isAvailable,
                    workingHours: technicianViewModel.workingHours,
                    onToggleServicesActive: (value) {
                      technicianViewModel.updateServicesActive(value);
                    },
                    onToggleAvailability: (value) {
                      technicianViewModel.updateAvailability(value);
                    },
                    onUpdateWorkingHours: (hours) {
                      technicianViewModel.updateWorkingHours(hours);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sección de redes sociales
                  SocialLinksSection(
                    isEditing: _isEditing,
                    socialLinks: technicianViewModel.socialLinks,
                    onUpdateSocialLinks: (links) {
                      technicianViewModel.updateSocialLinks(links);
                    },
                  ),

                  // Espacio para el botón flotante
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton:
              _isEditing
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'cancel',
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.close),
                        onPressed: _toggleEditMode,
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        heroTag: 'save',
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.check),
                        onPressed: _saveProfile,
                      ),
                    ],
                  )
                  : FloatingActionButton(
                    heroTag: 'edit',
                    child: const Icon(Icons.edit),
                    onPressed: _toggleEditMode,
                  ),
        );
      },
    );
  }

  // Sección de perfil superior (foto, nombre, disponibilidad)
  Widget _buildProfileHeader(TechnicianViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar del usuario con stack para el botón de edición
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : viewModel.technicianData['profileImage'] != null
                      ? NetworkImage(viewModel.technicianData['profileImage'])
                          as ImageProvider<Object>
                      : null,
              child:
                  viewModel.technicianData['profileImage'] == null &&
                          _profileImageFile == null
                      ? Text(
                        viewModel.technicianData['name']?.isNotEmpty == true
                            ? viewModel.technicianData['name'][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Información básica
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                  ? TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  )
                  : Text(
                    viewModel.technicianData['name'] ?? 'Nombre del técnico',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

              const SizedBox(height: 4),

              // Mostrar estrellas de valoración
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${(viewModel.technicianData['rating'] ?? 0.0).toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${viewModel.technicianData['reviewCount'] ?? 0} reseñas)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: viewModel.isAvailable ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.isAvailable ? 'Disponible' : 'No disponible',
                    style: TextStyle(
                      color: viewModel.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              _isEditing
                  ? TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  )
                  : Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        viewModel.technicianData['phone'] ?? 'Sin teléfono',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      viewModel.technicianData['email'] ?? 'Sin email',
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
