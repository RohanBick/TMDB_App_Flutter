import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/services/movie_api_service.dart';

class MovieListViewModel extends ChangeNotifier {
  late MovieAPIService _apiService;
  late List<Movie> _movies;
  late bool _isLoading;
  late String _errorMessage;

  MovieListViewModel() {
    _apiService = MovieAPIService();
    _movies = [];
    _isLoading = false;
    _errorMessage = '';
  }

  List<Movie> get movies => _movies;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  Future<void> fetchMovies() async {
    try {
      _isLoading = true;
      _movies = await _apiService.fetchMovies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load movies: $e';
      notifyListeners();
    }
  }
}
