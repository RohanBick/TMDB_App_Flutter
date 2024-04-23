import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/models/movie_details.dart';
import 'package:flutter_application_1/services/movie_api_service.dart';
import 'package:flutter_application_1/views/movie_details_view.dart';
import 'package:flutter_application_1/services/user_favorites.dart'; // Assuming this is your class to manage user favorites

class UserFavoritesView extends StatefulWidget {
  @override
  _UserFavoritesViewState createState() => _UserFavoritesViewState();
}

class _UserFavoritesViewState extends State<UserFavoritesView> {
  final MovieAPIService _movieAPIService = MovieAPIService();
  List<Movie> _favoriteMovies = [];
  final DatabaseReference _userFavoritesRef =
      FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _fetchUserFavoriteMovies();
  }

  Future<void> _fetchUserFavoriteMovies() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userUid = currentUser.uid;
      final List<int> favoriteIds = await _fetchFavoriteMovieIds(userUid);
      final List<Movie> favoriteMovies = await _fetchMoviesByIds(favoriteIds);
      setState(() {
        _favoriteMovies = favoriteMovies;
      });
    }
  }

  Future<List<int>> _fetchFavoriteMovieIds(String userUid) async {
    final snapshot =
        await _userFavoritesRef.child('users/$userUid/favorites').once();
    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> favorites =
          Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
      return favorites.keys.map<int>((id) => int.parse(id)).toList();
    }
    return [];
  }

  Future<List<Movie>> _fetchMoviesByIds(List<int> movieIds) async {
    List<Movie> movies = [];
    for (int id in movieIds) {
      final MovieDetails movieDetails =
          await _movieAPIService.fetchMovieDetails(id);
      movies.add(Movie(
        id: movieDetails.id,
        title: movieDetails.title,
        posterPath: movieDetails.posterPath,
        isFavorite: true,
      ));
    }
    return movies;
  }

  void _toggleFavorite(Movie movie) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userUid = currentUser.uid;
      bool isNowFavorite = !movie.isFavorite;
      movie.isFavorite = isNowFavorite;

      if (isNowFavorite) {
        _userFavoritesRef
            .child('users/$userUid/favorites/${movie.id}')
            .set(true);
      } else {
        _userFavoritesRef
            .child('users/$userUid/favorites/${movie.id}')
            .remove();
        setState(() {
          _favoriteMovies.removeWhere((element) => element.id == movie.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Favorites'),
      ),
      body: _favoriteMovies.isNotEmpty
          ? WillPopScope(
              onWillPop: () async {
                Navigator.pop(context,
                    true); // Pass a result indicating refresh is needed
                return false; // Prevent default back navigation
              },
              child: ListView.builder(
                itemCount: _favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = _favoriteMovies[index];
                  return ListTile(
                    leading: FadeInImage.assetNetwork(
                      placeholder: 'assets/Roll.png',
                      image: movie.posterPath.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w185/${movie.posterPath}'
                          : 'assets/Roll.png',
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(movie.title),
                    trailing: IconButton(
                      icon: Icon(
                        movie.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => _toggleFavorite(movie),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsView(
                              movieID: movie.id, isFavorite: movie.isFavorite),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : Center(
              child: Text('No favorite movies found.'),
            ),
    );
  }
}
