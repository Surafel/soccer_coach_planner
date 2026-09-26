import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../theme/app_colors.dart';

class DrillCard extends StatelessWidget {
  final Drill drill;
  final VoidCallback onTap;

  const DrillCard({super.key, required this.drill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.colorFor(drill.category);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: categoryColor.withValues(alpha: 0.15),
          child: Icon(Icons.sports_soccer, color: categoryColor),
        ),
        title: Text(drill.name),
        subtitle: Text('${drillCategoryLabel(drill.category)} · Ages ${drill.ageRange}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
