import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isEditing = false;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();

    // Cargar datos del perfil del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );
      profileViewModel.loadUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // Método para actualizar controladores cuando se carguen los datos del usuario
  void _updateControllers(ProfileViewModel viewModel) {
    if (!_isEditing) {
      _nameController.text = viewModel.userData['name'] ?? '';
      _phoneController.text = viewModel.userData['phone'] ?? '';
      _cityController.text = viewModel.userData['city'] ?? '';
      _countryController.text = viewModel.userData['country'] ?? '';
      _postalCodeController.text = viewModel.userData['postalCode'] ?? '';
    }
  }

  // Método para cambiar a modo edición
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        // Si cancelamos la edición, restaurar valores originales
        final profileViewModel = Provider.of<ProfileViewModel>(
          context,
          listen: false,
        );
        _updateControllers(profileViewModel);
        _profileImageFile = null;
      }
    });
  }

  // Método para guardar cambios del perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );

    // Crear mapa con datos actualizados
    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
    };

    // Si hay imagen nueva, procesarla
    if (_profileImageFile != null) {
      await profileViewModel.uploadProfileImage(_profileImageFile!);
    }

    // Actualizar perfil
    final result = await profileViewModel.updateUserProfile(updatedData);

    if (result.isSuccess) {
      setState(() {
        _isEditing = false;
        _profileImageFile = null;
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
                    final profileViewModel = Provider.of<ProfileViewModel>(
                      context,
                      listen: false,
                    );
                    final image = await profileViewModel.pickImageFromCamera();
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
                    final profileViewModel = Provider.of<ProfileViewModel>(
                      context,
                      listen: false,
                    );
                    final image = await profileViewModel.pickImageFromGallery();
                    if (image != null) {
                      setState(() {
                        _profileImageFile = image;
                      });
                    }
                  },
                ),
                if (Provider.of<ProfileViewModel>(
                      context,
                      listen: false,
                    ).userData['profileImage'] !=
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
                        final profileViewModel = Provider.of<ProfileViewModel>(
                          context,
                          listen: false,
                        );
                        await profileViewModel.removeProfileImage();
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar el provider existente en lugar de crear uno nuevo
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, _) {
        // Actualizar controladores con datos del usuario
        if (!_isEditing && !profileViewModel.isLoading) {
          _updateControllers(profileViewModel);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEditMode,
                  tooltip: 'Editar perfil',
                )
              else
                TextButton(
                  onPressed: _toggleEditMode,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body:
              profileViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProfileContent(profileViewModel),
          floatingActionButton:
              _isEditing
                  ? FloatingActionButton.extended(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  )
                  : null,
        );
      },
    );
  }

  // Método para construir el contenido del perfil
  Widget _buildProfileContent(ProfileViewModel profileViewModel) {
    String firstLetter = '';
    if (profileViewModel.userData['name'] != null &&
        profileViewModel.userData['name'].toString().isNotEmpty) {
      firstLetter =
          profileViewModel.userData['name']
              .toString()
              .substring(0, 1)
              .toUpperCase();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de información básica
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con foto
                    Center(
                      child: Column(
                        children: [
                          // Avatar del usuario
                          _buildProfileAvatar(profileViewModel, firstLetter),
                          const SizedBox(height: 16),

                          // Nombre (editable o no)
                          _isEditing
                              ? CustomTextField(
                                controller: _nameController,
                                label: 'Nombre completo',
                                prefixIcon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre es obligatorio';
                                  }
                                  return null;
                                },
                              )
                              : Text(
                                profileViewModel.userData['name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Email (no editable)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: const Text(
                        'Correo electrónico',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        profileViewModel.userData['email'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

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
                            child: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: const Text(
                            'Teléfono',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            profileViewModel.userData['phone']?.isNotEmpty ==
                                    true
                                ? profileViewModel.userData['phone']
                                : 'No especificado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de ubicación
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Ciudad
                    _isEditing
                        ? CustomTextField(
                          controller: _cityController,
                          label: 'Ciudad',
                          prefixIcon: Icons.location_city,
                        )
                        : ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(
                              Icons.location_city,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: const Text(
                            'Ciudad',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            profileViewModel.userData['city']?.isNotEmpty ==
                                    true
                                ? profileViewModel.userData['city']
                                : 'No especificada',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                    const SizedBox(height: 16),

                    // País
                    _isEditing
                        ? CustomTextField(
                          controller: _countryController,
                          label: 'País',
                          prefixIcon: Icons.flag,
                        )
                        : ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(
                              Icons.flag,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: const Text(
                            'País',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            profileViewModel.userData['country']?.isNotEmpty ==
                                    true
                                ? profileViewModel.userData['country']
                                : 'No especificado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                    const SizedBox(height: 16),

                    // Código postal
                    _isEditing
                        ? CustomTextField(
                          controller: _postalCodeController,
                          label: 'Código postal',
                          prefixIcon: Icons.mail,
                          keyboardType: TextInputType.number,
                        )
                        : ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(
                              Icons.mail,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: const Text(
                            'Código postal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            profileViewModel
                                        .userData['postalCode']
                                        ?.isNotEmpty ==
                                    true
                                ? profileViewModel.userData['postalCode']
                                : 'No especificado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de información adicional
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Fecha de registro
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: const Text('Fecha de registro'),
                    subtitle: Text(
                      profileViewModel.userData['createdAt'] is DateTime
                          ? '${profileViewModel.userData['createdAt'].day}/${profileViewModel.userData['createdAt'].month}/${profileViewModel.userData['createdAt'].year}'
                          : 'No disponible',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Divider(height: 1),

                  // Cambiar contraseña
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text('Cambiar contraseña'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navegar a cambio de contraseña
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: Cambiar contraseña'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // Eliminar cuenta
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Eliminar cuenta',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      // Mostrar diálogo de confirmación
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Eliminar cuenta'),
                              content: const Text(
                                '¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Próximamente: Eliminar cuenta',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'ELIMINAR',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Espacio adicional al final
          ],
        ),
      ),
    );
  }

  // Método para construir avatar de perfil
  Widget _buildProfileAvatar(
    ProfileViewModel profileViewModel,
    String firstLetter,
  ) {
    final double radius = 50.0;

    // Si hay una imagen temporal para subir
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

    // Si hay una imagen de perfil guardada
    if (profileViewModel.userData['profileImage'] != null &&
        profileViewModel.userData['profileImage'].toString().isNotEmpty) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(
              profileViewModel.userData['profileImage'],
            ),
            onBackgroundImageError: (exception, stackTrace) {
              // Mostrar avatar por defecto en caso de error
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

    // Avatar por defecto con inicial
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
