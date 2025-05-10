// lib/presentation/screens/home/components/category_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/category_model.dart';
import '../../../view_models/category_view_model.dart';

class CategorySelector extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, categoryViewModel, child) {
        if (categoryViewModel.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (categoryViewModel.categories.isEmpty) {
          return const Center(child: Text('No hay categorías disponibles'));
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              categoryViewModel.categories.map((category) {
                final isSelected = selectedCategories.contains(category.id);

                return FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    final List<String> newCategories = List.from(
                      selectedCategories,
                    );

                    if (selected) {
                      newCategories.add(category.id);
                    } else {
                      newCategories.remove(category.id);
                    }

                    onCategoriesChanged(newCategories);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: category.iconColor.withOpacity(0.2),
                  checkmarkColor: category.iconColor,
                  avatar: CircleAvatar(
                    backgroundColor:
                        isSelected ? category.iconColor : Colors.grey.shade300,
                    child: Icon(
                      category.getIcon(),
                      size: 14,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
