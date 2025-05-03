import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'location_service.dart';

class MapsService {
  // Eliminar la ubicación estática y usar una variable dinámica
  LatLng? _defaultLocation;

  // Método para inicializar la ubicación por defecto (ubicación actual)
  Future<void> initializeDefaultLocation() async {
    final currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      _defaultLocation = currentLocation;
    }
  }

  // Obtener ubicación actual
  Future<LatLng?> getCurrentLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    try {
      final locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      print('Error al obtener ubicación: $e');
    }

    return null;
  }

  // Convertir coordenadas a dirección
  Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
    } catch (e) {
      print('Error al obtener dirección: $e');
    }

    return null;
  }

  // Convertir dirección a coordenadas
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await geocoding.locationFromAddress(address);

      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error al obtener coordenadas: $e');
    }

    return null;
  }

  // Obtener la ubicación por defecto (actual del usuario)
  LatLng? get defaultLocation => _defaultLocation;
}
