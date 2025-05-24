import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../technician/profile/location_picker_screen.dart';
import '../../home/components/location_input.dart';
import 'edit_form_data.dart';

class EditLocationSection extends StatelessWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditLocationSection({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación del servicio',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Radio buttons para seleccionar ubicación
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'En tu ubicación',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                value: true,
                groupValue: formData.inClientLocation,
                onChanged: (value) {
                  onUpdate(() {
                    formData.updateLocation(value!);
                  });
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'En local del técnico',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                value: false,
                groupValue: formData.inClientLocation,
                onChanged: (value) {
                  onUpdate(() {
                    formData.updateLocation(value!);
                  });
                },
                dense: true,
              ),
            ),
          ],
        ),

        // Campo de dirección si es en ubicación del cliente
        if (formData.inClientLocation) ...[
          const SizedBox(height: 16),
          LocationInput(
            controller: formData.addressController,
            onGetLocation: () => _getCurrentLocation(context),
            onOpenMap: () => _openLocationPicker(context),
          ),
        ],
      ],
    );
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final mapsService = MapsService();
      final location = await mapsService.getCurrentLocation();

      if (context.mounted) Navigator.pop(context);

      if (location != null && context.mounted) {
        onUpdate(() {
          formData.updateSelectedLocation(location);
        });

        final locationService = LocationService();
        final address = await locationService.getAddressFromLatLng(location);
        if (address != null && context.mounted) {
          formData.updateAddress(address);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener tu ubicación actual'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openLocationPicker(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationPickerScreen(
              initialPosition: formData.selectedLocation,
              coverageRadius: 5.0,
            ),
      ),
    );

    if (result != null &&
        result.containsKey('position') &&
        result.containsKey('address') &&
        context.mounted) {
      final position = result['position'];
      final address = result['address'] as String;

      if (position is LatLng) {
        onUpdate(() {
          formData.updateSelectedLocation(position);
          formData.updateAddress(address);
        });
      }
    }
  }
}
