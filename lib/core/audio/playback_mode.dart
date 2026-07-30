enum PlaybackMode {
  list,
  single,
  random;

  String get label => switch (this) {
    PlaybackMode.list => '列表循环',
    PlaybackMode.single => '单曲循环',
    PlaybackMode.random => '随机播放',
  };

  PlaybackMode get next =>
      PlaybackMode.values[(index + 1) % PlaybackMode.values.length];
}
