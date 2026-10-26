import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/beta_glass_popover.dart';
import '../../themes/beta_appearance.dart';

class PlayerMenuAction {
  const PlayerMenuAction(
    this.value,
    this.label,
    this.icon, {
    this.selected = false,
  });
  final String value, label;
  final IconData icon;
  final bool selected;
}

/// Geometry, motion and glass share one owner with the capsule and editing
/// toolbar. Business actions run only after the surface has finished closing.
class PlayerMoreMenu extends StatefulWidget {
  const PlayerMoreMenu({
    required this.groups,
    required this.onSelected,
    this.trigger,
    this.tooltip = '更多操作',
    this.menuWidth = 280,
    super.key,
  });
  final List<List<PlayerMenuAction>> groups;
  final ValueChanged<String> onSelected;
  final Widget? trigger;
  final String tooltip;
  final double menuWidth;
  @override
  State<PlayerMoreMenu> createState() => _PlayerMoreMenuState();
}

class _PlayerMoreMenuState extends State<PlayerMoreMenu> {
  final _anchor = GlobalKey();
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    final box = _anchor.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    _opening = true;
    try {
      final theme = Theme.of(context);
      final ink = theme.brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF202024);
      final value = await showBetaGlassPopover<String>(
        context: context,
        anchor: box.localToGlobal(Offset.zero) & box.size,
        width: widget.menuWidth,
        label: '关闭更多菜单',
        builder: (dialogContext) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var group = 0; group < widget.groups.length; group++) ...[
                if (group > 0)
                  Divider(
                    height: 13,
                    thickness: .5,
                    color: theme.dividerColor.withValues(alpha: .3),
                    indent: 16,
                    endIndent: 16,
                  ),
                for (final action in widget.groups[group])
                  Semantics(
                    selected: action.selected,
                    button: true,
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(dialogContext).pop(action.value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 46),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Icon(action.icon, color: ink, size: 20),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  action.label,
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (action.selected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    CupertinoIcons.check_mark,
                                    size: 18,
                                    color: BetaAppearance.accent(
                                      theme.brightness,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
      if (mounted && value != null) widget.onSelected(value);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.trigger != null
      ? Tooltip(
          message: widget.tooltip,
          child: CupertinoButton(
            key: _anchor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(44, 44),
            onPressed: _open,
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!,
              child: widget.trigger!,
            ),
          ),
        )
      : IconButton(
          key: _anchor,
          tooltip: widget.tooltip,
          onPressed: _open,
          icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white),
        );
}
