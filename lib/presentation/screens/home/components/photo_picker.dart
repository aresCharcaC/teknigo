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

  @override
  void initState() {
    super.initState();
  }

  void _pickImages(BuildContext context) {
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
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (photo != null) {
        // Validar el número máximo de imágenes
        if (_selectedFiles.length + widget.photoUrls.length >=
            AppConstants.maxImagesPerService) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Máximo ${AppConstants.maxImagesPerService} imágenes permitidas',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          _selectedFiles.add(File(photo.path));
        });

        // Notificar al padre sobre los nuevos archivos
        if (widget.onFilesSelected != null) {
          widget.onFilesSelected!(_selectedFiles);
        }
      }
    } catch (e) {
      print('Error al tomar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar foto: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _getImagesFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (images != null && images.isNotEmpty) {
        // Validar el número máximo de imágenes
        if (_selectedFiles.length + widget.photoUrls.length + images.length >
            AppConstants.maxImagesPerService) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Máximo ${AppConstants.maxImagesPerService} imágenes permitidas',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Añadir solo las imágenes que entren en el límite
          final remaining =
              AppConstants.maxImagesPerService -
              (_selectedFiles.length + widget.photoUrls.length);

          if (remaining > 0) {
            setState(() {
              for (int i = 0; i < remaining && i < images.length; i++) {
                _selectedFiles.add(File(images[i].path));
              }
            });

            // Notificar al padre sobre los nuevos archivos
            if (widget.onFilesSelected != null) {
              widget.onFilesSelected!(_selectedFiles);
            }
          }
          return;
        }

        setState(() {
          for (var image in images) {
            _selectedFiles.add(File(image.path));
          }
        });

        // Notificar al padre sobre los nuevos archivos
        if (widget.onFilesSelected != null) {
          widget.onFilesSelected!(_selectedFiles);
        }
      }
    } catch (e) {
      print('Error al seleccionar imágenes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imágenes: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    // Notificar al padre sobre los archivos actualizados
    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }
  }

  void _removePhotoUrl(int index) {
    final List<String> newUrls = List.from(widget.photoUrls);
    newUrls.removeAt(index);
    widget.onPhotosChanged(newUrls);
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _pickImages(context),
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
                            onTap: () => _removePhotoUrl(index),
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

                // Mostrar archivos locales seleccionados
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
                            onTap: () => _removeSelectedFile(index),
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
