import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String
  iconName; // Nombre del icono de Flutter (para usar cuando no hay URL)
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

  // Convertir de Firestore a objeto
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      print('Convertir documento: ${doc.id}');
      print('Datos: $data');

      // Verificar iconColor
      final String colorString = data['iconColor'] ?? '#2196F3';
      print('String de color: $colorString');

      // Convertir tags
      final List<dynamic> rawTags = data['tags'] ?? [];
      final List<String> tags = rawTags.map((tag) => tag.toString()).toList();
      print('Tags convertidos: $tags');

      // Convertir fechas
      final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
      final Timestamp? updatedAtTimestamp = data['updatedAt'] as Timestamp?;

      final DateTime createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();
      final DateTime updatedAt = updatedAtTimestamp?.toDate() ?? DateTime.now();

      print('Fechas convertidas: $createdAt, $updatedAt');

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

  // Convertir a mapa para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    try {
      final hexColor = _colorToHex(iconColor);
      print('Convirtiendo a Firestore. Color hex: $hexColor');

      return {
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'iconName': iconName,
        'iconColor': hexColor,
        'tags': tags,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
    } catch (e) {
      print('Error en toFirestore: $e');
      rethrow;
    }
  }

  // Funciones auxiliares para convertir entre Color y Hex - MEJORADO
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

  static String _colorToHex(Color color) {
    try {
      // Obtener valor hexadecimal sin alpha y agregar #
      final hex = '#${color.value.toRadixString(16).substring(2, 8)}';
      return hex;
    } catch (e) {
      print('Error al convertir de color a hex: $e');
      return '#2196F3'; // Color azul por defecto
    }
  }
}
