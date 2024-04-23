import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserFavorites {
  final DatabaseReference _favoriteRef = FirebaseDatabase.instance.reference();

  Future<List<int>> getUserFavoriteMovieIds() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userUid = currentUser.uid;
      final favoriteRef =
          _favoriteRef.child('users').child(userUid).child('favorites');

      try {
        final snapshot = await favoriteRef.once();
        final dataSnapshot = snapshot.snapshot;
        if (dataSnapshot.value != null) {
          final Map<dynamic, dynamic>? favorites =
              dataSnapshot.value as Map<dynamic, dynamic>?;

          if (favorites != null) {
            final List<int> favoriteMovieIds = [];
            favorites.forEach((key, value) {
              if (value == true) {
                favoriteMovieIds.add(int.parse(key.toString()));
              }
            });
            return favoriteMovieIds;
          }
        }
      } catch (e) {
        print('Error fetching user favorites: $e');
        throw e; // Rethrow the error for handling in the calling function
      }
    }
    return []; // Return an empty list if no user is logged in or no favorites are found
  }
}
