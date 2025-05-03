import 'package:flutter/material.dart';

/// Widget de tarjeta para mostrar y editar las categorías del técnico
class CategoriesCard extends StatefulWidget {
  final bool isEditing;
  final List<String> selectedCategories;
  final Function(List<String>) onUpdateCategories;

  const CategoriesCard({
    Key? key,
    required this.isEditing,
    required this.selectedCategories,
    required this.onUpdateCategories,
  }) : super(key: key);

  @override
  _CategoriesCardState createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<CategoriesCard> {
  // Lista de categorías disponibles
  final List<CategoryItem> _availableCategories = [
    CategoryItem(id: '1', name: 'Electricista'),
    CategoryItem(id: '2', name: 'Técnico en Iluminación'),
    CategoryItem(id: '3', name: 'Plomero'),
    CategoryItem(id: '4', name: 'Técnico en Calefacción'),
    CategoryItem(id: '5', name: 'Técnico PC'),
    CategoryItem(id: '6', name: 'Reparador de Móviles'),
    CategoryItem(id: '7', name: 'Técnico en Redes'),
    CategoryItem(id: '8', name: 'Refrigeración'),
    CategoryItem(id: '9', name: 'Técnico en Ventilación'),
    CategoryItem(id: '10', name: 'Cerrajero'),
    CategoryItem(id: '11', name: 'Técnico en Alarmas'),
    CategoryItem(id: '12', name: 'Carpintero'),
    // Aquí puedes añadir todas las categorías necesarias
  ];

  // Alternar categoría seleccionada
  void _toggleCategory(String categoryId) {
    List<String> updatedCategories = List.from(widget.selectedCategories);

    if (updatedCategories.contains(categoryId)) {
      updatedCategories.remove(categoryId);
    } else {
      updatedCategories.add(categoryId);
    }

    widget.onUpdateCategories(updatedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis categorías',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.isEditing)
                  TextButton.icon(
                    onPressed: () {
                      // Mostrar diálogo para seleccionar categorías
                      _showCategoriesDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de categorías seleccionadas
            widget.selectedCategories.isEmpty
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No has seleccionado ninguna categoría',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.selectedCategories.map((categoryId) {
                        // Encontrar el nombre de la categoría
                        final category = _availableCategories.firstWhere(
                          (c) => c.id == categoryId,
                          orElse:
                              () => CategoryItem(
                                id: categoryId,
                                name: 'Desconocida',
                              ),
                        );

                        return Chip(
                          label: Text(category.name),
                          backgroundColor: Colors.blue.shade50,
                          deleteIcon:
                              widget.isEditing
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                          onDeleted:
                              widget.isEditing
                                  ? () => _toggleCategory(categoryId)
                                  : null,
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  // Mostrar diálogo para seleccionar categorías
  void _showCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar categorías'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400, // Altura fija para el diálogo
              child: ListView.builder(
                itemCount: _availableCategories.length,
                itemBuilder: (context, index) {
                  final category = _availableCategories[index];
                  final isSelected = widget.selectedCategories.contains(
                    category.id,
                  );

                  return CheckboxListTile(
                    title: Text(category.name),
                    value: isSelected,
                    onChanged: (value) {
                      _toggleCategory(category.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CERRAR'),
              ),
            ],
          ),
    );
  }
}

/// Modelo para categoría
class CategoryItem {
  final String id;
  final String name;

  CategoryItem({required this.id, required this.name});
}
