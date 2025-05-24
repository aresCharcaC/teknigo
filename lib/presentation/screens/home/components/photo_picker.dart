// lib/presentation/screens/home/components/photo_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';

class PhotoPicker extends StatefulWidget {
  final List<String> photoUrls;
  final Function(List<String>) onPhotosChanged;
  final Function(List<File>)? onFilesSelected;

  const PhotoPicker({
    Key? key,
    required this.photoUrls,
    required this.onPhotosChanged,
    this.onFilesSelected,
  }) : super(key: key);

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isDisposed = false;

  // Referencia segura al ScaffoldMessenger
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();

    // Notificación inicial diferida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNotifyParent();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Guardar referencia segura al ScaffoldMessenger
    try {
      _scaffoldMessenger = ScaffoldMessenger.of(context);
    } catch (e) {
      print('Error getting ScaffoldMessenger reference: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scaffoldMessenger = null;
    super.dispose();
  }

  // Método seguro para mostrar SnackBar
  void _showSafeSnackBar(String message) {
    if (_isDisposed || !mounted) return;

    final messenger = _scaffoldMessenger;
    if (messenger != null) {
      try {
        messenger.showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      } catch (e) {
        print('Error showing SnackBar: $e');
      }
    }
  }

  // Método seguro para notificar al padre
  void _safeNotifyParent() {
    if (_isDisposed || widget.onFilesSelected == null) return;

    try {
      widget.onFilesSelected!(_selectedFiles);
    } catch (e) {
      print('Error notifying parent: $e');
    }
  }

  // Método seguro para notificar cambios en URLs
  void _safeNotifyUrlChange(List<String> newUrls) {
    if (_isDisposed) return;

    try {
      widget.onPhotosChanged(newUrls);
    } catch (e) {
      print('Error notifying URL change: $e');
    }
  }

  void _pickImages(BuildContext context) {
    if (_isDisposed) return;

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
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImagesFromGallery();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _getImageFromCamera() async {
    if (_isDisposed) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (photo != null && !_isDisposed && mounted) {
        // Validar máximo número de imágenes
        if (_selectedFiles.length + widget.photoUrls.length >=
            AppConstants.maxImagesPerService) {
          _showSafeSnackBar(
            'Máximo ${AppConstants.maxImagesPerService} imágenes permitidas',
          );
          return;
        }

        setState(() {
          _selectedFiles.add(File(photo.path));
        });

        // Notificar al padre de forma diferida
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _safeNotifyParent();
        });
      }
    } catch (e) {
      print('Error al tomar foto: $e');
      if (!_isDisposed) {
        _showSafeSnackBar('Error al tomar foto: $e');
      }
    }
  }

  Future<void> _getImagesFromGallery() async {
    if (_isDisposed) return;

    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (images != null && images.isNotEmpty && !_isDisposed && mounted) {
        // Validar máximo número de imágenes
        if (_selectedFiles.length + widget.photoUrls.length + images.length >
            AppConstants.maxImagesPerService) {
          _showSafeSnackBar(
            'Máximo ${AppConstants.maxImagesPerService} imágenes permitidas',
          );

          // Añadir solo las imágenes que caben
          final remaining =
              AppConstants.maxImagesPerService -
              (_selectedFiles.length + widget.photoUrls.length);

          if (remaining > 0) {
            setState(() {
              for (int i = 0; i < remaining && i < images.length; i++) {
                _selectedFiles.add(File(images[i].path));
              }
            });

            // Notificar al padre de forma diferida
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _safeNotifyParent();
            });
          }
          return;
        }

        setState(() {
          for (var image in images) {
            _selectedFiles.add(File(image.path));
          }
        });

        // Notificar al padre de forma diferida
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _safeNotifyParent();
        });
      }
    } catch (e) {
      print('Error al seleccionar imágenes: $e');
      if (!_isDisposed) {
        _showSafeSnackBar('Error al seleccionar imágenes: $e');
      }
    }
  }

  void _removeSelectedFile(int index) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _selectedFiles.removeAt(index);
    });

    // Notificar al padre de forma diferida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNotifyParent();
    });
  }

  void _removePhotoUrl(int index) {
    if (_isDisposed) return;

    final List<String> newUrls = List.from(widget.photoUrls);
    newUrls.removeAt(index);

    // Notificar cambio de forma diferida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNotifyUrlChange(newUrls);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si el widget está disposed, mostrar versión mínima
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotos (Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _isDisposed ? null : () => _pickImages(context),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Agregar'),
            ),
          ],
        ),

        // Mostrar imágenes seleccionadas y existentes
        if (_selectedFiles.isNotEmpty || widget.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Mostrar fotos existentes
                ...widget.photoUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stack) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap:
                                _isDisposed
                                    ? null
                                    : () => _removePhotoUrl(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                }),

                // Mostrar archivos seleccionados localmente
                ..._selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stack) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap:
                                _isDisposed
                                    ? null
                                    : () => _removeSelectedFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
