// lib/presentation/screens/technician/components/location_map_card.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_service.dart';

class LocationMapCard extends StatelessWidget {
  final LatLng? location;
  final String? address;
  final double coverageRadius;
  final bool isEditing;
  final Function() onSelectLocation;
  final LocationService locationService;

  const LocationMapCard({
    Key? key,
    required this.location,
    required this.address,
    required this.coverageRadius,
    required this.isEditing,
    required this.onSelectLocation,
    required this.locationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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

            // Mapa
            _buildLocationMap(context),

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

  Widget _buildLocationMap(BuildContext context) {
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
          initialCameraPosition: CameraPosition(target: location!, zoom: 15),
          markers: {
            Marker(
              markerId: const MarkerId('myLocation'),
              position: location!,
              draggable: isEditing,
              onDragEnd:
                  isEditing
                      ? (newPosition) async {
                        // Este callback necesitará ser manejado en el widget padre
                        // Solo se proporciona como placeholder
                      }
                      : null,
            ),
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
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            // Puedes guardar el controlador aquí si necesitas
            Future.delayed(Duration(milliseconds: 500), () {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(location!, 15),
              );
            });
          },
        ),
      ),
    );
  }
}
