// lib/presentation/screens/service_request/components_edit/edit_photos_section.dart
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
    _isDisposed = true;
    super.dispose();
  }

  void _handlePhotosChanged(List<String> urls) {
    if (_isDisposed) return;

    // Usar WidgetsBinding para diferir la actualización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        widget.onUpdate(() {
          widget.formData.updatePhotoUrls(urls);
        });
      }
    });
  }

  void _handleFilesSelected(List<File> files) {
    if (_isDisposed) return;

    // Usar WidgetsBinding para diferir la actualización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        widget.onUpdate(() {
          widget.formData.updatePhotoFiles(files);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PhotoPicker(
      photoUrls: widget.formData.photoUrls,
      onPhotosChanged: _handlePhotosChanged,
      onFilesSelected: _handleFilesSelected,
    );
  }
}
