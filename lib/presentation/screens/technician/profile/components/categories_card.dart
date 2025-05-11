// lib/presentation/screens/technician/components/categories_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/category_view_model.dart';
import '../../../../../core/models/category_model.dart';

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
            Consumer<CategoryViewModel>(
              builder: (context, categoryViewModel, child) {
                if (widget.selectedCategories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No has seleccionado ninguna categoría',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.selectedCategories.map((categoryId) {
                        // Buscar la categoría en el listado completo
                        final category = categoryViewModel.categories
                            .firstWhere(
                              (cat) => cat.id == categoryId,
                              orElse:
                                  () => CategoryModel(
                                    id: categoryId,
                                    name: 'Desconocida',
                                    iconName: 'more_horiz',
                                    iconColor: Colors.grey,
                                    tags: [],
                                    isActive: true,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                            );

                        return Chip(
                          label: Text(category.name),
                          backgroundColor: category.iconColor.withOpacity(0.2),
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
                );
              },
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
              child: Consumer<CategoryViewModel>(
                builder: (context, categoryViewModel, child) {
                  // Mostrar indicador de carga si las categorías aún se están cargando
                  if (categoryViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Mostrar mensaje si no hay categorías
                  if (categoryViewModel.categories.isEmpty) {
                    return const Center(
                      child: Text('No hay categorías disponibles'),
                    );
                  }

                  // Mostrar la lista de categorías disponibles
                  return ListView.builder(
                    itemCount: categoryViewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryViewModel.categories[index];
                      final isSelected = widget.selectedCategories.contains(
                        category.id,
                      );

                      return CheckboxListTile(
                        title: Text(category.name),
                        subtitle: Text(
                          category.tags.isNotEmpty
                              ? category.tags.join(', ')
                              : 'Sin etiquetas',
                        ),
                        value: isSelected,
                        secondary: CircleAvatar(
                          backgroundColor: category.iconColor.withOpacity(0.2),
                          child: Icon(
                            category.getIcon(),
                            color: category.iconColor,
                          ),
                        ),
                        onChanged: (value) {
                          _toggleCategory(category.id);
                          // No cerramos el diálogo para permitir seleccionar múltiples categorías
                        },
                      );
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
