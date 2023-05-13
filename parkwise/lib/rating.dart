import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  @override
  _RatingWidgetState createState() => _RatingWidgetState();

  final String userId;
  RatingWidget({required this.userId});
}

class _RatingWidgetState extends State<RatingWidget> {

  void loadRating() async{
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        String loadedRating = userSnapshot.get('rating');
        _rating = int.parse(loadedRating);
      }
    } 
    catch (e) 
    {
      print('Error loading rating: $e');
    }
  }
  
  void uploadRating(String ratingToUpload) async{
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        await userRef.update({'rating': ratingToUpload});
      }
    } catch (e) {
      print('Error uploading rating: $e');
    }
  }

  late String userId;

  int _rating = 0;
  List<String> _ratingOptions = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    loadRating();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(0, 50, 0, 0),
          items: _ratingOptions.map((String option) {
            return PopupMenuItem<String>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: _rating >= int.parse(option)
                        ? Colors.orange
                        : Colors.grey[400],
                  ),
                  SizedBox(width: 10.0),
                  Text(option),
                ],
              ),
            );
          }).toList(),
        ).then((value) {
          setState(() {
            _rating = int.parse(value ?? '0');
            uploadRating(value ?? '0');
          });
        });
      },
      icon: Icon(Icons.star_border),
      label: Text('Rate this app'),
    );
  }
}

