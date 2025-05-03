import 'package:flutter/material.dart';
import '../../core/models/category_model.dart';

/// Widget que muestra una categoría en formato de tarjeta para el grid
class CategoryGridItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryGridItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener el icono basado en el nombre de la categoría
    final IconData iconData = category.getIcon();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono dentro de un círculo con el color de la categoría
              CircleAvatar(
                radius: 24,
                backgroundColor: category.iconColor.withOpacity(0.2),
                child: Icon(iconData, color: category.iconColor, size: 24),
              ),
              const SizedBox(height: 8),

              // Nombre de la categoría (con protección contra desbordamiento)
              Flexible(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Tags (mostrar solo uno y con protección contra desbordamiento)
              if (category.tags.isNotEmpty)
                Flexible(
                  child: Text(
                    category.tags.first,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
