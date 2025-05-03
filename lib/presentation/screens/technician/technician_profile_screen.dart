// lib/presentation/screens/technician/technician_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../data/repositories/technician_repository.dart';
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
  // Repositorios y servicios
  final TechnicianRepository _repository = TechnicianRepository();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();
  final ImagePicker _imagePicker = ImagePicker();

  // Estados
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic> _technicianData = {};

  // Imágenes temporales
  File? _profileImageFile;
  File? _businessImageFile;

  // Estados de técnico
  bool _isIndividual = true;
  bool _isServicesActive = false;
  bool _isAvailable = true;

  // Ubicación
  LatLng? _location;
  String? _address;
  double _coverageRadius = 10.0;

  // Categorías y habilidades
  List<String> _selectedCategories = [];
  List<String> _skills = [];

  // Controladores para formularios
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _businessNameController = TextEditingController();

  // Lista completa de categorías disponibles
  final List<CategoryItem> _availableCategories = [
    CategoryItem(id: '1', name: 'Electricista'),
    CategoryItem(id: '2', name: 'Técnico en Iluminación'),
    CategoryItem(id: '3', name: 'Plomero'),
    CategoryItem(id: '4', name: 'Técnico en Calefacción'),
    CategoryItem(id: '5', name: 'Técnico PC'),
    CategoryItem(id: '6', name: 'Reparador de Móviles'),
    CategoryItem(id: '7', name: 'Técnico en Redes'),
    CategoryItem(id: '8', name: 'Refrigeración'),
    CategoryItem(id: '9', name: 'Técnico en Ventilación'),
    CategoryItem(id: '10', name: 'Cerrajero'),
    CategoryItem(id: '11', name: 'Técnico en Alarmas'),
    CategoryItem(id: '12', name: 'Carpintero'),
    CategoryItem(id: '13', name: 'Ebanista'),
    CategoryItem(id: '14', name: 'Albañil'),
    CategoryItem(id: '15', name: 'Yesero'),
    CategoryItem(id: '16', name: 'Pintor'),
    CategoryItem(id: '17', name: 'Jardinero'),
    CategoryItem(id: '18', name: 'Paisajista'),
    CategoryItem(id: '19', name: 'Limpieza'),
    CategoryItem(id: '20', name: 'Limpieza de Alfombras'),
    CategoryItem(id: '21', name: 'Mecánico'),
    CategoryItem(id: '22', name: 'Técnico en Neumáticos'),
    CategoryItem(id: '23', name: 'Electrónica'),
    CategoryItem(id: '24', name: 'Técnico en Electrodomésticos'),
    CategoryItem(id: '25', name: 'Mudanzas'),
    CategoryItem(id: '26', name: 'Decorador de Interiores'),
    CategoryItem(id: '27', name: 'Técnico en Piscinas'),
    CategoryItem(id: '28', name: 'Costurero'),
    CategoryItem(id: '29', name: 'Vidriero'),
    CategoryItem(id: '30', name: 'Técnico en Tejados'),
    CategoryItem(id: '31', name: 'Control de Plagas'),
    CategoryItem(id: '32', name: 'Técnico en Paneles Solares'),
    CategoryItem(id: '33', name: 'Técnico en Gas'),
    CategoryItem(id: '34', name: 'Tapicero'),
    CategoryItem(id: '35', name: 'Cuidador de Ancianos'),
    CategoryItem(id: '36', name: 'Esteticista'),
    CategoryItem(id: '37', name: 'Organizador de Eventos'),
    CategoryItem(id: '38', name: 'Otro'),
  ];

  @override
  void initState() {
    super.initState();
    _loadTechnicianData();
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

  // Cargar datos del técnico
  Future<void> _loadTechnicianData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _repository.getTechnicianProfile();

      if (data != null) {
        setState(() {
          _technicianData = data;
          _isIndividual = data['isIndividual'] ?? true;
          _isServicesActive = data['isServicesActive'] ?? false;
          _isAvailable = data['isAvailable'] ?? true;

          // Extraer ubicación
          if (data['location'] != null) {
            final locationData = data['location'];
            if (locationData is Map<String, dynamic>) {
              // Si location viene como un Map
              if (locationData.containsKey('latitude') &&
                  locationData.containsKey('longitude')) {
                _location = LatLng(
                  locationData['latitude'] as double,
                  locationData['longitude'] as double,
                );
              }
            } else if (locationData.runtimeType.toString() == 'GeoPoint') {
              // Si es un GeoPoint de Firestore
              _location = LatLng(
                (locationData as dynamic).latitude as double,
                (locationData as dynamic).longitude as double,
              );
            }
          }

          _address = data['address'] as String?;
          _coverageRadius = data['coverageRadius'] as double? ?? 10.0;

          // Extraer categorías
          if (data['categories'] != null && data['categories'] is List) {
            _selectedCategories = List<String>.from(data['categories']);
          }

          // Extraer habilidades
          if (data['skills'] != null && data['skills'] is List) {
            _skills = List<String>.from(data['skills']);
          }
        });

        // Inicializar controladores solo con datos existentes
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _experienceController.text = data['experience'] ?? '';
        _businessNameController.text = data['businessName'] ?? '';
      }
    } catch (e) {
      print('Error al cargar datos del técnico: $e');

      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Guardar cambios del perfil
  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Datos básicos a actualizar
      final updatedData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'description': _descriptionController.text,
        'experience': _experienceController.text,
        'isIndividual': _isIndividual,
        'isAvailable': _isAvailable,
        'isServicesActive': _isServicesActive,
        'businessName': _businessNameController.text,
        'categories': _selectedCategories,
        'skills': _skills,
      };

      // Subir imágenes si hay nuevas
      if (_profileImageFile != null) {
        final profileUrl = await _repository.uploadProfileImage(
          _profileImageFile!,
        );
        if (profileUrl != null) {
          updatedData['profileImage'] = profileUrl;
        }
      }

      if (_businessImageFile != null) {
        final businessUrl = await _repository.uploadBusinessImage(
          _businessImageFile!,
        );
        if (businessUrl != null) {
          updatedData['businessImage'] = businessUrl;
        }
      }

      // Guardar cambios en Firestore
      final success = await _repository.updateTechnicianProfile(updatedData);

      if (success) {
        // Actualizar datos locales
        setState(() {
          _technicianData = {..._technicianData, ...updatedData};
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar el perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error al guardar perfil: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Alternar modo de edición
  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Cancelar edición y restaurar valores originales
        _isEditing = false;
        _profileImageFile = null;
        _businessImageFile = null;

        // Restaurar controladores
        _nameController.text = _technicianData['name'] ?? '';
        _phoneController.text = _technicianData['phone'] ?? '';
        _addressController.text = _technicianData['address'] ?? '';
        _descriptionController.text = _technicianData['description'] ?? '';
        _experienceController.text = _technicianData['experience'] ?? '';
        _businessNameController.text = _technicianData['businessName'] ?? '';

        // Restaurar estados
        _isIndividual = _technicianData['isIndividual'] ?? true;
        _isServicesActive = _technicianData['isServicesActive'] ?? false;
        _isAvailable = _technicianData['isAvailable'] ?? true;
      } else {
        _isEditing = true;
      }
    });
  }

  // Construir perfil completo
  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isSaving) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Técnico'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil básico (avatar, nombre, etc.)
            _buildProfileCard(),

            // Tarjeta de disponibilidad
            _buildAvailabilityCard(),

            // Tarjeta de ubicación
            _buildLocationCard(),

            // Tarjeta de categorías
            _buildCategoriesCard(),

            // Tarjeta de habilidades
            _buildSkillsCard(),
          ],
        ),
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              )
              : null,
    );
  }

  // Tarjeta de perfil básico
  Widget _buildProfileCard() {
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
                _buildProfileAvatar(),

                const SizedBox(width: 16),

                // Información básica
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      _isEditing
                          ? TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                          )
                          : Text(
                            _technicianData['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                      const SizedBox(height: 8),

                      // Email (no editable)
                      Text(
                        _technicianData['email'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      if (!_isEditing && _technicianData['rating'] != null) ...[
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
                              '${_technicianData['rating']?.toStringAsFixed(1) ?? '0.0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${_technicianData['reviewCount'] ?? 0} reseñas)',
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
            _buildTechnicianTypeSelector(),

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
                  subtitle: Text(_technicianData['phone'] ?? 'No especificado'),
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
                  _technicianData['description'] ?? 'No hay descripción',
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
                ? TextField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Años de experiencia',
                    border: OutlineInputBorder(),
                  ),
                )
                : Text(
                  _technicianData['experience'] ?? 'No especificada',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
          ],
        ),
      ),
    );
  }

  // Construir avatar de perfil
  Widget _buildProfileAvatar() {
    const double radius = 50.0;

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
    if (_technicianData['profileImage'] != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                imageUrl: _technicianData['profileImage'],
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

    // Avatar por defecto
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            _getInitials(),
            style: TextStyle(
              fontSize: 30,
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

  // Obtener iniciales del nombre
  String _getInitials() {
    final name = _technicianData['name'] ?? '';
    if (name.isEmpty) return '';

    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0];
    }

    return '';
  }

  // Selector de tipo de técnico
  Widget _buildTechnicianTypeSelector() {
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
                onTap: _isEditing ? () => _updateTechnicianType(true) : null,
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
                onTap: _isEditing ? () => _updateTechnicianType(false) : null,
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
                        'Empresa',
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
                  labelText: 'Nombre de la empresa',
                  border: OutlineInputBorder(),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre de la empresa:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_technicianData['businessName'] ?? 'No especificado'),
                ],
              ),
        ],
      ],
    );
  }

  // Actualizar tipo de técnico
  void _updateTechnicianType(bool isIndividual) {
    setState(() {
      _isIndividual = isIndividual;
    });
  }

  // Seleccionar imagen de perfil
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
                    await _getImageFromSource(
                      ImageSource.camera,
                      isProfile: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImageFromSource(
                      ImageSource.gallery,
                      isProfile: true,
                    );
                  },
                ),
                if (_technicianData['profileImage'] != null)
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
                        await _removeProfileImage();
                      }
                    },
                  ),
              ],
            ),
          ),
    );
  }

  // Obtener imagen desde fuente
  Future<void> _getImageFromSource(
    ImageSource source, {
    bool isProfile = true,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _profileImageFile = File(pickedFile.path);
          } else {
            _businessImageFile = File(pickedFile.path);
          }
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

  // Eliminar imagen de perfil
  Future<void> _removeProfileImage() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final profileUrl = _technicianData['profileImage'];
      if (profileUrl != null) {
        // Eliminar de Storage
        final success = await _storageService.deleteImageByUrl(profileUrl);

        if (success) {
          // Actualizar Firestore
          await _repository.updateTechnicianProfile({'profileImage': null});

          // Actualizar datos locales
          setState(() {
            _technicianData['profileImage'] = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
        _isSaving = false;
      });
    }
  }

  // Tarjeta de disponibilidad
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

  // Tarjeta de ubicación
  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Mapa
            _buildLocationMap(),

            const SizedBox(height: 12),

            // Dirección
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _address ?? 'Dirección no especificada',
                    style: TextStyle(color: Colors.grey.shade800),
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
    );
  }

  // Construir mapa con ubicación
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

  // Seleccionar ubicación
  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialPosition: _location),
      ),
    );

    if (result != null) {
      final position = result['position'] as LatLng?;
      final address = result['address'] as String?;
      final radius = result['coverageRadius'] as double? ?? 10.0;

      if (position != null && address != null) {
        setState(() {
          _isSaving = true;
        });

        try {
          // Actualizar en Firestore
          final success = await _repository.updateLocation(
            position,
            address,
            radius,
          );

          if (success) {
            // Actualizar datos locales
            setState(() {
              _location = position;
              _address = address;
              _coverageRadius = radius;
              _addressController.text = address;
            });
          }
        } catch (e) {
          print('Error al actualizar ubicación: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar ubicación: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  // Tarjeta de categorías (simplificada, solo nombres de categorías)
  Widget _buildCategoriesCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis categorías',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isEditing)
                  TextButton.icon(
                    onPressed: _showCategoriesDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de categorías
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
                : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _selectedCategories.map((categoryId) {
                        // Encontrar el nombre de la categoría
                        final category = _availableCategories.firstWhere(
                          (c) => c.id == categoryId,
                          orElse:
                              () => CategoryItem(
                                id: categoryId,
                                name: 'Desconocida',
                              ),
                        );

                        return Chip(
                          label: Text(category.name),
                          backgroundColor: Colors.blue.shade50,
                          deleteIcon:
                              _isEditing
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                          onDeleted:
                              _isEditing
                                  ? () {
                                    setState(() {
                                      _selectedCategories.remove(categoryId);
                                    });
                                  }
                                  : null,
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  // Mostrar diálogo para seleccionar categorías
  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Seleccionar categorías'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400, // Altura fija para el diálogo
                  child: ListView.builder(
                    itemCount: _availableCategories.length,
                    itemBuilder: (context, index) {
                      final category = _availableCategories[index];
                      final isSelected = _selectedCategories.contains(
                        category.id,
                      );

                      return CheckboxListTile(
                        title: Text(category.name),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedCategories.add(category.id);
                            } else {
                              _selectedCategories.remove(category.id);
                            }
                          });

                          // También actualizar el estado principal
                          this.setState(() {});
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CERRAR'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Tarjeta de habilidades
  Widget _buildSkillsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
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
    );
  }

  // Mostrar diálogo para añadir habilidad
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
              textCapitalization: TextCapitalization.sentences,
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
}

// Clase para categorías (simplificada)
class CategoryItem {
  final String id;
  final String name;

  CategoryItem({required this.id, required this.name});
}
