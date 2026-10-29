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
