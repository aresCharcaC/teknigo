// lib/core/models/technician_search_model.dart
import 'package:flutter/material.dart';

class TechnicianSearchModel {
  final String id;
  final String name;
  final List<String> categories;
  final List<String> skills;
  final double rating;
  final int reviewCount;
  final bool available;
  final String? profileImage;
  final bool isBusinessAccount;
  final String? businessName;
  final String city;

  TechnicianSearchModel({
    required this.id,
    required this.name,
    required this.categories,
    required this.skills,
    required this.rating,
    required this.reviewCount,
    required this.available,
    this.profileImage,
    required this.isBusinessAccount,
    this.businessName,
    required this.city,
  });

  // Método de ayuda para comprobar si coincide con el texto de búsqueda
  bool matchesSearchTerm(String searchTerm) {
    final term = searchTerm.toLowerCase().trim();

    // Verificar en nombre
    if (name.toLowerCase().contains(term)) {
      return true;
    }

    // Verificar en nombre del negocio
    if (isBusinessAccount && businessName != null) {
      if (businessName!.toLowerCase().contains(term)) {
        return true;
      }
    }

    // Verificar en habilidades
    for (var skill in skills) {
      if (skill.toLowerCase().contains(term)) {
        return true;
      }
    }

    return false;
  }
}
