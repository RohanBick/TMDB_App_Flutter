import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/movie_details.dart';
import 'package:flutter_application_1/services/movie_api_service.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoColors;
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailsView extends StatelessWidget {
  final int movieID;
  final bool isFavorite;

  const MovieDetailsView(
      {Key? key, required this.movieID, required this.isFavorite})
      : super(key: key);

  Map<String, Color> _popularityLabelAndColor(double popularity) {
    if (popularity > 100) {
      return {"High": Colors.green};
    } else if (popularity > 50) {
      return {"Medium": Colors.orange};
    } else {
      return {"Low": Colors.red};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Details'),
      ),
      body: FutureBuilder<MovieDetails>(
        future: MovieAPIService().fetchMovieDetails(movieID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MovieDetails movieDetails = snapshot.data!;
            Map<String, Color> popularityInfo =
                _popularityLabelAndColor(movieDetails.popularity);
            String popularityLabel = popularityInfo.keys.first;
            Color popularityColor = popularityInfo[popularityLabel]!;
            List<String> imagePaths = [
              movieDetails.posterPath,
              movieDetails.backdropPath,
              movieDetails.posterPath,
              movieDetails.backdropPath,
            ];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        String imagePath = imagePaths[index];
                        String imageUrl =
                            'https://image.tmdb.org/t/p/w500/$imagePath';
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                Image.asset('assets/Roll.png'),
                            imageUrl: imagePath.isNotEmpty
                                ? imageUrl
                                : 'assets/Roll.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 200,
                            fadeInDuration: Duration(milliseconds: 250),
                            fadeOutDuration: Duration(milliseconds: 150),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      movieDetails.title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: StarRatingView(rating: movieDetails.voteAverage / 2),
                  ),
                  Wrap(
                    children: movieDetails.genres
                        .map((genre) => Container(
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(genre,
                                  style: TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Overview:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(movieDetails.overview),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('Runtime: ${movieDetails.runtime} minutes',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('Release Date: ${movieDetails.releaseDate}',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: popularityColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('Popularity: $popularityLabel',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : null, // Set color to red when favorite
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: _loadingIndicator(context));
        },
      ),
    );
  }

  Widget _loadingIndicator(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }
}

class StarRatingView extends StatelessWidget {
  final double rating;

  const StarRatingView({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int numFullStars = rating.floor();
    bool hasHalfStar = rating - numFullStars >= 0.5;
    int numEmptyStars = 5 - numFullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
            numFullStars, (_) => Icon(Icons.star, color: Colors.amber)),
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber),
        ...List.generate(
            numEmptyStars, (_) => Icon(Icons.star_border, color: Colors.amber)),
      ],
    );
  }
}
