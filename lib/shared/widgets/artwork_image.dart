import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

const _legacyArtworkAssetAliases = <String, String>{
  'assets/branding/dress-midnight-launch.png':
      'assets/branding/dress-midnight-launch-v2.webp',
  'assets/branding/dress-midnight-launch-v2.png':
      'assets/branding/dress-midnight-launch-v2.webp',
  'assets/branding/dress-morning-launch.png':
      'assets/branding/dress-morning-launch.webp',
  'assets/images/themes/shinchan_progress.png':
      'assets/images/theme_gallery/shinchan-avatar-v2.png',
  'assets/images/themes/shinchan_sunny.png':
      'assets/images/theme_gallery/motion-walk-shinchan-scene.webp',
  'assets/images/theme_gallery/shinchan-progress-head.png':
      'assets/images/theme_gallery/shinchan-avatar-v2.png',
};

String canonicalArtworkUri(String value) =>
    _legacyArtworkAssetAliases[value] ?? value;

class ArtworkImage extends StatefulWidget {
  const ArtworkImage({
    required this.uri,
    this.width,
    this.height,
    this.decodeWidth,
    this.decodeHeight,
    this.fit = BoxFit.cover,
    this.retryOnNetworkError = false,
    super.key,
  });

  final String uri;
  final double? width;
  final double? height;
  final double? decodeWidth;
  final double? decodeHeight;
  final BoxFit fit;
  final bool retryOnNetworkError;

  @override
  State<ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<ArtworkImage> {
  static const _maxNetworkRetries = 3;

  Timer? _retryTimer;
  int _networkRetry = 0;

  @override
  void didUpdateWidget(covariant ArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri == widget.uri &&
        oldWidget.retryOnNetworkError == widget.retryOnNetworkError) {
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = null;
    _networkRetry = 0;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uri = canonicalArtworkUri(widget.uri);
    final hasExplicitDecodeSize =
        widget.decodeWidth != null || widget.decodeHeight != null;
    final cacheWidth = artworkCacheDimension(
      context,
      widget.decodeWidth ?? (hasExplicitDecodeSize ? null : widget.width),
    );
    final cacheHeight = artworkCacheDimension(
      context,
      widget.decodeHeight ?? (hasExplicitDecodeSize ? null : widget.height),
    );
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return _ArtworkPlaceholder(width: widget.width, height: widget.height);
    }

    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      final provider = ResizeImage.resizeIfNeeded(
        cacheWidth,
        cacheHeight,
        NetworkImage(uri),
      );
      return Image(
        // Keep the same image element when a signed URL is refreshed. This lets
        // gaplessPlayback retain the last decoded avatar instead of flashing
        // the placeholder between two equivalent CloudBase URLs.
        key: ValueKey('network-artwork-retry-$_networkRetry'),
        image: provider,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          _scheduleNetworkRetry(provider);
          return errorBuilder(context, error, stackTrace);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            _retryTimer?.cancel();
            _retryTimer = null;
          }
          return child;
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null || widget.retryOnNetworkError) return child;
          return _ArtworkPlaceholder(
            width: widget.width,
            height: widget.height,
          );
        },
      );
    }
    if (uri.isEmpty) {
      return _ArtworkPlaceholder(width: widget.width, height: widget.height);
    }
    final localFile = _localFile(uri);
    if (localFile != null) {
      return Image.file(
        localFile,
        width: widget.width,
        height: widget.height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        fit: widget.fit,
        errorBuilder: errorBuilder,
      );
    }
    return Image.asset(
      uri,
      width: widget.width,
      height: widget.height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      fit: widget.fit,
      errorBuilder: errorBuilder,
    );
  }

  void _scheduleNetworkRetry(ImageProvider<Object> provider) {
    if (!widget.retryOnNetworkError ||
        _networkRetry >= _maxNetworkRetries ||
        _retryTimer != null) {
      return;
    }
    final nextRetry = _networkRetry + 1;
    _retryTimer = Timer(Duration(milliseconds: 650 * nextRetry), () async {
      _retryTimer = null;
      await provider.evict();
      if (!mounted) return;
      setState(() => _networkRetry = nextRetry);
    });
  }

  File? _localFile(String value) {
    File? file;
    if (value.startsWith('file://')) {
      file = File.fromUri(Uri.parse(value));
    } else if (value.startsWith('/') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value)) {
      file = File(value);
    }
    return file != null && file.existsSync() ? file : null;
  }
}

int? artworkCacheDimension(BuildContext context, double? logicalPixels) {
  if (logicalPixels == null || !logicalPixels.isFinite || logicalPixels <= 0) {
    return null;
  }
  final physicalPixels =
      (logicalPixels * MediaQuery.devicePixelRatioOf(context)).ceil();
  return physicalPixels.clamp(1, 2048);
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE9EDFF),
      alignment: Alignment.center,
      child: const Icon(Icons.album_rounded, color: Color(0xFF4B63D0)),
    );
  }
}
