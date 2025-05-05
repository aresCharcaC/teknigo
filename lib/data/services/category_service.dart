// lib/data/services/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Convertir Color a hexadecimal
  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2, 8)}';

  // Obtener todas las categorías
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(_processCategoryDocs);
  }

  // Procesar documentos de categoría - método separado para reutilizar
  List<CategoryModel> _processCategoryDocs(QuerySnapshot snapshot) {
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
  }

  // Obtener todas las categorías (una sola vez, no stream)
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('Obteniendo categorías...');
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      return _processCategoryDocs(snapshot);
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // Buscar categorías por nombre o tags
  Future<List<CategoryModel>> searchCategories(String query) async {
    query = query.toLowerCase().trim();

    if (query.isEmpty) {
      return getCategories();
    }

    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      return _filterCategoriesByQuery(snapshot, query);
    } catch (e) {
      print('Error en searchCategories: $e');
      return [];
    }
  }

  // Filtrar categorías por consulta - método separado para mejor modularidad
  List<CategoryModel> _filterCategoriesByQuery(
    QuerySnapshot snapshot,
    String query,
  ) {
    return snapshot.docs
        .map((doc) {
          try {
            return CategoryModel.fromFirestore(doc);
          } catch (e) {
            print('Error al convertir documento en búsqueda ${doc.id}: $e');
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
  }

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

  // Métodos para operaciones CRUD

  // Crear una nueva categoría
  Future<String> createCategory({
    required String name,
    String? description,
    String? iconUrl,
    required String iconName,
    required Color iconColor,
    required List<String> tags,
  }) async {
    try {
      final data = _prepareCategoryData(
        name: name,
        description: description,
        iconUrl: iconUrl,
        iconName: iconName,
        iconColor: iconColor,
        tags: tags,
        isActive: true,
      );

      final docRef = await _firestore.collection(_collection).add(data);
      print('Categoría creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear categoría: $e');
      rethrow;
    }
  }

  // Preparar datos de categoría - método separado para reutilización
  Map<String, dynamic> _prepareCategoryData({
    required String name,
    String? description,
    String? iconUrl,
    required String iconName,
    required Color iconColor,
    required List<String> tags,
    required bool isActive,
  }) {
    final hexColor = _colorToHex(iconColor);
    print('Color convertido a hex: $hexColor');

    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'iconName': iconName,
      'iconColor': hexColor,
      'tags': tags,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Actualizar una categoría existente
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

  // Agregar categorías predeterminadas
  Future<void> addDefaultCategories() async {
    try {
      // Verificar si ya existen categorías
      final snapshot = await _firestore.collection(_collection).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        print('Ya existen categorías, no se crearán las predeterminadas');
        return;
      }

      await _createDefaultCategories();
    } catch (e) {
      print('Error al crear categorías predeterminadas: $e');
    }
  }

  // Crear categorías predeterminadas - extraído para mejorar legibilidad
  Future<void> _createDefaultCategories() async {
    print('Creando categorías predeterminadas...');

    // Lista de categorías predeterminadas (se podría mover a un archivo de constants)
    final List<Map<String, dynamic>> defaultCategories = [
      _defaultCategory(
        'Electricista',
        'Servicios de instalación y reparación eléctrica',
        'electrical_services',
        '#FFC107',
        [
          'electricidad',
          'instalación',
          'cableado',
          'corto circuito',
          'enchufes',
          'luces',
        ],
      ),
      _defaultCategory(
        'Plomero',
        'Servicios de plomería y fontanería',
        'plumbing',
        '#2196F3',
        ['agua', 'tuberías', 'grifos', 'inodoro', 'ducha', 'fugas'],
      ),
      // Resto de categorías...
    ];

    // Crear batch para insertar todas las categorías de una vez
    final batch = _firestore.batch();

    for (final category in defaultCategories) {
      final docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, category);
    }

    await batch.commit();
    print('Categorías predeterminadas creadas con éxito');
  }

  // Método para crear rápidamente un mapa de categoría predeterminada
  Map<String, dynamic> _defaultCategory(
    String name,
    String description,
    String iconName,
    String iconColor,
    List<String> tags,
  ) {
    return {
      'name': name,
      'description': description,
      'iconUrl': null,
      'iconName': iconName,
      'iconColor': iconColor,
      'tags': tags,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
