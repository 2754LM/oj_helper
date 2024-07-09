class Rating {
  final String name;
  final int curRating;
  final int maxRating;
  int time;
  int ranking;
  Rating({
    this.name = '',
    required this.curRating,
    this.maxRating = -1,
    this.time = 0,
    this.ranking = 0,
  });
}
