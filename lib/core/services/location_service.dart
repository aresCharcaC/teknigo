// lib/core/services/location_service.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  final Location _location = Location();

  // Obtener la ubicación actual
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Verificar permisos de ubicación
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Obtener ubicación actual
    try {
      return await _location.getLocation();
    } catch (e) {
      print('Error al obtener ubicación: $e');
      return null;
    }
  }

  // Convertir coordenadas a dirección
  Future<String?> getAddressFromLatLng(LatLng position) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Error al obtener dirección: $e');
      return null;
    }
  }

  // Convertir dirección a coordenadas
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(
        address,
      );

      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
      return null;
    } catch (e) {
      print('Error al obtener coordenadas: $e');
      return null;
    }
  }

  // Calcular distancia entre dos puntos (en kilómetros)
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    // Convertir coordenadas a radianes
    final lat1 = _degreesToRadians(point1.latitude);
    final lon1 = _degreesToRadians(point1.longitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final lon2 = _degreesToRadians(point2.longitude);

    // Fórmula de Haversine
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  // Convertir grados a radianes
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
