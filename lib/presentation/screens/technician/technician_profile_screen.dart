// lib/presentation/screens/technician/technician_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/services/storage_service.dart';
import '../../../core/services/location_service.dart';
import 'location_picker_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({Key? key}) : super(key: key);

  @override
  _TechnicianProfileScreenState createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isImageUploading = false;
  Map<String, dynamic> _userData = {};

  bool _isIndividual = true; // Individual o negocio
  bool _isServicesActive =
      false; // Estado de activación de servicios (disponible en buscador)
  bool _isAvailable = true; // Estado de disponibilidad para trabajar

  File? _profileImageFile; // Imagen seleccionada temporalmente
  File? _businessImageFile; // Imagen de negocio seleccionada temporalmente

  // Ubicación
  LatLng? _location;
  String? _address;
  double _coverageRadius = 10.0;

  // Controladores para la edición
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _businessNameController = TextEditingController();

  // Categorías disponibles
  final List<TechnicianCategory> _availableCategories = [
    TechnicianCategory(id: '1', name: 'Electricista'),
    TechnicianCategory(id: '2', name: 'Plomero'),
    TechnicianCategory(id: '3', name: 'Técnico PC'),
    TechnicianCategory(id: '4', name: 'Refrigeración'),
    TechnicianCategory(id: '5', name: 'Cerrajero'),
    TechnicianCategory(id: '6', name: 'Carpintero'),
    TechnicianCategory(id: '7', name: 'Pintor'),
    TechnicianCategory(id: '8', name: 'Albañil'),
    TechnicianCategory(id: '9', name: 'Jardinero'),
    TechnicianCategory(id: '10', name: 'Limpieza'),
    TechnicianCategory(id: '11', name: 'Mecánico'),
    TechnicianCategory(id: '12', name: 'Electrónica'),
  ];

  // Categorías seleccionadas
  final List<String> _selectedCategories = [
    '1',
    '3',
  ]; // Ejemplo: Electricista y Técnico PC

  // Tags seleccionados por categoría (simulados)
  final Map<String, List<String>> _selectedTags = {
    '1': [
      'instalación',
      'cableado',
      'corto circuito',
    ], // Tags para Electricista
    '3': ['reparación', 'mantenimiento', 'software'], // Tags para Técnico PC
  };

  // Habilidades adicionales
  final List<String> _skills = [
    'Instalación de redes',
    'Reparación de equipos Apple',
    'Mantenimiento preventivo',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  // Cargar datos del usuario
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En una implementación real, cargarías datos de Firestore
      // Por ahora, usamos datos predefinidos
      await Future.delayed(const Duration(milliseconds: 800)); // Simular carga

      final userData = {
        'name': 'Carlos Técnico',
        'email': 'carlos@example.com',
        'phone': '+51 987 654 321',
        'address': 'Av. Arequipa 123, Arequipa',
        'description':
            'Técnico experimentado con más de 5 años en reparación e instalación de sistemas eléctricos y equipos de cómputo.',
        'experience': '5 años',
        'rating': 4.8,
        'reviewCount': 45,
        'completedJobs': 87,
        'isIndividual': true,
        'isAvailable': true,
        'isServicesActive': false,
        'profileImage':
            'https://randomuser.me/api/portraits/men/44.jpg', // Simulado
        'businessName': 'TechRepairs S.A.',
        'businessImage': null,
        'location': {'latitude': -16.3988900, 'longitude': -71.5350000},
        'coverageRadius': 10.0,
      };

      setState(() {
        _userData = userData;
        _isLoading = false;

        // Inicializar controladores
        _nameController.text = userData['name']?.toString() ?? '';
        _phoneController.text = userData['phone']?.toString() ?? '';
        _addressController.text = userData['address']?.toString() ?? '';
        _descriptionController.text = userData['description']?.toString() ?? '';
        _experienceController.text = userData['experience']?.toString() ?? '';
        _businessNameController.text =
            userData['businessName']?.toString() ?? '';

        // Inicializar estados
        _isIndividual = userData['isIndividual'] == true;
        _isAvailable = userData['isAvailable'] == true;
        _isServicesActive = userData['isServicesActive'] == true;

        // Inicializar ubicación
        if (userData['location'] != null) {
          final location = userData['location'] as Map<String, dynamic>;
          _location = LatLng(
            location['latitude'] as double,
            location['longitude'] as double,
          );
        }

        _address = userData['address']?.toString();
        _coverageRadius =
            (userData['coverageRadius'] is num)
                ? (userData['coverageRadius'] as num).toDouble()
                : 10.0;
      });
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Alternar categoría seleccionada
  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
        _selectedTags.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
        // Inicializar tags vacíos
        _selectedTags[categoryId] = [];
      }
    });
  }

  // Alternar entre modo individual y negocio
  void _toggleTechnicianType(bool isIndividual) {
    setState(() {
      _isIndividual = isIndividual;
    });
  }

  // Seleccionar imagen de perfil
  Future<void> _pickProfileImage() async {
    // Mostrar opciones (cámara o galería)
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
                    await _getProfileImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getProfileImageFromSource(ImageSource.gallery);
                  },
                ),
                if (_userData['profileImage'] != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Eliminar foto actual',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      // Confirmar eliminación
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
                        await _removeProfileImage();
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  // Seleccionar imagen de negocio
  Future<void> _pickBusinessImage() async {
    // Mostrar opciones (cámara o galería)
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
                    await _getBusinessImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getBusinessImageFromSource(ImageSource.gallery);
                  },
                ),
                if (_userData['businessImage'] != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Eliminar foto actual',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      // Confirmar eliminación
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Eliminar foto'),
                              content: const Text(
                                '¿Estás seguro de eliminar la foto de tu negocio?',
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
                        await _removeBusinessImage();
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  // Obtener imagen de perfil de cámara o galería
  Future<void> _getProfileImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Obtener imagen de negocio de cámara o galería
  Future<void> _getBusinessImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _businessImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Subir imagen de perfil
  Future<String?> _uploadProfileImage() async {
    if (_profileImageFile == null) return null;

    setState(() {
      _isImageUploading = true;
    });

    try {
      // En una implementación real, subir a Firebase Storage
      final userId = _authService.currentUser?.uid ?? 'user123';
      final url = await _storageService.uploadImage(
        _profileImageFile!,
        'profile_images',
        userId,
      );

      return url;
    } catch (e) {
      print('Error al subir imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  // Subir imagen de negocio
  Future<String?> _uploadBusinessImage() async {
    if (_businessImageFile == null) return null;

    setState(() {
      _isImageUploading = true;
    });

    try {
      // En una implementación real, subir a Firebase Storage
      final userId = _authService.currentUser?.uid ?? 'user123';
      final url = await _storageService.uploadImage(
        _businessImageFile!,
        'business_images',
        userId,
      );

      return url;
    } catch (e) {
      print('Error al subir imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  // Eliminar imagen de perfil
  Future<void> _removeProfileImage() async {
    if (_userData['profileImage'] == null) return;

    setState(() {
      _isImageUploading = true;
    });

    try {
      // En una implementación real, eliminar de Firebase Storage
      final success = await _storageService.deleteImageByUrl(
        _userData['profileImage'],
      );

      if (success) {
        setState(() {
          _userData['profileImage'] = null;
          _profileImageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al eliminar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  // Eliminar imagen de negocio
  Future<void> _removeBusinessImage() async {
    if (_userData['businessImage'] == null) return;

    setState(() {
      _isImageUploading = true;
    });

    try {
      // En una implementación real, eliminar de Firebase Storage
      final success = await _storageService.deleteImageByUrl(
        _userData['businessImage'],
      );

      if (success) {
        setState(() {
          _userData['businessImage'] = null;
          _businessImageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de negocio eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al eliminar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  // Seleccionar ubicación
  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialPosition: _location),
      ),
    );

    if (result != null) {
      setState(() {
        _location = result['position'] as LatLng?;
        _address = result['address'] as String?;
        _coverageRadius = result['coverageRadius'] as double? ?? 10.0;
        _addressController.text = _address ?? '';
      });
    }
  }

  // Mostrar diálogo para agregar habilidad
  void _showAddSkillDialog() {
    final skillController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar habilidad'),
            content: TextField(
              controller: skillController,
              decoration: const InputDecoration(
                labelText: 'Habilidad o especialidad',
                hintText: 'Ej: Instalación de redes wifi',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  final skill = skillController.text.trim();
                  if (skill.isNotEmpty) {
                    setState(() {
                      _skills.add(skill);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('AGREGAR'),
              ),
            ],
          ),
    );
  }

  // Mostrar diálogo para agregar tags a una categoría
  void _showTagsDialog(String categoryId, String categoryName) {
    // Lista de todos los tags posibles para esta categoría
    final List<String> allTags = _getTagsForCategory(categoryId);

    // Lista temporal de tags seleccionados
    final List<String> tempSelectedTags = List.from(
      _selectedTags[categoryId] ?? [],
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Seleccionar especialidades para $categoryName'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          allTags.map((tag) {
                            final isSelected = tempSelectedTags.contains(tag);
                            return CheckboxListTile(
                              title: Text(tag),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    tempSelectedTags.add(tag);
                                  } else {
                                    tempSelectedTags.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Guardar los tags seleccionados
                        this.setState(() {
                          _selectedTags[categoryId] = tempSelectedTags;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('GUARDAR'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Obtener tags para una categoría específica
  List<String> _getTagsForCategory(String categoryId) {
    switch (categoryId) {
      case '1': // Electricista
        return [
          'instalación',
          'cableado',
          'corto circuito',
          'enchufes',
          'iluminación',
          'transformadores',
        ];
      case '2': // Plomero
        return [
          'agua',
          'tuberías',
          'grifos',
          'inodoros',
          'duchas',
          'fugas',
          'desagües',
        ];
      case '3': // Técnico PC
        return [
          'reparación',
          'formateo',
          'virus',
          'mantenimiento',
          'hardware',
          'software',
          'redes',
        ];
      case '4': // Refrigeración
        return [
          'aire acondicionado',
          'refrigeradores',
          'congeladores',
          'mantenimiento',
          'instalación',
        ];
      default:
        return ['general', 'reparación', 'mantenimiento', 'instalación'];
    }
  }

  // Guardar cambios del perfil
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Subir imagen de perfil si hay una nueva
      String? profileImageUrl;
      if (_profileImageFile != null) {
        profileImageUrl = await _uploadProfileImage();
      }

      // Subir imagen de negocio si hay una nueva
      String? businessImageUrl;
      if (_businessImageFile != null) {
        businessImageUrl = await _uploadBusinessImage();
      }

      // En una implementación real, guardarías en Firestore
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simular guardado

      setState(() {
        _userData = {
          ..._userData,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _address ?? _addressController.text,
          'description': _descriptionController.text,
          'experience': _experienceController.text,
          'isIndividual': _isIndividual,
          'isAvailable': _isAvailable,
          'isServicesActive': _isServicesActive,
          'businessName': _businessNameController.text,
          'location':
              _location != null
                  ? {
                    'latitude': _location!.latitude,
                    'longitude': _location!.longitude,
                  }
                  : null,
          'coverageRadius': _coverageRadius,
        };

        // Actualizar imagen de perfil si se subió una nueva
        if (profileImageUrl != null) {
          _userData['profileImage'] = profileImageUrl;
          _profileImageFile = null;
        }

        // Actualizar imagen de negocio si se subió una nueva
        if (businessImageUrl != null) {
          _userData['businessImage'] = businessImageUrl;
          _businessImageFile = null;
        }

        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al guardar perfil: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mostrar avatar con imagen de perfil
  Widget _buildProfileAvatar() {
    const double radius = 50.0;

    // Si hay una imagen temporal seleccionada
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

    // Si hay una URL de imagen guardada
    if (_userData['profileImage'] != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                imageUrl: _userData['profileImage'],
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget:
                    (context, url, error) =>
                        Icon(Icons.person, size: radius, color: Colors.grey),
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    // Avatar por defecto si no hay imagen
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, size: radius, color: Colors.blue),
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

  // Mostrar imagen de negocio
  Widget _buildBusinessImage() {
    const double height = 150.0;

    // Si hay una imagen temporal seleccionada
    if (_businessImageFile != null) {
      return Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(_businessImageFile!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              right: 8,
              bottom: 8,
              child: InkWell(
                onTap: _pickBusinessImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
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

    // Si hay una URL de imagen guardada
    if (_userData['businessImage'] != null) {
      return Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _userData['businessImage'],
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.business,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              right: 8,
              bottom: 8,
              child: InkWell(
                onTap: _pickBusinessImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
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

    // Imagen por defecto si no hay imagen
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 50, color: Colors.grey.shade400),
                if (!_isEditing)
                  Text(
                    'Sin imagen de negocio',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            right: 8,
            bottom: 8,
            child: InkWell(
              onTap: _pickBusinessImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Mapa simplificado para mostrar la ubicación
  Widget _buildLocationMap() {
    if (_location == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No hay ubicación seleccionada')),
      );
    }

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: _location!, zoom: 14),
          markers: {
            Marker(
              markerId: const MarkerId('myLocation'),
              position: _location!,
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('coverageArea'),
              center: _location!,
              radius: _coverageRadius * 1000, // Convertir a metros
              fillColor: Colors.blue.withOpacity(0.2),
              strokeColor: Colors.blue.withOpacity(0.5),
              strokeWidth: 2,
            ),
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  // Tarjeta de disponibilidad y activación de servicios
  Widget _buildAvailabilityCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado de servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Activar/desactivar servicios (disponible en buscador)
            SwitchListTile(
              title: const Text(
                'Activar servicios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Cuando está activado, aparecerás en el buscador para que los clientes te encuentren',
              ),
              value: _isServicesActive,
              activeColor: Colors.green,
              onChanged:
                  _isEditing
                      ? (value) {
                        setState(() {
                          _isServicesActive = value;
                        });
                      }
                      : null,
            ),

            const Divider(),

            // Disponibilidad para trabajos
            SwitchListTile(
              title: const Text(
                'Disponible para trabajos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Indica si estás disponible para aceptar trabajos en este momento',
              ),
              value: _isAvailable,
              activeColor: Colors.green,
              onChanged:
                  _isEditing
                      ? (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      }
                      : null,
            ),

            if (!_isEditing) ...[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isServicesActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isServicesActive
                        ? 'Servicios activados'
                        : 'Servicios desactivados',
                    style: TextStyle(
                      color:
                          _isServicesActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildProfileContent();
  }

  // Construir el contenido del perfil
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de perfil básico
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar (ahora con imagen)
                      _buildProfileAvatar(),
                      const SizedBox(width: 16),
                      // Información del perfil
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isEditing
                                ? TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre',
                                    border: OutlineInputBorder(),
                                  ),
                                )
                                : Text(
                                  _userData['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            const SizedBox(height: 8),
                            Text(
                              _userData['email'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Valoración
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_userData['rating'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${_userData['reviewCount'] ?? 0} reseñas)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Trabajos completados
                            Text(
                              '${_userData['completedJobs'] ?? 0} trabajos completados',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botón de edición
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          tooltip: 'Editar perfil',
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tipo de técnico (individual o negocio)
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
                                  ? () => _toggleTechnicianType(true)
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  _isIndividual
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                              border: Border.all(
                                color:
                                    _isIndividual
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                                width: _isIndividual ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person,
                                  color:
                                      _isIndividual
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Individual',
                                  style: TextStyle(
                                    color:
                                        _isIndividual
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade700,
                                    fontWeight:
                                        _isIndividual
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
                                  ? () => _toggleTechnicianType(false)
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  !_isIndividual
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                              border: Border.all(
                                color:
                                    !_isIndividual
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                                width: !_isIndividual ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.business,
                                  color:
                                      !_isIndividual
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Negocio',
                                  style: TextStyle(
                                    color:
                                        !_isIndividual
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade700,
                                    fontWeight:
                                        !_isIndividual
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
                  if (!_isIndividual) ...[
                    const SizedBox(height: 16),
                    _isEditing
                        ? TextField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del negocio',
                            border: OutlineInputBorder(),
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nombre del negocio:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _userData['businessName'] ?? 'No especificado',
                            ),
                          ],
                        ),

                    const SizedBox(height: 16),
                    const Text(
                      'Imagen del negocio:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBusinessImage(),
                  ],

                  const SizedBox(height: 16),

                  // Teléfono
                  _isEditing
                      ? TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      )
                      : ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.phone, color: Colors.blue),
                        ),
                        title: const Text('Teléfono'),
                        subtitle: Text(_userData['phone'] ?? 'No especificado'),
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
                      ? TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción profesional',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      )
                      : Text(
                        _userData['description'] ?? 'No hay descripción',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),

                  const SizedBox(height: 16),

                  // Experiencia
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Experiencia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isEditing
                                ? TextField(
                                  controller: _experienceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Años de experiencia',
                                    border: OutlineInputBorder(),
                                  ),
                                )
                                : Text(
                                  _userData['experience'] ?? 'No especificada',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Botones de acción
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _profileImageFile = null;
                                _businessImageFile = null;
                                // Restaurar valores originales
                                _nameController.text = _userData['name'] ?? '';
                                _phoneController.text =
                                    _userData['phone'] ?? '';
                                _addressController.text =
                                    _userData['address'] ?? '';
                                _descriptionController.text =
                                    _userData['description'] ?? '';
                                _experienceController.text =
                                    _userData['experience'] ?? '';
                                _businessNameController.text =
                                    _userData['businessName'] ?? '';
                                _isIndividual =
                                    _userData['isIndividual'] ?? true;
                                _isAvailable = _userData['isAvailable'] ?? true;
                                _isServicesActive =
                                    _userData['isServicesActive'] ?? false;
                              });
                            },
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tarjeta de disponibilidad y activación
          _buildAvailabilityCard(),

          // Tarjeta de ubicación
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isEditing)
                        TextButton.icon(
                          onPressed: _selectLocation,
                          icon: const Icon(Icons.edit_location_alt),
                          label: const Text('Cambiar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mapa con ubicación
                  _buildLocationMap(),

                  const SizedBox(height: 12),

                  // Dirección
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address ?? 'Dirección no especificada',
                          style: TextStyle(color: Colors.grey.shade800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Radio de cobertura
                  Row(
                    children: [
                      const Icon(Icons.radar, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Radio de cobertura: ${_coverageRadius.toStringAsFixed(1)} km',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                  ),

                  if (_isEditing && _location == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectLocation,
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Seleccionar ubicación'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Categorías
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis categorías',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isEditing)
                        TextButton.icon(
                          onPressed: () {
                            // Mostrar diálogo de todas las categorías disponibles
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Seleccionar categorías'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children:
                                            _availableCategories.map((
                                              category,
                                            ) {
                                              final isSelected =
                                                  _selectedCategories.contains(
                                                    category.id,
                                                  );
                                              return CheckboxListTile(
                                                title: Text(category.name),
                                                value: isSelected,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _toggleCategory(
                                                      category.id,
                                                    );
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('CERRAR'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de categorías seleccionadas
                  _selectedCategories.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No has seleccionado ninguna categoría',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedCategories.length,
                        itemBuilder: (context, index) {
                          final categoryId = _selectedCategories[index];
                          final category = _availableCategories.firstWhere(
                            (c) => c.id == categoryId,
                            orElse:
                                () => TechnicianCategory(
                                  id: categoryId,
                                  name: 'Desconocida',
                                ),
                          );

                          // Obtener los tags seleccionados para esta categoría
                          final selectedTags = _selectedTags[categoryId] ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle:
                                  selectedTags.isNotEmpty
                                      ? Wrap(
                                        spacing: 4,
                                        children:
                                            selectedTags
                                                .map(
                                                  (tag) => Chip(
                                                    label: Text(
                                                      tag,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue.shade50,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                )
                                                .toList(),
                                      )
                                      : const Text(
                                        'Sin especialidades seleccionadas',
                                      ),
                              trailing:
                                  _isEditing
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed:
                                                () => _showTagsDialog(
                                                  categoryId,
                                                  category.name,
                                                ),
                                            tooltip: 'Editar especialidades',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedCategories.remove(
                                                  categoryId,
                                                );
                                                _selectedTags.remove(
                                                  categoryId,
                                                );
                                              });
                                            },
                                            tooltip: 'Eliminar categoría',
                                          ),
                                        ],
                                      )
                                      : null,
                              onTap:
                                  _isEditing
                                      ? () => _showTagsDialog(
                                        categoryId,
                                        category.name,
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),

          // Habilidades adicionales
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Habilidades adicionales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                          ),
                          onPressed: _showAddSkillDialog,
                          tooltip: 'Agregar habilidad',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de habilidades
                  _skills.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No has agregado habilidades adicionales',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _skills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor: Colors.blue.shade50,
                                deleteIcon:
                                    _isEditing
                                        ? const Icon(Icons.close, size: 16)
                                        : null,
                                onDeleted:
                                    _isEditing
                                        ? () {
                                          setState(() {
                                            _skills.remove(skill);
                                          });
                                        }
                                        : null,
                              );
                            }).toList(),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para categorías
class TechnicianCategory {
  final String id;
  final String name;

  TechnicianCategory({required this.id, required this.name});
}
