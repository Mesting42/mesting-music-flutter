import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../themes/music_theme_tokens.dart';

class PlaylistDraft {
  const PlaylistDraft({
    required this.name,
    required this.description,
    required this.coverAsset,
  });

  final String name;
  final String description;
  final String? coverAsset;
}

Future<PlaylistDraft?> showPlaylistEditorDialog(
  BuildContext context, {
  String? initialName,
  String initialDescription = '',
  String? initialCoverAsset,
}) {
  return showLiquidGlassBottomSheet<PlaylistDraft>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: .56),
    builder: (sheetContext) => _PlaylistEditorSheet(
      initialName: initialName,
      initialDescription: initialDescription,
      initialCoverAsset: initialCoverAsset,
    ),
  );
}

class _PlaylistEditorSheet extends StatefulWidget {
  const _PlaylistEditorSheet({
    required this.initialName,
    required this.initialDescription,
    required this.initialCoverAsset,
  });

  final String? initialName;
  final String initialDescription;
  final String? initialCoverAsset;

  @override
  State<_PlaylistEditorSheet> createState() => _PlaylistEditorSheetState();
}

class _PlaylistEditorSheetState extends State<_PlaylistEditorSheet> {
  static const _maximumCoverBytes = 10 * 1024 * 1024;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCover;
  String? _pendingPickedCover;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _nameController.addListener(_refreshCounters);
    _descriptionController.addListener(_refreshCounters);
    _selectedCover = widget.initialCoverAsset;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_refreshCounters)
      ..dispose();
    _descriptionController
      ..removeListener(_refreshCounters)
      ..dispose();
    super.dispose();
  }

  void _refreshCounters() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final editing = widget.initialName != null;
    final panelColor = Color.alphaBlend(tokens.glassStrong, scheme.surface);

    return AnimatedPadding(
      key: const ValueKey('playlist-editor-sheet'),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * .91),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: Material(
            color: panelColor,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: dark
                        ? Colors.white.withValues(alpha: .16)
                        : scheme.primary.withValues(alpha: .13),
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: dark ? .13 : .075),
                    panelColor.withValues(alpha: .98),
                    panelColor,
                  ],
                  stops: const [0, .42, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  _SheetHandle(color: tokens.textMuted),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EditorHeader(
                              editing: editing,
                              onClose: _saving
                                  ? null
                                  : () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 18),
                            _CoverStudio(
                              cover: _selectedCover,
                              saving: _saving,
                              onPick: _pickCover,
                              onAutomatic: _selectedCover == null
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedCover = null;
                                        _pendingPickedCover = null;
                                        _error = null;
                                      });
                                    },
                            ),
                            const SizedBox(height: 18),
                            _StudioTextField(
                              key: const ValueKey('playlist-editor-name-field'),
                              controller: _nameController,
                              label: '歌单名称',
                              hint: '给这一段旋律取个名字',
                              icon: Icons.graphic_eq_rounded,
                              maximumLength: 30,
                              enabled: !_saving,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            _StudioTextField(
                              key: const ValueKey(
                                'playlist-editor-description-field',
                              ),
                              controller: _descriptionController,
                              label: '歌单描述',
                              hint: '写下这张歌单的情绪、场景或故事',
                              icon: Icons.notes_rounded,
                              maximumLength: 100,
                              enabled: !_saving,
                              maximumLines: 3,
                              minimumLines: 2,
                              textInputAction: TextInputAction.newline,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              _EditorNotice(message: _error!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  _EditorFooter(
                    editing: editing,
                    saving: _saving,
                    canSave: _nameController.text.trim().isNotEmpty,
                    onCancel: () => Navigator.pop(context),
                    onSave: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCover() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (picked == null) return;
      if (await picked.length() > _maximumCoverBytes) {
        if (mounted) setState(() => _error = '封面图片不能超过 10 MB');
        return;
      }
      if (!mounted) return;
      setState(() {
        _selectedCover = picked.path;
        _pendingPickedCover = picked.path;
        _error = null;
      });
    } on Object {
      if (mounted) setState(() => _error = '图片读取失败，请换一张图片重试');
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '先为歌单取一个名字');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var cover = _selectedCover;
      final pendingCover = _pendingPickedCover;
      if (pendingCover != null) cover = await _persistCover(pendingCover);
      if (!mounted) return;
      Navigator.pop(
        context,
        PlaylistDraft(
          name: name,
          description: _descriptionController.text.trim(),
          coverAsset: cover,
        ),
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '封面保存失败，请检查存储空间后重试';
      });
    }
  }

  Future<String> _persistCover(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) throw const FileSystemException('图片不存在');
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${documents.path}${Platform.pathSeparator}playlist_covers',
    );
    await directory.create(recursive: true);
    final extension = _safeImageExtension(sourcePath);
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      'playlist_cover_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return (await source.copy(target.path)).path;
  }

  String _safeImageExtension(String path) {
    final fileName = path.replaceAll('\\', '/').split('/').last;
    final dot = fileName.lastIndexOf('.');
    if (dot > 0) {
      final extension = fileName.substring(dot).toLowerCase();
      if (const {'.jpg', '.jpeg', '.png', '.webp'}.contains(extension)) {
        return extension;
      }
    }
    return '.jpg';
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .34),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.editing, required this.onClose});

  final bool editing;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withValues(alpha: .18)),
          ),
          child: Icon(
            Icons.library_music_rounded,
            color: scheme.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAYLIST STUDIO',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                editing ? '编辑歌单' : '创建歌单',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
            ],
          ),
        ),
        _RoundAction(
          semanticLabel: '关闭',
          icon: Icons.close_rounded,
          onTap: onClose,
        ),
      ],
    );
  }
}

class _CoverStudio extends StatelessWidget {
  const _CoverStudio({
    required this.cover,
    required this.saving,
    required this.onPick,
    required this.onAutomatic,
  });

  final String? cover;
  final bool saving;
  final VoidCallback onPick;
  final VoidCallback? onAutomatic;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: const ValueKey('playlist-editor-cover-stage'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.glassSubtle,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: dark
              ? tokens.borderStrong
              : scheme.primary.withValues(alpha: .13),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: .72),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: '歌单封面，点击从相册选择图片',
            child: GestureDetector(
              onTap: saving ? null : onPick,
              child: _CoverPreview(cover: cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  cover == null ? '让歌曲决定封面' : '封面已就位',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cover == null
                      ? '未选择图片时，会自动取歌单内的第一张唱片封面。'
                      : '支持 JPG、PNG、WebP，图片仅保存在本机应用目录。',
                  style: TextStyle(
                    color: tokens.textMuted,
                    height: 1.45,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _CoverAction(
                      label: '从相册选择',
                      icon: Icons.add_photo_alternate_rounded,
                      emphasized: true,
                      onTap: saving ? null : onPick,
                    ),
                    _CoverAction(
                      label: '自动封面',
                      icon: Icons.auto_awesome_rounded,
                      onTap: saving ? null : onAutomatic,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.cover});

  final String? cover;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.musicThemeTokens;
    return Container(
      width: 108,
      height: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: tokens.borderStrong),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 19,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cover == null)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: .2),
                    scheme.primaryContainer.withValues(alpha: .72),
                  ],
                ),
              ),
              child: Icon(Icons.album_rounded, size: 43, color: scheme.primary),
            )
          else
            ArtworkImage(uri: cover!),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xD91A1720),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: .22)),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverAction extends StatelessWidget {
  const _CoverAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.musicThemeTokens;
    final active = onTap != null;
    final foreground = emphasized ? scheme.primary : tokens.textSecondary;
    return Semantics(
      button: true,
      enabled: active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: emphasized
                ? scheme.primary.withValues(alpha: active ? .12 : .055)
                : tokens.glass.withValues(alpha: active ? .72 : .34),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: emphasized
                  ? scheme.primary.withValues(alpha: active ? .2 : .08)
                  : tokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: foreground.withValues(alpha: active ? 1 : .4),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: foreground.withValues(alpha: active ? 1 : .4),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioTextField extends StatefulWidget {
  const _StudioTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.maximumLength,
    required this.enabled,
    required this.textInputAction,
    this.maximumLines = 1,
    this.minimumLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maximumLength;
  final bool enabled;
  final int maximumLines;
  final int minimumLines;
  final TextInputAction textInputAction;

  @override
  State<_StudioTextField> createState() => _StudioTextFieldState();
}

class _StudioTextFieldState extends State<_StudioTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    final focused = _focusNode.hasFocus;
    final multiline = widget.maximumLines > 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        color: focused
            ? scheme.primary.withValues(alpha: .075)
            : tokens.glassSubtle,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: focused
              ? scheme.primary.withValues(alpha: .72)
              : tokens.borderStrong,
          width: focused ? 1.35 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .1),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ]
            : const [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: focused
                  ? scheme.primary.withValues(alpha: .16)
                  : tokens.glass,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: focused ? scheme.primary : tokens.textMuted,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: focused
                              ? scheme.primary
                              : tokens.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.controller.text.characters.length}'
                      '/${widget.maximumLength}',
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 9.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLength: widget.maximumLength,
                  maxLines: widget.maximumLines,
                  minLines: widget.minimumLines,
                  textInputAction: widget.textInputAction,
                  textAlignVertical: multiline
                      ? TextAlignVertical.top
                      : TextAlignVertical.center,
                  cursorHeight: 19,
                  cursorRadius: const Radius.circular(2),
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintMaxLines: multiline ? widget.minimumLines : 1,
                    hintStyle: TextStyle(
                      color: tokens.textMuted.withValues(alpha: .72),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.only(
                      top: multiline ? 6 : 4,
                      bottom: multiline ? 4 : 4,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorNotice extends StatelessWidget {
  const _EditorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.error.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: scheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorFooter extends StatelessWidget {
  const _EditorFooter({
    required this.editing,
    required this.saving,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  final bool editing;
  final bool saving;
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    final enabled = canSave && !saving;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(tokens.glassStrong, scheme.surface),
        border: Border(top: BorderSide(color: tokens.border)),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 22,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              children: [
                Expanded(
                  child: _FooterAction(
                    label: '取消',
                    icon: Icons.close_rounded,
                    onTap: saving ? null : onCancel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _FooterAction(
                    key: const ValueKey('playlist-editor-save'),
                    label: editing ? '保存修改' : '完成创建',
                    icon: Icons.arrow_forward_rounded,
                    emphasized: true,
                    loading: saving,
                    onTap: enabled ? onSave : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
    this.loading = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final scheme = Theme.of(context).colorScheme;
    final active = onTap != null;
    final foreground = emphasized ? scheme.onPrimary : tokens.textSecondary;
    return Semantics(
      button: true,
      enabled: active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: emphasized
                ? scheme.primary.withValues(alpha: active ? 1 : .34)
                : tokens.glassSubtle,
            borderRadius: BorderRadius.circular(18),
            border: emphasized ? null : Border.all(color: tokens.borderStrong),
            boxShadow: emphasized && active
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: .22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: loading
                ? SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: scheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: foreground.withValues(alpha: active ? 1 : .48),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Icon(
                        icon,
                        size: 18,
                        color: foreground.withValues(alpha: active ? 1 : .48),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tokens.glassSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.border),
          ),
          child: Icon(icon, color: tokens.textPrimary, size: 21),
        ),
      ),
    );
  }
}
