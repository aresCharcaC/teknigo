import 'package:flutter/material.dart';
import 'edit_form_data.dart';

class EditBasicFields extends StatelessWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditBasicFields({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de título
        TextFormField(
          controller: formData.titleController,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ej: Reparación de refrigerador',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El título es obligatorio';
            }
            if (value.length < 5) {
              return 'El título debe tener al menos 5 caracteres';
            }
            return null;
          },
          maxLines: 1,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        // Campo de descripción
        TextFormField(
          controller: formData.descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción del problema',
            hintText: 'Describe tu problema con detalle',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La descripción es obligatoria';
            }
            if (value.length < 10) {
              return 'La descripción debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }
}
