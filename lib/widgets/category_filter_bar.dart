import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../theme/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  final DrillCategory? selected;
  final ValueChanged<DrillCategory?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in DrillCategory.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(drillCategoryLabel(category)),
                selected: selected == category,
                selectedColor: AppColors.colorFor(category).withValues(alpha: 0.25),
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}
