// lib/presentation/screens/chat/components/location_message.dart (CORREGIDO)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMessage extends StatelessWidget {
  final LatLng location;
  final String address;

  const LocationMessage({Key? key, required this.location, this.address = ''})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Miniatura del mapa (estático, para evitar problemas de rendimiento)
          Expanded(
            child: Stack(
              children: [
                // Imagen estática de Google Maps (o placeholder)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  child: Container(
                    color: Colors.grey.shade300,
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

                // Marcador centrado
                Center(
                  child: Icon(Icons.location_on, color: Colors.red, size: 36),
                ),

                // Botón para abrir en Google Maps
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.open_in_new,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onPressed:
                          () => _openInGoogleMaps(
                            location.latitude,
                            location.longitude,
                          ),
                      tooltip: 'Abrir en Google Maps',
                      constraints: BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dirección (si está disponible)
          if (address.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                address,
                style: TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // Abrir ubicación en Google Maps
  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        print('No se pudo abrir la ubicación');
      }
    } catch (e) {
      print('Error al abrir mapa: $e');
    }
  }
}
