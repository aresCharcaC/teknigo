// lib/presentation/view_models/home_view_model.dart

import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/technician_repository.dart';
import '../../presentation/widgets/technician_card.dart';
import '../common/base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  final TechnicianRepository _technicianRepository = TechnicianRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<TechnicianItem> _topTechnicians = [];
  List<TechnicianItem> get topTechnicians => _topTechnicians;

  // Cargar técnicos mejor valorados
  Future<void> loadLocalTechnicians() async {
    return executeAsync<void>(() async {
      final userData = await _authRepository.getUserData();
      final String userCity = userData?['city'] ?? "Arequipa";

      final techniciansList = await _technicianRepository.getTechniciansInCity(
        userCity,
      );

      _topTechnicians =
          techniciansList.map((tech) {
            final bool isBusinessAccount = !(tech['isIndividual'] ?? true);
            String displayName =
                isBusinessAccount
                    ? (tech['businessName'] ?? tech['name'] ?? 'Empresa')
                    : (tech['name'] ?? 'Técnico');

            return TechnicianItem(
              id: tech['id'] ?? '',
              name: displayName,
              specialty: _getCategoryName(tech['categories']),
              rating: (tech['rating'] ?? 0.0).toDouble(),
              reviewCount: (tech['reviewCount'] ?? 0),
              available: tech['isAvailable'] ?? false,
              profileImage:
                  isBusinessAccount
                      ? tech['businessImage']
                      : tech['profileImage'],
              isBusinessAccount: isBusinessAccount,
            );
          }).toList();
    });
  }

  // Método auxiliar para obtener la especialidad principal (primera categoría)
  String _getCategoryName(List<dynamic>? categories) {
    if (categories == null || categories.isEmpty) {
      return 'General';
    }

    // Tomamos la primera categoría del técnico
    String categoryId = categories.first.toString();

    // Mapa de IDs a nombres de categorías
    // Puedes expandir este mapa con todos tus IDs y nombres de categorías
    Map<String, String> categoryNames = {
      '1': 'Electricista',
      '2': 'Técnico en Iluminación',
      '3': 'Plomero',
      '4': 'Técnico en Calefacción',
      '5': 'Técnico PC',
      '6': 'Reparador de Móviles',
      '7': 'Técnico en Redes',
      '8': 'Refrigeración',
      '9': 'Técnico en Ventilación',
      '10': 'Cerrajero',
      '11': 'Técnico en Alarmas',
      '12': 'Carpintero',
      '13': 'Ebanista',
      '14': 'Albañil',
      '15': 'Yesero',
      '16': 'Pintor',
      '17': 'Jardinero',
      '18': 'Otros',
      // Añade más categorías según sea necesario
    };

    // Intenta obtener el nombre de la categoría, o usa un valor por defecto
    return categoryNames[categoryId] ?? 'General';
  }

  // Método simplificado para obtener una distancia simulada
  double _calculateDistance(Map<String, dynamic> technicianData) {
    // Simulamos una distancia entre 0.5 y 10 km
    return ((technicianData['id'].hashCode % 95) / 10.0 + 0.5);
  }
}
