// lib/presentation/screens/technician/components/categories_card.dart
import 'package:flutter/material.dart';

class CategoriesCard extends StatefulWidget {
  final bool isEditing;
  final List<String> selectedCategories;
  final Function(List<String>, Map<String, List<String>>) onUpdateCategories;

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
    CategoryItem(id: '2', name: 'Plomero'),
    CategoryItem(id: '3', name: 'Técnico PC'),
    CategoryItem(id: '4', name: 'Refrigeración'),
    CategoryItem(id: '5', name: 'Cerrajero'),
    CategoryItem(id: '6', name: 'Carpintero'),
    CategoryItem(id: '7', name: 'Pintor'),
    CategoryItem(id: '8', name: 'Albañil'),
    CategoryItem(id: '9', name: 'Jardinero'),
    CategoryItem(id: '10', name: 'Limpieza'),
    CategoryItem(id: '11', name: 'Mecánico'),
    CategoryItem(id: '12', name: 'Electrónica'),
  ];

  // Mapa de tags por categoría
  Map<String, List<String>> _tagsMap = {};

  @override
  void initState() {
    super.initState();
    // Inicializar mapa de tags
    for (final categoryId in widget.selectedCategories) {
      if (!_tagsMap.containsKey(categoryId)) {
        _tagsMap[categoryId] = [];
      }
    }
  }

  // Alternar categoría seleccionada
  void _toggleCategory(String categoryId) {
    List<String> updatedCategories = List.from(widget.selectedCategories);

    if (updatedCategories.contains(categoryId)) {
      updatedCategories.remove(categoryId);
      _tagsMap.remove(categoryId);
    } else {
      updatedCategories.add(categoryId);
      _tagsMap[categoryId] = [];
    }

    widget.onUpdateCategories(updatedCategories, _tagsMap);
  }

  // Mostrar diálogo para seleccionar tags
  void _showTagsDialog(String categoryId, String categoryName) {
    // Tags disponibles para esta categoría
    final allTags = _getTagsForCategory(categoryId);

    // Tags seleccionados actualmente
    final selectedTags = List<String>.from(_tagsMap[categoryId] ?? []);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Seleccionar especialidades para $categoryName'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          allTags.map((tag) {
                            final isSelected = selectedTags.contains(tag);
                            return CheckboxListTile(
                              title: Text(tag),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedTags.add(tag);
                                  } else {
                                    selectedTags.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Guardar los tags seleccionados
                        Map<String, List<String>> updatedTags = Map.from(
                          _tagsMap,
                        );
                        updatedTags[categoryId] = selectedTags;

                        widget.onUpdateCategories(
                          widget.selectedCategories,
                          updatedTags,
                        );
                        _tagsMap = updatedTags;

                        Navigator.pop(context);
                      },
                      child: const Text('GUARDAR'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Obtener tags disponibles para una categoría
  List<String> _getTagsForCategory(String categoryId) {
    switch (categoryId) {
      case '1': // Electricista
        return [
          'instalación',
          'cableado',
          'corto circuito',
          'enchufes',
          'iluminación',
          'transformadores',
        ];
      case '2': // Plomero
        return [
          'agua',
          'tuberías',
          'grifos',
          'inodoros',
          'duchas',
          'fugas',
          'desagües',
        ];
      case '3': // Técnico PC
        return [
          'reparación',
          'formateo',
          'virus',
          'mantenimiento',
          'hardware',
          'software',
          'redes',
        ];
      case '4': // Refrigeración
        return [
          'aire acondicionado',
          'refrigeradores',
          'congeladores',
          'mantenimiento',
          'instalación',
        ];
      default:
        return ['general', 'reparación', 'mantenimiento', 'instalación'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
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
                      // Mostrar diálogo de todas las categorías disponibles
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Seleccionar categorías'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView(
                                  shrinkWrap: true,
                                  children:
                                      _availableCategories.map((category) {
                                        final isSelected = widget
                                            .selectedCategories
                                            .contains(category.id);
                                        return CheckboxListTile(
                                          title: Text(category.name),
                                          value: isSelected,
                                          onChanged: (value) {
                                            _toggleCategory(category.id);
                                            Navigator.pop(context);
                                          },
                                        );
                                      }).toList(),
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
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.selectedCategories.length,
                  itemBuilder: (context, index) {
                    final categoryId = widget.selectedCategories[index];
                    final category = _availableCategories.firstWhere(
                      (c) => c.id == categoryId,
                      orElse:
                          () =>
                              CategoryItem(id: categoryId, name: 'Desconocida'),
                    );

                    // Obtener los tags seleccionados para esta categoría
                    final selectedTags = _tagsMap[categoryId] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            selectedTags.isNotEmpty
                                ? Wrap(
                                  spacing: 4,
                                  children:
                                      selectedTags
                                          .map(
                                            (tag) => Chip(
                                              label: Text(
                                                tag,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Colors.blue.shade50,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          )
                                          .toList(),
                                )
                                : const Text(
                                  'Sin especialidades seleccionadas',
                                ),
                        trailing:
                            widget.isEditing
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _showTagsDialog(
                                            categoryId,
                                            category.name,
                                          ),
                                      tooltip: 'Editar especialidades',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _toggleCategory(categoryId);
                                      },
                                      tooltip: 'Eliminar categoría',
                                    ),
                                  ],
                                )
                                : null,
                        onTap:
                            widget.isEditing
                                ? () =>
                                    _showTagsDialog(categoryId, category.name)
                                : null,
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String id;
  final String name;

  CategoryItem({required this.id, required this.name});
}
