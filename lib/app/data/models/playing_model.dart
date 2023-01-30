class PlayingModel {
  PlayingModel({
    required this.url,
    required this.verse,
  });

  final String url;
  final int verse;

  @override
  String toString() => 'PlayingModel(url: $url, verse: $verse)';
}
