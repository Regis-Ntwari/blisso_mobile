import 'package:flutter/material.dart';

class ExpandablePillsComponent extends StatefulWidget {
  final List<dynamic> items;
  final Color color;

  const ExpandablePillsComponent({
    super.key,
    required this.items,
    required this.color,
  });

  @override
  State<ExpandablePillsComponent> createState() => _ExpandablePillsState();
}

class _ExpandablePillsState extends State<ExpandablePillsComponent> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final chips = widget.items.map((name) {
        return Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        );
      }).toList();

      // EXPANDED VIEW → show all chips + View less
      if (expanded) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...chips,
            GestureDetector(
              onTap: () => setState(() => expanded = false),
              child: const Padding(
                padding: EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  "View less",
                  style: TextStyle(
                    fontSize: 12,
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        );
      }

      // COLLAPSED → SINGLE LINE
      // COLLAPSED → SINGLE LINE
      List<Widget> rowChildren = [];
      double usedWidth = 0;
      const double reservedForViewMore = 80;

      for (var chip in chips) {
        final width = _estimateChipWidth(chip);

        if (usedWidth + width + reservedForViewMore > constraints.maxWidth) {
          break;
        }

        rowChildren.add(chip);
        usedWidth += width;
      }

// Determine if more items exist after the ones shown
      bool hasHiddenItems = chips.length > rowChildren.length;

// Add View More only when needed
      if (hasHiddenItems) {
        rowChildren.add(
          GestureDetector(
            onTap: () => setState(() => expanded = true),
            child: const Text(
              "View more",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }

      return Row(children: rowChildren);
    });
  }

  // A simple estimation that is accurate enough for pills
  double _estimateChipWidth(Widget chip) => 90;
}
