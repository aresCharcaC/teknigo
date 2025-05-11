// lib/presentation/screens/technician/components/services_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/category_view_model.dart';
import '../../../../../core/models/category_model.dart';
import 'profile_section.dart';

class ServicesSection extends StatelessWidget {
  final bool isEditing;
  final List<String> selectedCategories;
  final List<String> skills;
  final Function(List<String>) onUpdateCategories;
  final Function(List<String>) onUpdateSkills;
  final bool serviceAtHome;
  final bool serviceAtOffice;
  final Function(bool) onToggleServiceAtHome;
  final Function(bool) onToggleServiceAtOffice;

  const ServicesSection({
    Key? key,
    required this.isEditing,
    required this.selectedCategories,
    required this.skills,
    required this.onUpdateCategories,
    required this.onUpdateSkills,
    required this.serviceAtHome,
    required this.serviceAtOffice,
    required this.onToggleServiceAtHome,
    required this.onToggleServiceAtOffice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'Servicios y especialidades',
      icon: Icons.build,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipos de servicio
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Tipo de servicio:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // A domicilio
          SwitchListTile(
            title: const Text('Servicio a domicilio'),
            subtitle: const Text(
              'Ofreces servicios en la ubicación del cliente',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: serviceAtHome,
            activeColor: Theme.of(context).primaryColor,
            onChanged: isEditing ? onToggleServiceAtHome : null,
            contentPadding: EdgeInsets.zero,
          ),

          // En local
          SwitchListTile(
            title: const Text('Servicio en local/oficina'),
            subtitle: const Text(
              'Los clientes pueden acudir a tu local',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: serviceAtOffice,
            activeColor: Theme.of(context).primaryColor,
            onChanged: isEditing ? onToggleServiceAtOffice : null,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          // Categorías
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isEditing)
                  TextButton.icon(
                    onPressed: () => _showCategoriesDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
          ),

          // Lista de categorías seleccionadas
          Consumer<CategoryViewModel>(
            builder: (context, categoryViewModel, child) {
              if (selectedCategories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No has seleccionado ninguna categoría',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      selectedCategories.map((categoryId) {
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
                          avatar: Icon(
                            category.getIcon(),
                            size: 16,
                            color: category.iconColor,
                          ),
                          label: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          backgroundColor: category.iconColor.withOpacity(0.1),
                          deleteIcon:
                              isEditing
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                          onDeleted:
                              isEditing
                                  ? () => _removeCategory(categoryId)
                                  : null,
                        );
                      }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Habilidades
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Habilidades:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isEditing)
                  TextButton.icon(
                    onPressed: () => _showAddSkillDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
          ),

          // Lista de habilidades
          skills.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No has agregado ninguna habilidad',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
              : Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      skills.map((skill) {
                        return Chip(
                          label: Text(skill, overflow: TextOverflow.ellipsis),
                          backgroundColor: Colors.blue.shade50,
                          deleteIcon:
                              isEditing
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                          onDeleted:
                              isEditing ? () => _removeSkill(skill) : null,
                        );
                      }).toList(),
                ),
              ),
        ],
      ),
    );
  }

  // Eliminar una categoría
  void _removeCategory(String categoryId) {
    final updatedCategories = List<String>.from(selectedCategories);
    updatedCategories.remove(categoryId);
    onUpdateCategories(updatedCategories);
  }

  // Eliminar una habilidad
  void _removeSkill(String skill) {
    final updatedSkills = List<String>.from(skills);
    updatedSkills.remove(skill);
    onUpdateSkills(updatedSkills);
  }

  // Diálogo para agregar categorías (mostrará las mismas categorías que ve el usuario)
  void _showCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar categorías'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Consumer<CategoryViewModel>(
                builder: (context, categoryViewModel, child) {
                  if (categoryViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (categoryViewModel.categories.isEmpty) {
                    return const Center(
                      child: Text('No hay categorías disponibles'),
                    );
                  }

                  // Mostrar todas las categorías disponibles (las mismas que ve el usuario)
                  return ListView.builder(
                    itemCount: categoryViewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryViewModel.categories[index];
                      final isSelected = selectedCategories.contains(
                        category.id,
                      );

                      return CheckboxListTile(
                        title: Text(category.name),
                        subtitle: Text(
                          category.tags.isNotEmpty
                              ? category.tags.join(', ')
                              : 'Sin etiquetas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          if (value == true) {
                            final updatedCategories = List<String>.from(
                              selectedCategories,
                            );
                            updatedCategories.add(category.id);
                            onUpdateCategories(updatedCategories);
                          } else {
                            final updatedCategories = List<String>.from(
                              selectedCategories,
                            );
                            updatedCategories.remove(category.id);
                            onUpdateCategories(updatedCategories);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CERRAR'),
              ),
            ],
          ),
    );
  }

  // Diálogo para agregar habilidad
  void _showAddSkillDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar habilidad'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Habilidad o especialidad',
                hintText: 'Ej: Instalación de redes wifi',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  final skill = controller.text.trim();
                  if (skill.isNotEmpty) {
                    final updatedSkills = List<String>.from(skills);
                    updatedSkills.add(skill);
                    onUpdateSkills(updatedSkills);
                    Navigator.pop(context);
                  }
                },
                child: const Text('AGREGAR'),
              ),
            ],
          ),
    );
  }
}
