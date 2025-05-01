import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _userData = {};

  // Controladores para la edición
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Índice para BottomNavigationBar
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  // Cargar datos del usuario
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En una implementación real, obtendrías estos datos de Firestore
      final userData = await _authService.getUserData();

      // Extraer photoURL para usuarios de Google u otros proveedores
      String? photoURL;

      // Para usuarios de Google, el photoURL vendría de FirebaseAuth
      final currentUser = _authService.currentUser;
      if (currentUser != null &&
          currentUser.photoURL != null &&
          currentUser.photoURL!.isNotEmpty) {
        photoURL = currentUser.photoURL;
      } else {
        // Para usuarios normales, podría estar guardado en Firestore
        photoURL = userData?['photoURL'];
      }

      // Datos simulados para completar el perfil
      final completeData = {
        ...userData ?? {},
        'phone': userData?['phone'] ?? '',
        'city': userData?['city'] ?? '',
        'country': userData?['country'] ?? '',
        'postalCode': userData?['postalCode'] ?? '',
        'joinDate': userData?['createdAt'] ?? DateTime.now(),
        'photoURL': photoURL, // URL de foto de perfil (Google, etc.)
      };

      setState(() {
        _userData = completeData;
        _isLoading = false;

        // Inicializar controladores
        _nameController.text = completeData['name'] ?? '';
        _phoneController.text = completeData['phone'] ?? '';
        _cityController.text = completeData['city'] ?? '';
        _countryController.text = completeData['country'] ?? '';
        _postalCodeController.text = completeData['postalCode'] ?? '';
      });
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Guardar cambios del perfil
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En una implementación real, guardarías estos datos en Firestore
      // Por ahora, solo actualizamos el estado local
      setState(() {
        _userData = {
          ..._userData,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'country': _countryController.text,
          'postalCode': _postalCodeController.text,
        };
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

  // Alternar modo de edición
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        // Si se cancela la edición, restaurar valores originales
        _nameController.text = _userData['name'] ?? '';
        _phoneController.text = _userData['phone'] ?? '';
        _cityController.text = _userData['city'] ?? '';
        _countryController.text = _userData['country'] ?? '';
        _postalCodeController.text = _userData['postalCode'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfileContent(),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Búsqueda'),
        ],
        onTap: (index) {
          if (index != _currentIndex) {
            Navigator.pop(context); // Regresar a la pantalla principal
          }
        },
      ),
    );
  }

  // Construir contenido del perfil
  Widget _buildProfileContent() {
    String firstLetter = '';
    if (_userData['name'] != null && _userData['name'].toString().isNotEmpty) {
      firstLetter = _userData['name'].toString().substring(0, 1).toUpperCase();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                        // Mostrar imagen de perfil si existe
                        (_userData['photoURL'] != null &&
                                _userData['photoURL'].toString().isNotEmpty)
                            ? Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    _userData['photoURL'].toString(),
                                  ),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Si hay error al cargar la imagen, mostrará la letra
                                    setState(() {
                                      _userData['photoURL'] = null;
                                    });
                                  },
                                ),
                              ),
                            )
                            : CircleAvatar(
                              radius: 50,
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
                        const SizedBox(height: 16),
                        // Nombre con texto que se ajusta para evitar desbordamientos
                        Container(
                          width: double.infinity,
                          child: Text(
                            _userData['name'] ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // Permite hasta 2 líneas
                            overflow:
                                TextOverflow
                                    .ellipsis, // Añade ... si es muy largo
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isEditing)
                          ElevatedButton.icon(
                            onPressed: () {
                              // En una implementación real, abrir selector de imagen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Próximamente: Cambiar foto'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Cambiar foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nombre
                  _buildProfileField(
                    label: 'Nombre completo',
                    value: _userData['name'] ?? '',
                    icon: Icons.person,
                    controller: _nameController,
                    isEditing: _isEditing,
                  ),

                  const SizedBox(height: 16),

                  // Email (no editable)
                  _buildProfileField(
                    label: 'Correo electrónico',
                    value: _userData['email'] ?? '',
                    icon: Icons.email,
                    isEditable: false,
                  ),

                  const SizedBox(height: 16),

                  // Teléfono
                  _buildProfileField(
                    label: 'Teléfono',
                    value: _userData['phone'] ?? '',
                    icon: Icons.phone,
                    controller: _phoneController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.phone,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Ciudad
                  _buildProfileField(
                    label: 'Ciudad',
                    value: _userData['city'] ?? '',
                    icon: Icons.location_city,
                    controller: _cityController,
                    isEditing: _isEditing,
                  ),

                  const SizedBox(height: 16),

                  // País
                  _buildProfileField(
                    label: 'País',
                    value: _userData['country'] ?? '',
                    icon: Icons.flag,
                    controller: _countryController,
                    isEditing: _isEditing,
                  ),

                  const SizedBox(height: 16),

                  // Código postal
                  _buildProfileField(
                    label: 'Código postal',
                    value: _userData['postalCode'] ?? '',
                    icon: Icons.mail,
                    controller: _postalCodeController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.number,
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
                    _userData['joinDate'] is DateTime
                        ? '${_userData['joinDate'].day}/${_userData['joinDate'].month}/${_userData['joinDate'].year}'
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
    );
  }

  // Campo de perfil (modo visualización o edición)
  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    TextEditingController? controller,
    bool isEditing = false,
    bool isEditable = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return isEditing && isEditable
        ? TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: keyboardType,
        )
        : ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            value.isNotEmpty ? value : 'No especificado',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
  }
}
