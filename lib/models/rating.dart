class Rating {
  final String name;
  final int curRating;
  final int maxRating;

  Rating({
    this.name = '',
    required this.curRating,
    this.maxRating = -1,
  });
}
