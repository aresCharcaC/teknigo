import 'package:flutter/material.dart';

/// Clase que define todos los colores utilizados en la aplicación.
/// Utiliza esta clase como referencia única para todos los colores
/// para mantener consistencia en el diseño.
class AppColors {
  // Color primario y sus variantes
  static const Color primary = Color(0xFF2196F3); // Azul actual
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryExtraLight = Color(0xFFBBDEFB);

  // Color secundario y sus variantes (verde teal, complementa bien al azul)
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryLight = Color(0xFF5DF2D6);
  static const Color secondaryDark = Color(0xFF008E76);

  // Color de acento (naranja, contrasta bien con el azul)
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);

  // Colores de fondo
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF0F0F0);

  // Colores para texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFEB3B);
  static const Color info = Color(0xFF2196F3);

  // Colores para bordes y divisores
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFDDDDDD);

  // Colores para tarjetas y superficies
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Colores para indicadores
  static const Color available = Color(0xFF4CAF50); // Verde
  static const Color unavailable = Color(0xFFE0E0E0); // Gris
  static const Color busy = Color(0xFFF44336); // Rojo

  // Colores para categorías
  static Map<String, Color> categoryColors = {
    'Electricista': Color(0xFFFFC107), // Amber
    'Plomero': Color(0xFF2196F3), // Azul
    'Técnico PC': Color(0xFF4CAF50), // Verde
    'Refrigeración': Color(0xFF00BCD4), // Cyan
    'Cerrajero': Color(0xFF795548), // Marrón
    'Carpintero': Color(0xFFFF9800), // Naranja
    'Pintor': Color(0xFF9C27B0), // Púrpura
    'Albañil': Color(0xFF607D8B), // Gris azulado
    'Jardinero': Color(0xFF8BC34A), // Verde claro
  };

  // Método para obtener un color aleatorio pero consistente basado en un string
  static Color getColorFromString(String text) {
    if (text.isEmpty) return primary;

    if (categoryColors.containsKey(text)) {
      return categoryColors[text]!;
    }

    // Si la categoría no está predefinida, genera un color basado en el hash
    int hash = text.hashCode;

    // Lista de colores material predefinidos para usar como base
    final List<Color> baseColors = [
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.cyan,
      Colors.deepPurple,
      Colors.teal,
      Colors.lightBlue,
      Colors.lime,
      Colors.indigo,
    ];

    // Usar el hash para seleccionar un color base
    final baseColor = baseColors[hash.abs() % baseColors.length];

    // Modificar un poco la tonalidad para hacerlo único pero consistente
    return baseColor.withOpacity(0.8);
  }
}
