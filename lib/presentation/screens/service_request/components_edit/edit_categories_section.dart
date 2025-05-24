import 'package:flutter/material.dart';
import '../../home/components/category_selector.dart';
import 'edit_form_data.dart';

class EditCategoriesSection extends StatelessWidget {
  final EditFormData formData;
  final Function(VoidCallback) onUpdate;

  const EditCategoriesSection({
    Key? key,
    required this.formData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CategorySelector(
          selectedCategories: formData.selectedCategories,
          onCategoriesChanged: (categories) {
            onUpdate(() {
              formData.updateCategories(categories);
            });
          },
        ),
      ],
    );
  }
}
