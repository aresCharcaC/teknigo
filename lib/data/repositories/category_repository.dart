import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/models/category_model.dart';
import '../../core/constants/app_constants.dart';

/// Repositorio para manejar todas las operaciones relacionadas con categorías
///
/// Este repositorio encapsula toda la lógica de acceso a Firestore
/// para los datos de categorías.
class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de categorías predefinidas con sus propiedades
  final List<CategoryModel> _defaultCategories = [
    // Servicios eléctricos
    CategoryModel(
      id: '1',
      name: 'Electricista',
      description: 'Servicios de instalación y reparación eléctrica',
      iconName: 'electrical_services',
      iconColor: Color(0xFFFFC107), // Amber
      tags: [
        'electricidad',
        'instalación',
        'cableado',
        'corto circuito',
        'enchufes',
        'luces',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '2',
      name: 'Técnico en Iluminación',
      description: 'Instalación y reparación de sistemas de iluminación',
      iconName: 'lightbulb',
      iconColor: Color(0xFFFFEB3B), // Yellow
      tags: [
        'luces',
        'iluminación',
        'led',
        'decoración',
        'instalación',
        'reparación',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de plomería
    CategoryModel(
      id: '3',
      name: 'Plomero',
      description: 'Servicios de plomería y fontanería',
      iconName: 'plumbing',
      iconColor: Color(0xFF2196F3), // Blue
      tags: [
        'agua',
        'tuberías',
        'grifos',
        'inodoro',
        'ducha',
        'fugas',
        'desagües',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '4',
      name: 'Técnico en Calefacción',
      description: 'Instalación y reparación de sistemas de calefacción',
      iconName: 'thermostat',
      iconColor: Color(0xFFF44336), // Red
      tags: [
        'calefacción',
        'caldera',
        'radiadores',
        'termostato',
        'reparación',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de tecnología
    CategoryModel(
      id: '5',
      name: 'Técnico PC',
      description: 'Reparación y mantenimiento de computadoras',
      iconName: 'computer',
      iconColor: Color(0xFF4CAF50), // Green
      tags: [
        'computadora',
        'ordenador',
        'laptop',
        'software',
        'virus',
        'formateo',
        'mantenimiento',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '6',
      name: 'Reparador de Móviles',
      description: 'Reparación de teléfonos y dispositivos móviles',
      iconName: 'smartphone',
      iconColor: Color(0xFF03A9F4), // Light Blue
      tags: [
        'celular',
        'móvil',
        'pantalla',
        'batería',
        'reparación',
        'software',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '7',
      name: 'Técnico en Redes',
      description: 'Instalación y configuración de redes',
      iconName: 'wifi',
      iconColor: Color(0xFF009688), // Teal
      tags: [
        'internet',
        'wifi',
        'redes',
        'routers',
        'instalación',
        'configuración',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de climatización
    CategoryModel(
      id: '8',
      name: 'Refrigeración',
      description: 'Servicio para aires acondicionados y refrigeradores',
      iconName: 'ac_unit',
      iconColor: Color(0xFF00BCD4), // Cyan
      tags: [
        'aire acondicionado',
        'heladera',
        'congelador',
        'frío',
        'climatización',
        'reparación',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '9',
      name: 'Técnico en Ventilación',
      description: 'Instalación y mantenimiento de sistemas de ventilación',
      iconName: 'air',
      iconColor: Color(0xFF8BC34A), // Light Green
      tags: [
        'ventiladores',
        'extractores',
        'conductos',
        'instalación',
        'mantenimiento',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de seguridad
    CategoryModel(
      id: '10',
      name: 'Cerrajero',
      description: 'Servicios de cerrajería y seguridad',
      iconName: 'key',
      iconColor: Color(0xFF795548), // Brown
      tags: [
        'llaves',
        'cerraduras',
        'puertas',
        'seguridad',
        'candados',
        'emergencia',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '11',
      name: 'Técnico en Alarmas',
      description: 'Instalación y mantenimiento de sistemas de alarma',
      iconName: 'security',
      iconColor: Color(0xFFE91E63), // Pink
      tags: ['alarmas', 'seguridad', 'instalación', 'sensores', 'monitoreo'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de carpintería
    CategoryModel(
      id: '12',
      name: 'Carpintero',
      description: 'Trabajos en madera y reparaciones',
      iconName: 'carpenter',
      iconColor: Color(0xFFFF9800), // Orange
      tags: [
        'madera',
        'muebles',
        'puertas',
        'armarios',
        'reparación',
        'fabricación',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '13',
      name: 'Ebanista',
      description: 'Fabricación y restauración de muebles de madera',
      iconName: 'chair',
      iconColor: Color(0xFFFF5722), // Deep Orange
      tags: ['muebles', 'madera', 'diseño', 'restauración', 'artesanía'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de construcción
    CategoryModel(
      id: '14',
      name: 'Albañil',
      description: 'Servicios de construcción y reparación',
      iconName: 'build',
      iconColor: Color(0xFF9E9E9E), // Grey
      tags: [
        'construcción',
        'reparación',
        'paredes',
        'cemento',
        'obra',
        'reformas',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '15',
      name: 'Yesero',
      description: 'Instalación y reparación de yeso y drywall',
      iconName: 'construction',
      iconColor: Color(0xFF607D8B), // Blue Grey
      tags: ['yeso', 'paredes', 'techos', 'reformas', 'decoración'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de pintura
    CategoryModel(
      id: '16',
      name: 'Pintor',
      description: 'Servicios de pintura interior y exterior',
      iconName: 'format_paint',
      iconColor: Color(0xFF9C27B0), // Purple
      tags: [
        'pintura',
        'paredes',
        'decoración',
        'interior',
        'exterior',
        'reformas',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Servicios de jardinería
    CategoryModel(
      id: '17',
      name: 'Jardinero',
      description: 'Mantenimiento y diseño de jardines',
      iconName: 'grass',
      iconColor: Color(0xFF4CAF50), // Green
      tags: [
        'jardín',
        'plantas',
        'césped',
        'poda',
        'paisajismo',
        'mantenimiento',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Y las demás categorías... (hasta completar las 38)
  ];

  // Obtener todas las categorías
  Future<List<CategoryModel>> getCategories() async {
    try {
      // En lugar de obtener las categorías de Firestore, simplemente devolvemos
      // la lista predefinida
      return _defaultCategories;
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // Obtener todas las categorías como stream (simulado)
  Stream<List<CategoryModel>> getCategoriesStream() {
    // Simulamos un stream que emite una vez nuestra lista predefinida
    return Stream.value(_defaultCategories);
  }

  // Buscar categorías por nombre o tags
  Future<List<CategoryModel>> searchCategories(String query) async {
    query = query.toLowerCase().trim();

    if (query.isEmpty) {
      return _defaultCategories;
    }

    // Filtrar localmente en la lista predefinida
    return _defaultCategories.where((category) {
      // Verificar si el nombre contiene la consulta
      if (category.name.toLowerCase().contains(query)) {
        return true;
      }

      // Verificar si algún tag contiene la consulta
      for (final tag in category.tags) {
        if (tag.toLowerCase().contains(query)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  // Obtener una categoría por ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      // Buscar en la lista predefinida
      return _defaultCategories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Categoría no encontrada'),
      );
    } catch (e) {
      print('Error al obtener categoría por ID: $e');
      return null;
    }
  }
}
