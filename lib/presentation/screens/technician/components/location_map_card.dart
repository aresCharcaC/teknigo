// lib/presentation/screens/technician/components/location_map_card.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapCard extends StatelessWidget {
  final LatLng? location;
  final String? address;
  final double coverageRadius;
  final bool isEditing;
  final Function() onSelectLocation;

  const LocationMapCard({
    Key? key,
    this.location,
    this.address,
    required this.coverageRadius,
    required this.isEditing,
    required this.onSelectLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isEditing)
                  TextButton.icon(
                    onPressed: onSelectLocation,
                    icon: const Icon(Icons.edit_location_alt),
                    label: const Text('Cambiar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Mapa con ubicación
            _buildLocationMap(),

            const SizedBox(height: 12),

            // Dirección
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address ?? 'Dirección no especificada',
                    style: TextStyle(color: Colors.grey.shade800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Radio de cobertura
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Radio de cobertura: ${coverageRadius.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),

            if (isEditing && location == null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onSelectLocation,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Seleccionar ubicación'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap() {
    if (location == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No hay ubicación seleccionada')),
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
              fillColor: Colors.blue,
              strokeColor: Colors.blue,
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
