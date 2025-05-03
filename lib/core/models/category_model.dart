import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo que representa una categoría de servicios
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String iconName; // Nombre del icono de Flutter
  final Color iconColor; // Color del icono
  final List<String> tags; // Tags relacionados para búsqueda
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.iconName,
    required this.iconColor,
    required this.tags,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor desde un mapa (para convertir desde Firestore)
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Verificar iconColor
      final String colorString = data['iconColor'] ?? '#2196F3';

      // Convertir tags
      final List<dynamic> rawTags = data['tags'] ?? [];
      final List<String> tags = rawTags.map((tag) => tag.toString()).toList();

      // Convertir fechas
      final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
      final Timestamp? updatedAtTimestamp = data['updatedAt'] as Timestamp?;

      final DateTime createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();
      final DateTime updatedAt = updatedAtTimestamp?.toDate() ?? DateTime.now();

      return CategoryModel(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'],
        iconUrl: data['iconUrl'],
        iconName: data['iconName'] ?? 'category',
        iconColor: _colorFromHex(colorString),
        tags: tags,
        isActive: data['isActive'] ?? true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error en fromFirestore para ${doc.id}: $e');
      rethrow;
    }
  }

  // Métodos para convertir entre Color y Hex
  static Color _colorFromHex(String hexString) {
    try {
      // Asegurarse de que el string comience con #
      String formattedHex =
          hexString.startsWith('#') ? hexString : '#$hexString';

      // Verificar longitud
      if (formattedHex.length == 7) {
        // #RRGGBB
        // Añadir canal alpha FF
        formattedHex =
            '${formattedHex.substring(0, 1)}ff${formattedHex.substring(1)}';
      } else if (formattedHex.length == 9) {
        // #AARRGGBB
        // Ya está en formato correcto
      } else {
        print(
          'Formato de color hexadecimal inválido: $hexString. Usando azul por defecto.',
        );
        return Colors.blue;
      }

      // Quitar el # y convertir a int
      final hexValue = int.parse(formattedHex.substring(1), radix: 16);

      return Color(hexValue);
    } catch (e) {
      print('Error al convertir de hex a color: $e para $hexString');
      return Colors.blue; // Color por defecto
    }
  }

  static String colorToHex(Color color) {
    try {
      // Obtener valor hexadecimal sin alpha y agregar #
      final hex = '#${color.value.toRadixString(16).substring(2, 8)}';
      return hex;
    } catch (e) {
      print('Error al convertir de color a hex: $e');
      return '#2196F3'; // Color azul por defecto
    }
  }

  // Método para obtener un icono de Flutter basado en el nombre
  IconData getIcon() {
    switch (iconName) {
      case 'electrical_services':
        return Icons.electrical_services;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'plumbing':
        return Icons.plumbing;
      case 'thermostat':
        return Icons.thermostat;
      case 'computer':
        return Icons.computer;
      case 'smartphone':
        return Icons.smartphone;
      case 'wifi':
        return Icons.wifi;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'air':
        return Icons.air;
      case 'key':
        return Icons.key;
      case 'security':
        return Icons.security;
      case 'carpenter':
        return Icons.carpenter;
      case 'chair':
        return Icons.chair;
      case 'build':
        return Icons.build;
      case 'construction':
        return Icons.construction;
      case 'format_paint':
        return Icons.format_paint;
      case 'grass':
        return Icons.grass;
      case 'park':
        return Icons.park;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'clean_hands':
        return Icons.clean_hands;
      case 'car_repair':
        return Icons.car_repair;
      case 'tire_repair':
        return Icons.tire_repair;
      case 'memory':
        return Icons.memory;
      case 'microwave':
        return Icons.microwave;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'home':
        return Icons.home;
      case 'pool':
        return Icons.pool;
      case 'checkroom':
        return Icons.checkroom;
      case 'window':
        return Icons.window;
      case 'roofing':
        return Icons.roofing;
      case 'pest_control':
        return Icons.pest_control;
      case 'solar_power':
        return Icons.solar_power;
      case 'gas_meter':
        return Icons.gas_meter;
      case 'weekend':
        return Icons.weekend;
      case 'elderly':
        return Icons.elderly;
      case 'spa':
        return Icons.spa;
      case 'celebration':
        return Icons.celebration;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category; // Icono por defecto
    }
  }
}
