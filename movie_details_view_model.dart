import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/movie_details.dart';
import 'package:flutter_application_1/services/movie_api_service.dart';

class MovieDetailsViewModel extends ChangeNotifier {
  late MovieAPIService _apiService;
  late MovieDetails _movieDetails;
  late bool _isLoading;
  late String _errorMessage;

  MovieDetailsViewModel() {
    _apiService = MovieAPIService();
    _isLoading = false;
    _errorMessage = '';
  }

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  MovieDetails get movieDetails => _movieDetails;

  Future<void> fetchMovieDetails(int movieID) async {
    try {
      _isLoading = true;
      _movieDetails = await _apiService.fetchMovieDetails(movieID);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load movie details: $e';
      notifyListeners();
    }
  }
}
