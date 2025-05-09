// lib/data/repositories/search_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/technician_search_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener técnicos por ciudad con paginación
  Future<List<TechnicianSearchModel>> searchTechnicians({
    required String city,
    String? searchTerm,
    List<String>? categoryFilter,
    double? ratingFilter,
    bool? availableNowFilter,
    bool? businessFilter,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      // Construir la consulta base
      Query query = _firestore
          .collection(AppConstants.techniciansCollection)
          .where('isServicesActive', isEqualTo: true);

      // Aplicar filtros avanzados
      if (availableNowFilter == true) {
        query = query.where('isAvailable', isEqualTo: true);
      }

      if (businessFilter != null) {
        query = query.where('isIndividual', isEqualTo: !businessFilter);
      }

      // Para paginación
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Limitar resultados
      query = query.limit(limit);

      // Ejecutar la consulta
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Lista de resultados
      List<TechnicianSearchModel> technicians = [];

      // Para cada técnico, necesitamos obtener su información de usuario para la ciudad
      for (var doc in snapshot.docs) {
        try {
          final techId = doc.id;
          final techData = doc.data() as Map<String, dynamic>;

          // Obtener datos del usuario correspondiente
          final userDoc =
              await _firestore
                  .collection(AppConstants.usersCollection)
                  .doc(techId)
                  .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;

            // Verificar si coincide con la ciudad buscada
            final userCity = userData['city']?.toString().toLowerCase() ?? '';
            if (userCity == city.toLowerCase()) {
              // Crear modelo con datos combinados
              final technician = _createTechnicianModel(
                techId,
                techData,
                userData,
              );

              // Filtrar por texto de búsqueda si existe
              if (searchTerm != null && searchTerm.isNotEmpty) {
                if (technician.matchesSearchTerm(searchTerm)) {
                  technicians.add(technician);
                }
              } else {
                technicians.add(technician);
              }
            }
          }
        } catch (e) {
          print('Error procesando técnico ${doc.id}: $e');
        }

        // Si ya tenemos suficientes resultados, salimos del bucle
        if (technicians.length >= limit) {
          break;
        }
      }

      // Filtrar por categoría si está especificado
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        technicians =
            technicians.where((tech) {
              for (var cat in tech.categories) {
                if (categoryFilter.contains(cat)) {
                  return true;
                }
              }
              return false;
            }).toList();
      }

      // Filtrar por rating mínimo
      if (ratingFilter != null) {
        technicians =
            technicians.where((tech) => tech.rating >= ratingFilter).toList();
      }

      return technicians;
    } catch (e) {
      print('Error en búsqueda de técnicos: $e');
      return [];
    }
  }

  // Método auxiliar para crear el modelo de técnico
  TechnicianSearchModel _createTechnicianModel(
    String id,
    Map<String, dynamic> techData,
    Map<String, dynamic> userData,
  ) {
    // Determinar si es una cuenta de negocio
    final bool isBusinessAccount = !(techData['isIndividual'] ?? true);

    // Extraer categorías
    List<String> categories = [];
    if (techData['categories'] != null && techData['categories'] is List) {
      categories = List<String>.from(techData['categories']);
    }

    // Extraer habilidades
    List<String> skills = [];
    if (techData['skills'] != null && techData['skills'] is List) {
      skills = List<String>.from(techData['skills']);
    }

    return TechnicianSearchModel(
      id: id,
      name: techData['name'] ?? userData['name'] ?? 'Sin nombre',
      categories: categories,
      skills: skills,
      rating: (techData['rating'] ?? 0.0).toDouble(),
      reviewCount: (techData['reviewCount'] ?? 0),
      available: techData['isAvailable'] ?? false,
      profileImage:
          isBusinessAccount
              ? techData['businessImage']
              : techData['profileImage'],
      isBusinessAccount: isBusinessAccount,
      businessName: techData['businessName'],
      city: userData['city'] ?? '',
    );
  }

  // Método para obtener el último documento para paginación
  Future<DocumentSnapshot?> getLastDocumentForPagination(
    String city,
    int offset,
  ) async {
    try {
      final query = _firestore
          .collection(AppConstants.techniciansCollection)
          .where('isServicesActive', isEqualTo: true)
          .limit(offset);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty || snapshot.docs.length < offset) {
        return null;
      }

      return snapshot.docs.last;
    } catch (e) {
      print('Error al obtener documento para paginación: $e');
      return null;
    }
  }
}
