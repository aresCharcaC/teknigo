// lib/presentation/screens/home/components/location_input.dart
import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGetLocation;
  final VoidCallback onOpenMap;
  final bool readOnly;

  const LocationInput({
    Key? key,
    required this.controller,
    required this.onGetLocation,
    required this.onOpenMap,
    this.readOnly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Dirección',
        hintText: 'Ingresa tu dirección completa',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.location_on),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: onGetLocation,
              tooltip: 'Usar ubicación actual',
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: onOpenMap,
              tooltip: 'Seleccionar en mapa',
            ),
          ],
        ),
      ),
      readOnly: readOnly,
      onTap: readOnly ? onOpenMap : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La dirección es obligatoria para servicios en tu ubicación';
        }
        return null;
      },
    );
  }
}
