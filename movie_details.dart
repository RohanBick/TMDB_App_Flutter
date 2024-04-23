class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String posterPath;
  final String backdropPath;
  final List<String> genres;
  final int runtime;
  final String releaseDate;
  final double popularity;

  MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.posterPath,
    required this.backdropPath,
    required this.genres,
    required this.runtime,
    required this.releaseDate,
    required this.popularity,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    var genreList =
        List<String>.from(json['genres'].map((genre) => genre['name']));
    return MovieDetails(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      voteAverage: json['vote_average']?.toDouble() ?? 0.0,
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      genres: genreList,
      runtime: json['runtime'],
      releaseDate: json['release_date'],
      popularity: json['popularity']?.toDouble() ?? 0.0,
    );
  }
}
