// lib/presentation/screens/technician/location_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/constants/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final double coverageRadius;

  const LocationPickerScreen({
    Key? key,
    this.initialPosition,
    this.coverageRadius = 10.0,
  }) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LocationService _locationService = LocationService();

  GoogleMapController? _controller;
  LatLng? _selectedPosition;
  String? _selectedAddress;
  bool _isLoading = false;
  Set<Marker> _markers = {};

  // Radio de cobertura en km
  double _coverageRadius = 10.0;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _coverageRadius = widget.coverageRadius;
    _updateMarkerAndCircle();

    if (_selectedPosition == null) {
      _getCurrentLocation();
    } else {
      _getAddressFromPosition(_selectedPosition!);
    }
  }

  // Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationData = await _locationService.getCurrentLocation();

      if (locationData != null) {
        setState(() {
          _selectedPosition = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          _updateMarkerAndCircle();
        });

        _getAddressFromPosition(_selectedPosition!);

        // Mover cámara a la ubicación
        if (_controller != null) {
          _controller!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedPosition!, 15.0),
          );
        }
      }
    } catch (e) {
      print('Error al obtener ubicación actual: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Obtener dirección a partir de coordenadas
  Future<void> _getAddressFromPosition(LatLng position) async {
    try {
      final address = await _locationService.getAddressFromLatLng(position);

      setState(() {
        _selectedAddress = address;
      });
    } catch (e) {
      print('Error al obtener dirección: $e');
    }
  }

  // Actualizar marcador y círculo de cobertura
  void _updateMarkerAndCircle() {
    if (_selectedPosition == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: _selectedPosition!,
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _selectedPosition == null || _selectedAddress == null
                    ? null
                    : () {
                      // Verificar que tenemos la dirección antes de devolver el resultado
                      if (_selectedAddress != null &&
                          _selectedAddress!.isNotEmpty) {
                        // Devolver la ubicación seleccionada con dirección
                        Navigator.pop(context, {
                          'position': _selectedPosition,
                          'address': _selectedAddress,
                          'coverageRadius': _coverageRadius,
                        });
                      } else {
                        // Mostrar error si no hay dirección
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No se pudo obtener la dirección. Intenta seleccionar otra ubicación.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
            tooltip: 'Confirmar ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          _selectedPosition == null
              ? const Center(child: Text('Cargando mapa...'))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition!,
                  zoom: 15.0,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                markers: _markers,
                circles:
                    _selectedPosition == null
                        ? {}
                        : {
                          Circle(
                            circleId: const CircleId('coverageArea'),
                            center: _selectedPosition!,
                            radius:
                                _coverageRadius * 1000, // Convertir a metros
                            fillColor: Colors.blue.withOpacity(0.2),
                            strokeColor: Colors.blue.withOpacity(0.5),
                            strokeWidth: 2,
                          ),
                        },
                onTap: (position) {
                  setState(() {
                    _selectedPosition = position;
                    _updateMarkerAndCircle();
                  });
                  _getAddressFromPosition(position);
                },
              ),

          // Panel inferior con información
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dirección seleccionada
                  const Text(
                    'Dirección:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Text(_selectedAddress ?? 'Dirección no disponible'),

                  const SizedBox(height: 16),

                  // Selector de radio de cobertura
                  Text(
                    'Radio de cobertura: ${_coverageRadius.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Slider(
                    value: _coverageRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_coverageRadius.toStringAsFixed(1)} km',
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _coverageRadius = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Mi ubicación'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
