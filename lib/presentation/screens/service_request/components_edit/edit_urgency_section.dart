import 'package:flutter/material.dart';
import 'edit_form_data.dart';

class EditUrgencySection extends StatelessWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditUrgencySection({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text(
        'Urgente (solicito servicio para hoy)',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: formData.isUrgent,
      onChanged: (value) {
        onUpdate(() {
          formData.updateUrgency(value ?? false);
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
