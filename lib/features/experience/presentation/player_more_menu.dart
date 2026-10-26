import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

/// An anchored, bounded popover. Blur is confined to the menu rather than
/// applied to the moving player; actions retain one shared callback owner.
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
  Future<void> _open() async {
    final box = _anchor.currentContext!.findRenderObject()! as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = dark ? Colors.white : const Color(0xFF202024);
    final media = MediaQuery.of(context);
    final width = math.min(widget.menuWidth, media.size.width - 32);
    final top = math.min(
      origin.dy + box.size.height + 8,
      media.size.height * .3,
    );
    final right = (media.size.width - origin.dx - box.size.width).clamp(
      16.0,
      media.size.width - width - 16,
    );
    final groups = widget.groups;
    final value = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭更多菜单',
      barrierColor: Colors.black.withValues(alpha: .12),
      transitionDuration: media.disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, _) => Theme(
        data: theme,
        child: Stack(
          children: [
            Positioned(
              top: top,
              right: right,
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Material(
                    color: dark
                        ? const Color(0xE829292D)
                        : const Color(0xF2F7F7FA),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: math.max(
                          120,
                          media.size.height - top - media.padding.bottom - 24,
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var g = 0; g < groups.length; g++) ...[
                              if (g > 0)
                                const Divider(
                                  height: 13,
                                  thickness: .5,
                                  color: Colors.white24,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              for (final action in groups[g])
                                Semantics(
                                  selected: action.selected,
                                  button: true,
                                  child: InkWell(
                                    onTap: () => Navigator.of(
                                      dialogContext,
                                    ).pop(action.value),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 46,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 11,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              action.icon,
                                              color: ink,
                                              size: 20,
                                            ),
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
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .97, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
    );
    if (mounted && value != null) widget.onSelected(value);
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
