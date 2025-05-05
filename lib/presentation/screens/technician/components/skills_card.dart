// lib/presentation/screens/technician/components/skills_card.dart
import 'package:flutter/material.dart';

class SkillsCard extends StatefulWidget {
  final bool isEditing;
  final List<String> skills;
  final Function(List<String>) onUpdateSkills;
  final bool
  isIndividual; // Nuevo parámetro para diferenciar entre individual y negocio

  const SkillsCard({
    Key? key,
    required this.isEditing,
    required this.skills,
    required this.onUpdateSkills,
    required this.isIndividual, // Añadir este parámetro
  }) : super(key: key);

  @override
  _SkillsCardState createState() => _SkillsCardState();
}

class _SkillsCardState extends State<SkillsCard> {
  // Agregar una nueva habilidad
  void _addSkill() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              widget.isIndividual
                  ? 'Agregar habilidad especializada'
                  : 'Agregar servicio ofrecido',
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText:
                    widget.isIndividual
                        ? 'Habilidad o especialidad'
                        : 'Servicio que ofrece',
                hintText:
                    widget.isIndividual
                        ? 'Ej: Instalación de redes wifi'
                        : 'Ej: Reparación de refrigeradores',
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
                    final updatedSkills = List<String>.from(widget.skills);
                    updatedSkills.add(skill);
                    widget.onUpdateSkills(updatedSkills);
                    Navigator.pop(context);
                  }
                },
                child: const Text('AGREGAR'),
              ),
            ],
          ),
    );
  }

  // Eliminar una habilidad
  void _removeSkill(String skill) {
    final updatedSkills = List<String>.from(widget.skills);
    updatedSkills.remove(skill);
    widget.onUpdateSkills(updatedSkills);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isIndividual
            ? 'Habilidades especializadas'
            : 'Servicios ofrecidos';
    final emptyMessage =
        widget.isIndividual
            ? 'No has agregado habilidades especializadas'
            : 'No has agregado servicios ofrecidos';

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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isEditing)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: _addSkill,
                    tooltip:
                        widget.isIndividual
                            ? 'Agregar habilidad'
                            : 'Agregar servicio',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de habilidades
            widget.skills.isEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.blue.shade50,
                          deleteIcon:
                              widget.isEditing
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                          onDeleted:
                              widget.isEditing
                                  ? () => _removeSkill(skill)
                                  : null,
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }
}
