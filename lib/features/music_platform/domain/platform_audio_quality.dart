/// Request codes are the pinned upstream's real `/song/url` contract.
enum PlatformAudioQuality {
  standard('128', '标准'),
  high('320', '高品质'),
  lossless('flac', '无损'),
  hiRes('high', 'Hi-Res');

  const PlatformAudioQuality(this.code, this.label);
  final String code;
  final String label;

  static PlatformAudioQuality? fromCode(Object? code) {
    for (final value in values) {
      if (value.code == '$code') return value;
    }
    return null;
  }

  /// Follow the upstream downgrade chain; never label the request as the
  /// delivered quality. Unknown responses stay unknown in the player badge.
  List<PlatformAudioQuality> get fallbackChain =>
      values.take(index + 1).toList().reversed.toList();
}
