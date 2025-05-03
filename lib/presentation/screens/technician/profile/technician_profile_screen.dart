import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../view_models/technician_view_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../components/categories_card.dart';
import '../components/skills_card.dart';
import '../components/availability_card.dart';
import '../components/location_map_card.dart';

/// Pantalla de perfil del técnico
///
/// Permite al técnico configurar su perfil profesional, habilidades,
/// disponibilidad y ubicación de servicio.
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

  bool _isEditing = false;
  File? _profileImageFile;
  File? _businessImageFile;

  @override
  void initState() {
    super.initState();

    // Cargar datos del perfil del técnico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final technicianViewModel = Provider.of<TechnicianViewModel>(
        context,
        listen: false,
      );
      technicianViewModel.loadTechnicianProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  // Método para actualizar controladores cuando se carguen los datos
  void _updateControllers(TechnicianViewModel viewModel) {
    if (!_isEditing) {
      _nameController.text = viewModel.technicianData['name'] ?? '';
      _phoneController.text = viewModel.technicianData['phone'] ?? '';
      _descriptionController.text =
          viewModel.technicianData['description'] ?? '';
      _experienceController.text = viewModel.technicianData['experience'] ?? '';
      _businessNameController.text =
          viewModel.technicianData['businessName'] ?? '';
    }
  }

  // Método para cambiar a modo edición
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        // Si cancelamos la edición, restaurar valores originales
        final viewModel = Provider.of<TechnicianViewModel>(
          context,
          listen: false,
        );
        _updateControllers(viewModel);
        _profileImageFile = null;
        _businessImageFile = null;
      }
    });
  }

  // Método para guardar cambios del perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = Provider.of<TechnicianViewModel>(context, listen: false);

    // Crear mapa con datos actualizados
    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'description': _descriptionController.text.trim(),
      'experience': _experienceController.text.trim(),
      'isIndividual': viewModel.isIndividual,
      'isAvailable': viewModel.isAvailable,
      'isServicesActive': viewModel.isServicesActive,
      'businessName': _businessNameController.text.trim(),
      'categories': viewModel.selectedCategories,
      'skills': viewModel.skills,
    };

    // Si hay imagen nueva, procesarla
    if (_profileImageFile != null) {
      await viewModel.uploadProfileImage(_profileImageFile!);
    }

    if (_businessImageFile != null) {
      await viewModel.uploadBusinessImage(_businessImageFile!);
    }

    // Actualizar perfil
    final result = await viewModel.updateTechnicianProfile(updatedData);

    if (result.isSuccess) {
      setState(() {
        _isEditing = false;
        _profileImageFile = null;
        _businessImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Método para seleccionar imagen de perfil
  Future<void> _pickProfileImage() async {
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
                    // Implementar selección de cámara
                    // Por ahora, simulamos con una imagen
                    setState(() {
                      // En una implementación real, aquí se tomaría la foto
                      // _profileImageFile = ...
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Implementar selección de galería
                    // Por ahora, simulamos con una imagen
                    setState(() {
                      // En una implementación real, aquí se seleccionaría la imagen
                      // _profileImageFile = ...
                    });
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
                      // Implementar eliminar foto
                      // Por ahora, simulamos
                      setState(() {
                        // En una implementación real, aquí se eliminaría la foto
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicianViewModel>(
      builder: (context, technicianViewModel, _) {
        // Actualizar controladores con datos del técnico
        if (!_isEditing && !technicianViewModel.isLoading) {
          _updateControllers(technicianViewModel);
        }

        if (technicianViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildProfileContent(technicianViewModel);
      },
    );
  }

  // Método para construir el contenido del perfil
  Widget _buildProfileContent(TechnicianViewModel technicianViewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil básico (avatar, nombre, etc.)
            _buildProfileCard(technicianViewModel),

            const SizedBox(height: 16),

            // Tarjeta de disponibilidad
            AvailabilityCard(
              isEditing: _isEditing,
              isServicesActive: technicianViewModel.isServicesActive,
              isAvailable: technicianViewModel.isAvailable,
              onChangeServicesActive: (value) {
                technicianViewModel.updateServicesActive(value);
              },
              onChangeAvailability: (value) {
                technicianViewModel.updateAvailability(value);
              },
            ),

            const SizedBox(height: 16),

            // Tarjeta de ubicación
            LocationMapCard(
              location: technicianViewModel.location,
              address: technicianViewModel.address,
              coverageRadius: technicianViewModel.coverageRadius,
              isEditing: _isEditing,
              onSelectLocation: () {
                // Implementar selección de ubicación
                // Por ahora, muestra un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Selección de ubicación'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Tarjeta de categorías
            CategoriesCard(
              isEditing: _isEditing,
              selectedCategories: technicianViewModel.selectedCategories,
              onUpdateCategories: (newCategories) {
                technicianViewModel.updateSelectedCategories(newCategories);
              },
            ),

            const SizedBox(height: 16),

            // Tarjeta de habilidades
            SkillsCard(
              isEditing: _isEditing,
              skills: technicianViewModel.skills,
              onUpdateSkills: (newSkills) {
                technicianViewModel.updateSkills(newSkills);
              },
            ),

            const SizedBox(height: 40), // Espacio adicional al final
          ],
        ),
      ),
    );
  }

  // Tarjeta de perfil básico
  Widget _buildProfileCard(TechnicianViewModel technicianViewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildProfileAvatar(technicianViewModel),

                const SizedBox(width: 16),

                // Información básica
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      _isEditing
                          ? CustomTextField(
                            controller: _nameController,
                            label: 'Nombre',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              return null;
                            },
                          )
                          : Text(
                            technicianViewModel.technicianData['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                      const SizedBox(height: 8),

                      // Email (no editable)
                      Text(
                        technicianViewModel.technicianData['email'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      if (!_isEditing &&
                          technicianViewModel.technicianData['rating'] !=
                              null) ...[
                        const SizedBox(height: 8),
                        // Valoración
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${technicianViewModel.technicianData['rating']?.toStringAsFixed(1) ?? '0.0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${technicianViewModel.technicianData['reviewCount'] ?? 0} reseñas)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tipo de técnico (individual o empresa)
            _buildTechnicianTypeSelector(technicianViewModel),

            const SizedBox(height: 16),

            // Teléfono
            _isEditing
                ? CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                )
                : ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.phone, color: Colors.blue),
                  ),
                  title: const Text('Teléfono'),
                  subtitle: Text(
                    technicianViewModel.technicianData['phone'] ??
                        'No especificado',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),

            const SizedBox(height: 16),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción profesional',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                )
                : Text(
                  technicianViewModel.technicianData['description'] ??
                      'No hay descripción',
                  style: TextStyle(color: Colors.grey.shade700),
                ),

            const SizedBox(height: 16),

            // Experiencia
            const Text(
              'Experiencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? CustomTextField(
                  controller: _experienceController,
                  label: 'Años de experiencia',
                  prefixIcon: Icons.work,
                )
                : Text(
                  technicianViewModel.technicianData['experience'] ??
                      'No especificada',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
          ],
        ),
      ),
    );
  }

  // Selector de tipo de técnico
  Widget _buildTechnicianTypeSelector(TechnicianViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de técnico',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap:
                    _isEditing
                        ? () => viewModel.updateTechnicianType(true)
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        viewModel.isIndividual
                            ? Colors.blue.shade50
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          viewModel.isIndividual
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                      width: viewModel.isIndividual ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color:
                            viewModel.isIndividual
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Individual',
                        style: TextStyle(
                          color:
                              viewModel.isIndividual
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade700,
                          fontWeight:
                              viewModel.isIndividual
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap:
                    _isEditing
                        ? () => viewModel.updateTechnicianType(false)
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        !viewModel.isIndividual
                            ? Colors.blue.shade50
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          !viewModel.isIndividual
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                      width: !viewModel.isIndividual ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business,
                        color:
                            !viewModel.isIndividual
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Empresa',
                        style: TextStyle(
                          color:
                              !viewModel.isIndividual
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade700,
                          fontWeight:
                              !viewModel.isIndividual
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Información de negocio (solo si es tipo negocio)
        if (!viewModel.isIndividual) ...[
          const SizedBox(height: 16),
          _isEditing
              ? CustomTextField(
                controller: _businessNameController,
                label: 'Nombre de la empresa',
                prefixIcon: Icons.business,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre de la empresa:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    viewModel.technicianData['businessName'] ??
                        'No especificado',
                  ),
                ],
              ),
        ],
      ],
    );
  }

  // Construir avatar de perfil
  Widget _buildProfileAvatar(TechnicianViewModel viewModel) {
    const double radius = 50.0;
    String firstLetter = '';
    if (viewModel.technicianData['name'] != null &&
        viewModel.technicianData['name'].toString().isNotEmpty) {
      firstLetter =
          viewModel.technicianData['name']
              .toString()
              .substring(0, 1)
              .toUpperCase();
    }

    // Si hay una imagen temporal
    if (_profileImageFile != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(_profileImageFile!),
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    // Si hay una imagen guardada
    if (viewModel.technicianData['profileImage'] != null &&
        viewModel.technicianData['profileImage'].toString().isNotEmpty) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(
              viewModel.technicianData['profileImage'],
            ),
            onBackgroundImageError: (exception, stackTrace) {
              // Si hay error al cargar la imagen, mostrar la letra
              return;
            },
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    // Avatar por defecto
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            firstLetter,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
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
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
