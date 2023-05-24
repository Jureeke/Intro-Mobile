import 'package:cloud_firestore/cloud_firestore.dart';

class RatingFunctions{
    static int rating = 0;
    static int ratingShow = 0;

    static void loadRating(String userId) async {
      try {
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          int loadedRating = userSnapshot.get('currentRating') ?? 0;
          rating = loadedRating.floor();
        }
      } catch (e) {
        print('Error loading userRating: $e');
      }
    }

  static void uploadRating(String ratingToAdd, String userId) async {
      try {
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          int timesRated = userSnapshot.get('timesRated') ?? 0;
          int loadedRating = userSnapshot.get('currentRating') ?? 0;
          loadedRating += int.parse(ratingToAdd);

          await userRef.update({
            'currentRating': loadedRating,
            'timesRated': timesRated + 1,
          });
        }
      } catch (e) {
        print('Error uploading rating: $e');
      }
    }

  static void showRating(String userId) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        int timesRated = userSnapshot.get('timesRated') ?? 0;
        int loadedRating = userSnapshot.get('currentRating') ?? 0;
        
        ratingShow = (loadedRating / timesRated).floor();
      }
    } catch (e) {
      print('Error uploading rating: $e');
    }
}
}