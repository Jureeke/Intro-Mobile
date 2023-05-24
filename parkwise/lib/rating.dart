
import 'package:flutter/material.dart';
import 'package:parkwise/ratingfunctions.dart';

class RatingWidget extends StatefulWidget {
  @override
  _RatingWidgetState createState() => _RatingWidgetState();


  final String markerID;
  final String userId;

  RatingWidget({Key? key, required this.markerID, required this.userId}) : super(key: key);
}

class _RatingWidgetState extends State<RatingWidget> {

  List<String> _ratingOptions = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    super.initState();
    RatingFunctions.loadRating(widget.userId);
    RatingFunctions.showRating(widget.userId);
    }

@override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(0, 50, 0, 0),
          items: [
            ..._ratingOptions.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: RatingFunctions.rating >= int.parse(option)
                          ? Colors.orange
                          : Colors.grey[400],
                    ),
                    SizedBox(width: 10.0),
                    Text(option),
                  ],
                ),
              );
            }),
            PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 10.0),
                  Text('Cancel'),
                ],
              ),
            ),
          ],
        ).then((value) {
          if (value != null && value != 'cancel') {
            setState(() {
              RatingFunctions.rating = int.parse(value);
              RatingFunctions.uploadRating(value, widget.userId);
            });
          }
        });
      },
      icon: Icon(Icons.star_border),
      label: Text('Rate this user'),
    );
  }
}

