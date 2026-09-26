import 'package:flutter/material.dart';

import '../models/drill.dart';
import 'category_filter_bar.dart';
import 'drill_card.dart';

/// Shared search + category-filter + list UI, embedded by both the
/// Library screen and the drill picker used from the session builder.
class DrillBrowser extends StatefulWidget {
  final List<Drill> drills;
  final ValueChanged<Drill> onTap;

  const DrillBrowser({
    super.key,
    required this.drills,
    required this.onTap,
  });

  @override
  State<DrillBrowser> createState() => _DrillBrowserState();
}

class _DrillBrowserState extends State<DrillBrowser> {
  DrillCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.drills.where((d) {
      final matchesCategory = _category == null || d.category == _category;
      final matchesQuery =
          _query.isEmpty || d.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search drills',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 8),
        CategoryFilterBar(
          selected: _category,
          onSelected: (category) => setState(() => _category = category),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No drills match.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final drill = filtered[index];
                    return DrillCard(
                      drill: drill,
                      onTap: () => widget.onTap(drill),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
