import 'package:flutter/material.dart';

class ExpandableTextComponent extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableTextComponent({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<ExpandableTextComponent> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableTextComponent> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final span = TextSpan(text: widget.text, style: widget.style);
          final tp = TextPainter(
            text: span,
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          //final isOverflowing = tp.didExceedMaxLines;

          return AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: _expanded ? null : 1,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
