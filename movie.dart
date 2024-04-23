class Movie {
  final int id;
  final String title;
  final String posterPath;
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.isFavorite = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
    );
  }
  Movie copyWith({bool? isFavorite}) {
    return Movie(
      id: this.id,
      title: this.title,
      posterPath: this.posterPath,
      isFavorite: isFavorite ??
          this.isFavorite, // Update the isFavorite field if it's passed, otherwise keep the original
    );
  }
}
