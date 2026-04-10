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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;

    Widget buildChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color.withOpacity(0.4), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: widget.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    Widget buildToggle(String label, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: textColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    if (_expanded) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...widget.items.map(
            (name) => buildChip(name.toString()),
          ),
          buildToggle('Less ↑', () => setState(() => _expanded = false)),
        ],
      );
    }

    // Collapsed: show up to 3 chips + "N more" toggle if needed
    const int maxVisible = 3;
    final visible = widget.items.take(maxVisible).toList();
    final hiddenCount = widget.items.length - maxVisible;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...visible.map((name) => buildChip(name.toString())),
        if (hiddenCount > 0)
          buildToggle(
            '+$hiddenCount more',
            () => setState(() => _expanded = true),
          ),
      ],
    );
  }
}