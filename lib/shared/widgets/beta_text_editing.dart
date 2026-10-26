import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/platform/distribution_channel.dart';
import 'beta_glass_popover.dart';

Color betaEditingBlue(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF0A84FF)
    : const Color(0xFF007AFF);

/// Cupertino bar-and-ball selection handles with a single blue editing tint.
/// The framework still owns hit testing, selection geometry and the IME.
class BetaTextSelectionControls extends CupertinoTextSelectionControls
    with TextSelectionHandleControls {
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => CupertinoTheme(
    data: CupertinoTheme.of(
      context,
    ).copyWith(selectionHandleColor: betaEditingBlue(context)),
    child: Builder(
      builder: (context) =>
          super.buildHandle(context, type, textLineHeight, onTap),
    ),
  );
}

final betaTextSelectionControls = BetaTextSelectionControls();
TextSelectionControls? get mestingTextSelectionControls =>
    DistributionChannel.isBeta ? betaTextSelectionControls : null;

/// Plugged into all app fields, including the vendored glass search via its
/// public config. Stable-channel fields keep Flutter's incumbent toolbar.
Widget buildBetaEditingMenu(BuildContext context, EditableTextState editable) =>
    DistributionChannel.isBeta
    ? _BetaEditingMenu(editable: editable)
    : AdaptiveTextSelectionToolbar.editableText(editableTextState: editable);

class _BetaEditingMenu extends StatefulWidget {
  const _BetaEditingMenu({required this.editable});
  final EditableTextState editable;
  @override
  State<_BetaEditingMenu> createState() => _BetaEditingMenuState();
}

class _BetaEditingMenuState extends State<_BetaEditingMenu>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: betaMenuOpenDuration,
    reverseDuration: betaMenuCloseDuration,
  )..forward();
  bool _expanded = false, _closing = false;
  EditableTextState get e => widget.editable;

  Rect _fieldAnchor() {
    final anchors = e.contextMenuAnchors;
    final selection = Rect.fromPoints(
      anchors.primaryAnchor,
      anchors.secondaryAnchor ?? anchors.primaryAnchor,
    );
    Rect? field;
    e.context.visitAncestorElements((element) {
      if (element.widget is! TextField &&
          element.widget is! CupertinoTextField) {
        return true;
      }
      final box = element.findRenderObject();
      if (box is RenderBox && box.hasSize && box.attached) {
        field = Rect.fromPoints(
          box.localToGlobal(Offset.zero),
          box.localToGlobal(box.size.bottomRight(Offset.zero)),
        );
      }
      return false;
    });
    final bounds = field;
    if (bounds == null) return selection;
    // EditableText anchors sit on the selected text, inside the input padding.
    // Keep their horizontal origin, but measure the vertical gap from the whole
    // field so an expanded toolbar never rests on top of the comment capsule.
    return Rect.fromLTRB(
      selection.left,
      math.min(selection.top, bounds.top),
      selection.right,
      math.max(selection.bottom, bounds.bottom),
    );
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _close([VoidCallback? action]) async {
    if (_closing) return;
    _closing = true;
    if (!MediaQuery.disableAnimationsOf(context)) await _motion.reverse();
    if (!mounted || !e.mounted) return;
    e.hideToolbar();
    action?.call();
  }

  void _insert(String text) {
    // userUpdateTextEditingValue applies the original inputFormatters,
    // maxLength and onChanged. Never mutate controller.text behind the IME.
    final value = e.textEditingValue;
    final range = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final replacement = value.replaced(range, text);
    _close(
      () => e.userUpdateTextEditingValue(
        replacement,
        SelectionChangedCause.toolbar,
      ),
    );
  }

  List<({String label, IconData icon, VoidCallback? action})> _actions() {
    final field = e.widget;
    final value = e.textEditingValue;
    final numeric =
        field.keyboardType == TextInputType.phone ||
        field.keyboardType == TextInputType.number ||
        field.keyboardType == TextInputType.numberWithOptions();
    final paste = e.contextMenuButtonItems
        .where((b) => b.type == ContextMenuButtonType.paste)
        .firstOrNull;
    final all = e.contextMenuButtonItems
        .where((b) => b.type == ContextMenuButtonType.selectAll)
        .firstOrNull;
    return [
      (
        label: '粘贴',
        icon: CupertinoIcons.doc_on_clipboard,
        action: paste?.onPressed,
      ),
      if (value.text.isNotEmpty && !field.obscureText)
        (
          label: '选择',
          icon: CupertinoIcons.selection_pin_in_out,
          action: () {
            final offset = value.selection.isValid
                ? value.selection.extentOffset
                : 0;
            final boundary = e.renderEditable.getWordBoundary(
              TextPosition(offset: offset),
            );
            e.userUpdateTextEditingValue(
              value.copyWith(
                selection: TextSelection(
                  baseOffset: boundary.start,
                  extentOffset: boundary.end,
                ),
              ),
              SelectionChangedCause.toolbar,
            );
            e.showToolbar();
          },
        ),
      if (all != null && !field.obscureText)
        (label: '全选', icon: CupertinoIcons.textformat, action: all.onPressed),
      if (!field.readOnly && (field.autofillHints?.isNotEmpty ?? false))
        (
          label: '自动填充',
          icon: CupertinoIcons.keyboard,
          action: () {
            e.requestKeyboard();
            SystemChannels.textInput.invokeMethod<void>(
              'TextInput.requestAutofill',
            );
          },
        ),
      if (!field.readOnly && !field.obscureText && !numeric && _expanded) ...[
        if (field.maxLines != 1)
          (
            label: '换行',
            icon: CupertinoIcons.return_icon,
            action: () => _insert('\n'),
          ),
        (label: '#', icon: CupertinoIcons.number, action: () => _insert('#')),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final anchor = _fieldAnchor();
    final media = MediaQuery.of(context);
    final layout = BetaMenuLayout(
      anchor: anchor,
      media: media,
      width: _expanded ? 270 : math.min(430, media.size.width - 24),
    );
    final actions = _actions();
    Widget button(
      String label,
      IconData icon,
      VoidCallback? action, {
      bool row = false,
    }) => CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: row ? 18 : 12, vertical: 11),
      minimumSize: const Size(48, 48),
      onPressed: action == null
          ? null
          : () {
              // Insertions need their own formatted edit after the closing motion.
              if (label == '#' || label == '换行') {
                action();
              } else {
                _close(action);
              }
            },
      child: row
          ? Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 14),
                Expanded(child: Text(label)),
              ],
            )
          : Text(label, maxLines: 1),
    );
    return CustomSingleChildLayout(
      delegate: layout,
      child: TapRegion(
        onTapOutside: (_) => _close(),
        child: BetaGlassMenuTransition(
          animation: _motion,
          origin: layout.motionOrigin,
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Theme.of(context).brightness,
              primaryColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: AnimatedSize(
              duration: media.disableAnimations
                  ? Duration.zero
                  : betaMenuOpenDuration,
              alignment: Alignment.bottomRight,
              curve: Curves.easeOutCubic,
              child: SingleChildScrollView(
                scrollDirection: _expanded ? Axis.vertical : Axis.horizontal,
                child: _expanded
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              onPressed: () =>
                                  setState(() => _expanded = false),
                              child: const Icon(
                                CupertinoIcons.chevron_down,
                                semanticLabel: '收回编辑菜单',
                                size: 19,
                              ),
                            ),
                          ),
                          for (final item in actions)
                            button(
                              item.label,
                              item.icon,
                              item.action,
                              row: true,
                            ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final item in actions)
                            button(item.label, item.icon, item.action),
                          CupertinoButton(
                            padding: const EdgeInsets.all(12),
                            onPressed: () => setState(() => _expanded = true),
                            child: const Icon(
                              CupertinoIcons.chevron_right,
                              semanticLabel: '更多编辑操作',
                              size: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
