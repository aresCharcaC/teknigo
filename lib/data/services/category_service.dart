import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Convertir Color a hexadecimal
  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2, 8)}';

  // Obtener todas las categorías - CORREGIDO
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name') // Eliminado duplicado
        .snapshots()
        .map((snapshot) {
          print('Documentos recibidos: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) {
                print('Procesando documento: ${doc.id}');
                try {
                  return CategoryModel.fromFirestore(doc);
                } catch (e) {
                  print('Error al convertir documento ${doc.id}: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<CategoryModel>()
              .toList();
        });
  }

  // Obtener todas las categorías (una sola vez, no stream) - CORREGIDO
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('Obteniendo categorías...');
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name') // Eliminado duplicado
              .get();

      print('Documentos obtenidos: ${snapshot.docs.length}');

      final categories =
          snapshot.docs
              .map((doc) {
                try {
                  return CategoryModel.fromFirestore(doc);
                } catch (e) {
                  print('Error al convertir documento ${doc.id}: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<CategoryModel>()
              .toList();

      print('Categorías convertidas: ${categories.length}');
      return categories;
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // Buscar categorías por nombre o tags - CORREGIDO
  Future<List<CategoryModel>> searchCategories(String query) async {
    query = query.toLowerCase().trim();

    if (query.isEmpty) {
      return getCategories();
    }

    try {
      // Búsqueda por nombre o tags (manualmente porque Firestore no permite OR)
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      final results =
          snapshot.docs
              .map((doc) {
                try {
                  return CategoryModel.fromFirestore(doc);
                } catch (e) {
                  print(
                    'Error al convertir documento en búsqueda ${doc.id}: $e',
                  );
                  return null;
                }
              })
              .where((category) => category != null)
              .cast<CategoryModel>()
              .where((category) {
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
              })
              .toList();

      return results;
    } catch (e) {
      print('Error en searchCategories: $e');
      return [];
    }
  }

  // El resto del código permanece igual...

  // Obtener una categoría por ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      print('Error al obtener categoría por ID: $e');
      return null;
    }
  }

  // Crear una nueva categoría - CORRECCIÓN DEL COLORHEX
  Future<String> createCategory({
    required String name,
    String? description,
    String? iconUrl,
    required String iconName,
    required Color iconColor,
    required List<String> tags,
  }) async {
    try {
      final hexColor = _colorToHex(iconColor);
      print('Color convertido a hex: $hexColor');

      final data = {
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'iconName': iconName,
        'iconColor': hexColor,
        'tags': tags,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Datos de categoría a guardar: $data');
      final docRef = await _firestore.collection(_collection).add(data);
      print('Categoría creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear categoría: $e');
      rethrow;
    }
  }

  // Actualizar una categoría existente - CORRECCIÓN DEL COLORHEX
  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    String? iconUrl,
    required String iconName,
    required Color iconColor,
    required List<String> tags,
  }) async {
    try {
      final hexColor = _colorToHex(iconColor);

      await _firestore.collection(_collection).doc(id).update({
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'iconName': iconName,
        'iconColor': hexColor,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Categoría actualizada: $id');
    } catch (e) {
      print('Error al actualizar categoría: $e');
      rethrow;
    }
  }

  // Desactivar una categoría (soft delete)
  Future<void> deactivateCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Categoría desactivada: $id');
    } catch (e) {
      print('Error al desactivar categoría: $e');
      rethrow;
    }
  }

  // Eliminar una categoría permanentemente
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('Categoría eliminada: $id');
    } catch (e) {
      print('Error al eliminar categoría: $e');
      rethrow;
    }
  }

  // Agregar categorías predeterminadas (para inicialización)
  Future<void> addDefaultCategories() async {
    try {
      // Verificar si ya existen categorías
      final snapshot = await _firestore.collection(_collection).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        // Ya existen categorías, no crear las predeterminadas
        print('Ya existen categorías, no se crearán las predeterminadas');
        return;
      }

      // Lista de categorías predeterminadas
      final List<Map<String, dynamic>> defaultCategories = [
        {
          'name': 'Electricista',
          'description': 'Servicios de instalación y reparación eléctrica',
          'iconName': 'electrical_services',
          'iconColor': '#FFC107', // Amber
          'tags': [
            'electricidad',
            'instalación',
            'cableado',
            'corto circuito',
            'enchufes',
            'luces',
          ],
        },
        {
          'name': 'Plomero',
          'description': 'Servicios de plomería y fontanería',
          'iconName': 'plumbing',
          'iconColor': '#2196F3', // Blue
          'tags': ['agua', 'tuberías', 'grifos', 'inodoro', 'ducha', 'fugas'],
        },
        {
          'name': 'Técnico en PC',
          'description': 'Reparación y mantenimiento de computadoras',
          'iconName': 'computer',
          'iconColor': '#4CAF50', // Green
          'tags': [
            'computadora',
            'ordenador',
            'laptop',
            'software',
            'virus',
            'formateo',
          ],
        },
        {
          'name': 'Refrigeración',
          'description': 'Servicio para aires acondicionados y refrigeradores',
          'iconName': 'ac_unit',
          'iconColor': '#00BCD4', // Cyan
          'tags': [
            'aire acondicionado',
            'heladera',
            'congelador',
            'frío',
            'climatización',
          ],
        },
        {
          'name': 'Cerrajero',
          'description': 'Servicios de cerrajería y seguridad',
          'iconName': 'key',
          'iconColor': '#795548', // Brown
          'tags': ['llaves', 'cerraduras', 'puertas', 'seguridad', 'candados'],
        },
        {
          'name': 'Carpintero',
          'description': 'Trabajos en madera y reparaciones',
          'iconName': 'carpenter',
          'iconColor': '#FF9800', // Orange
          'tags': ['madera', 'muebles', 'puertas', 'armarios', 'reparación'],
        },
      ];

      print('Creando categorías predeterminadas...');

      // Crear batch para insertar todas las categorías de una vez
      final batch = _firestore.batch();

      for (final category in defaultCategories) {
        final docRef = _firestore.collection(_collection).doc();

        batch.set(docRef, {
          'name': category['name'],
          'description': category['description'],
          'iconUrl': null,
          'iconName': category['iconName'],
          'iconColor': category['iconColor'],
          'tags': category['tags'],
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Categorías predeterminadas creadas con éxito');
    } catch (e) {
      print('Error al crear categorías predeterminadas: $e');
    }
  }
}
