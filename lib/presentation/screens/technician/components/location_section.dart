// lib/presentation/screens/technician/components/location_section.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../technician/components/profile_section.dart';

class LocationSection extends StatelessWidget {
  final bool isEditing;
  final LatLng? location;
  final String? address;
  final double coverageRadius;
  final Function() onSelectLocation;

  const LocationSection({
    Key? key,
    required this.isEditing,
    required this.location,
    required this.address,
    required this.coverageRadius,
    required this.onSelectLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'Ubicación y cobertura',
      icon: Icons.location_on,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mapa
          _buildMap(context),

          const SizedBox(height: 16),

          // Dirección
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address ?? 'Dirección no especificada',
                  style: TextStyle(color: address == null ? Colors.grey : null),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Radio de cobertura
          Row(
            children: [
              Icon(
                Icons.radar,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Radio de cobertura: ${coverageRadius.toStringAsFixed(1)} km',
              ),
            ],
          ),

          // Botón para seleccionar ubicación (solo en modo edición)
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: onSelectLocation,
                  icon: const Icon(Icons.edit_location_alt),
                  label: Text(
                    location == null
                        ? 'Seleccionar ubicación'
                        : 'Cambiar ubicación',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Construir mapa
  Widget _buildMap(BuildContext context) {
    if (location == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Ubicación no seleccionada',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
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
          initialCameraPosition: CameraPosition(target: location!, zoom: 14),
          markers: {
            Marker(markerId: const MarkerId('myLocation'), position: location!),
          },
          circles: {
            Circle(
              circleId: const CircleId('coverageArea'),
              center: location!,
              radius: coverageRadius * 1000, // Convertir a metros
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
}
