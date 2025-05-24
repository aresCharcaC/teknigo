// lib/presentation/screens/service_request/components_edit/edit_photos_section.dart - CORREGIDO
import 'dart:io';
import 'package:flutter/material.dart';
import '../../home/components/photo_picker.dart';
import 'edit_form_data.dart';

class EditPhotosSection extends StatefulWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditPhotosSection({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditPhotosSectionState createState() => _EditPhotosSectionState();
}

class _EditPhotosSectionState extends State<EditPhotosSection> {
  bool _isDisposed = false;

  @override
  void dispose() {
    print('EditPhotosSection dispose() llamado');
    _isDisposed = true;
    super.dispose();
  }

  void _handlePhotosChanged(List<String> urls) {
    if (_isDisposed || !mounted) {
      print('EditPhotosSection: Widget disposed, ignorando cambio de fotos');
      return;
    }

    print('EditPhotosSection: Manejando cambio de fotos: ${urls.length}');

    // Usar un timer en lugar de WidgetsBinding para evitar problemas de contexto
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        try {
          widget.onUpdate(() {
            widget.formData.updatePhotoUrls(urls);
          });
        } catch (e) {
          print('Error en _handlePhotosChanged: $e');
        }
      }
    });
  }

  void _handleFilesSelected(List<File> files) {
    if (_isDisposed || !mounted) {
      print(
        'EditPhotosSection: Widget disposed, ignorando selección de archivos',
      );
      return;
    }

    print(
      'EditPhotosSection: Manejando selección de archivos: ${files.length}',
    );

    // Usar un timer en lugar de WidgetsBinding para evitar problemas de contexto
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        try {
          widget.onUpdate(() {
            widget.formData.updatePhotoFiles(files);
          });
        } catch (e) {
          print('Error en _handleFilesSelected: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si está disposed, no construir nada
    if (_isDisposed) {
      print('EditPhotosSection: Widget disposed, retornando SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    return PhotoPicker(
      photoUrls: widget.formData.photoUrls,
      onPhotosChanged: _handlePhotosChanged,
      onFilesSelected: _handleFilesSelected,
    );
  }
}
