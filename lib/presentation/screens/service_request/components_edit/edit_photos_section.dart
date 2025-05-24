import 'package:flutter/material.dart';
import '../../home/components/photo_picker.dart';
import 'edit_form_data.dart';

class EditPhotosSection extends StatelessWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditPhotosSection({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoPicker(
      photoUrls: formData.photoUrls,
      onPhotosChanged: (urls) {
        onUpdate(() {
          formData.updatePhotoUrls(urls);
        });
      },
      onFilesSelected: (files) {
        onUpdate(() {
          formData.updatePhotoFiles(files);
        });
      },
    );
  }
}
