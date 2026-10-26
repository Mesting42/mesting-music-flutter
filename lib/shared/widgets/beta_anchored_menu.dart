import 'package:flutter/material.dart';

/// Measures the actual, scaled trigger at open time. Menu width therefore
/// stays identical in large text as well as the normal 90dp minimum layout.
class BetaAnchoredMenu<T> extends StatefulWidget {
  const BetaAnchoredMenu({
    required this.tooltip,
    required this.value,
    required this.values,
    required this.label,
    required this.onSelected,
    super.key,
  });
  final String tooltip;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  @override
  State<BetaAnchoredMenu<T>> createState() => _BetaAnchoredMenuState<T>();
}

class _BetaAnchoredMenuState<T> extends State<BetaAnchoredMenu<T>> {
  final _anchor = GlobalKey();
  Future<void> _open() async {
    final box = _anchor.currentContext!.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(
              context,
              rootNavigator: true,
            ).overlay!.context.findRenderObject()!
            as RenderBox;
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    final selected = await showMenu<T>(
      context: context,
      useRootNavigator: true,
      constraints: BoxConstraints.tightFor(width: box.size.width),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          origin.dx,
          origin.dy + box.size.height + 6,
          box.size.width,
          0,
        ),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      items: [
        for (final value in widget.values)
          PopupMenuItem<T>(
            value: value,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  widget.value == value ? Icons.check_rounded : null,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.label(value),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    if (mounted && selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: TextButton(
      key: _anchor,
      onPressed: _open,
      style: TextButton.styleFrom(
        minimumSize: const Size(90, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label(widget.value),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    ),
  );
}
