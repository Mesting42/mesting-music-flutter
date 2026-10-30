/// Upgrade known public artwork CDNs without changing local assets or private
/// hosts. Android blocks cleartext CDN URLs returned by older playlist DTOs.
String normalizeArtworkUri(String value) {
  var text = value.trim();
  if (text.startsWith('//')) text = 'https:$text';
  final uri = Uri.tryParse(text);
  if (uri?.scheme == 'http' &&
      (uri!.host.endsWith('.music.126.net') ||
          uri.host.endsWith('.music.163.com') ||
          uri.host.endsWith('.kugou.com') ||
          uri.host == 'imge.kugou.com')) {
    return uri.replace(scheme: 'https').toString();
  }
  return text;
}

/// An empty primary DTO field must not hide a valid fallback image URL.
String firstArtworkUri(Iterable<Object?> values) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) {
      final normalized = normalizeArtworkUri(value);
      final uri = Uri.tryParse(normalized);
      // A filename/id in a primary DTO field must not mask the later CDN URL.
      if (uri != null &&
          {'http', 'https'}.contains(uri.scheme) &&
          uri.host.isNotEmpty) {
        return normalized;
      }
    }
  }
  return '';
}

/// The public NetEase artwork CDN rejects Dart's default HTTP User-Agent with
/// 403 on some image hosts. Identify this client consistently for disk-cache
/// and direct image requests (which must replace, not append, this header);
/// never attach account credentials to artwork.
/// Other hosts retain their own HTTP/signature behavior.
Map<String, String>? artworkRequestHeaders(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.host.endsWith('.music.126.net')) return null;
  return const {'User-Agent': 'MestingMusic/1.0 (Artwork)'};
}

/// NetEase returns original photos (sometimes >10 MB) even for a 64px row.
/// Request the CDN thumbnail before disk validation/decode, rather than merely
/// decoding a full download at a smaller size. Other CDNs/signatures are intact.
String sizedArtworkUri(String value, {int width = 768, int height = 768}) {
  final normalized = normalizeArtworkUri(value);
  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.host.endsWith('.music.126.net')) return normalized;
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'param': '${width.clamp(32, 1024)}y${height.clamp(32, 1024)}',
        },
      )
      .toString();
}
