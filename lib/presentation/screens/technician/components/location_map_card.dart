// lib/presentation/screens/technician/components/location_map_card.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapCard extends StatelessWidget {
  final LatLng? location;
  final String? address;
  final double coverageRadius;
  final Function() onSelectLocation;
  final bool isEditing;

  const LocationMapCard({
    Key? key,
    required this.location,
    required this.address,
    required this.coverageRadius,
    required this.onSelectLocation,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación y área de cobertura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mapa
            _buildMap(context),

            const SizedBox(height: 16),

            // Dirección
            address != null && address!.isNotEmpty
                ? Row(
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
                        address!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                )
                : Text(
                  'Dirección no seleccionada',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

            const SizedBox(height: 12),

            // Radio de cobertura
            if (location != null)
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
                    style: const TextStyle(fontSize: 14),
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
      ),
    );
  }

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
