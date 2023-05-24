import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:parkwise/rating.dart';

import 'markerinfo.dart';

class Map2 extends StatefulWidget {
  final String currentCar;
  final String userId;

  Map2({Key? key, required this.currentCar, required this.userId}) : super(key: key);

  @override
  Map2State createState() => Map2State();
}

class Map2State extends State<Map2> {
  MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  List<Marker> markers = [];
  List<MarkerInfo> markerReserved = [];
  bool isOWner = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getAllMarkers();
    print(widget.currentCar);
  }

  void _reloadMap() {
    setState(() {});
  }

  void _getCurrentLocation() async {
    Location location = Location();
    LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
    mapController.move(currentLocation, 16.0);
  }

  void _getAllMarkers() async {
    CollectionReference markersCollection = FirebaseFirestore.instance.collection('markers');
    QuerySnapshot markerData = await markersCollection.get();
    List<DocumentSnapshot> markersDocs = markerData.docs;

    for (var doc in markersDocs) {
      DateTime currentTime = DateTime.now();
      Timestamp markerTime = doc.get('endtime');
      DateTime endTime = markerTime.toDate();

      if (currentTime.difference(endTime).inMinutes > 0 && doc.get('reserved_user') == null) {
        await markersCollection.doc(doc.id).delete();
      } else {
        MarkerInfo marker = MarkerInfo(
          doc.id,
          doc.get('owner'),
          doc.get('reserved_user'),
          doc.get('location'),
          doc.get('endtime'),
          doc.get('car'),
        );
        markerReserved.add(marker);
      }

      setState(() {
        markers = markerReserved.map((marker) => createMapMarker(marker)).toList();
      });
    }
  }

  Future<DateTime?> showClockAndGetSelectedDateTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      return selectedDateTime;
    }
    return null;
  }

  void updateMarkerReserved(String markerIdToAdd) async {
    try {
      CollectionReference markersCollection = FirebaseFirestore.instance.collection('markers');
      DocumentSnapshot markerDoc = await markersCollection.doc(markerIdToAdd).get();
      
      if (markerDoc.exists) {
        MarkerInfo marker = MarkerInfo(
          markerDoc.id,
          markerDoc.get('owner'),
          markerDoc.get('reserved_user'),
          markerDoc.get('location'),
          markerDoc.get('endtime'),
          markerDoc.get('car'),
        );
        markerReserved.add(marker);
      }
    }catch (e) {
      print('Error updating: $e');
    }
  }

  void createMarker(LatLng markerLocation) async {
    print(widget.currentCar);
    String markerID = "";
    final selectedDateTime = await showClockAndGetSelectedDateTime(context) as DateTime;
    try {
      CollectionReference databaseMarkers = FirebaseFirestore.instance.collection('markers');
      GeoPoint _markerLocation = GeoPoint(markerLocation.latitude, markerLocation.longitude);

      DocumentReference newMarker = await databaseMarkers.add({
        'owner': widget.userId,
        'location': _markerLocation,
        'endtime': selectedDateTime,
        'reserved_user': null,
        'car': {'brand': widget.currentCar.split(' ')[0], 'color':widget.currentCar.split(' ')[1]},
      });

      markerID = newMarker.id;

      _reloadMap();
      print("marker successfully added");
      updateMarkerReserved(markerID);
    } catch (error) {
      print('Error adding marker: $error');
    }

  setState(() {
    markers.add(createMapMarker(MarkerInfo(markerID, widget.userId, null, GeoPoint(markerLocation.latitude, markerLocation.longitude), Timestamp.fromDate(selectedDateTime), {'brand': widget.currentCar.split(' '), 'color': widget.currentCar[1]})));
  });
  
  }

  void updateMarkerEndTime(String markerId, DateTime newEndTime) async {
  try {
    DocumentReference markerRef = FirebaseFirestore.instance.collection('markers').doc(markerId);
    await markerRef.update({'endtime': newEndTime});
    print('Marker end time updated successfully');
  } catch (error) {
    print('Error updating marker end time: $error');
  }
}


  Marker createMapMarker(MarkerInfo marker) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(marker.location.latitude, marker.location.longitude),
      builder: (ctx) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              if (marker.reserved == false && widget.userId != marker.ownerReference) {
                return AlertDialog(
                  title: Text("Confirmation"),
                  content: Text("Do you want to reserve this place?"),
                  actions: [
                    ElevatedButton(
                      child: Text("Reserve"),
                      onPressed: () async {
                        final selectedDateTime = await showClockAndGetSelectedDateTime(context);
                        updateMarkerEndTime(marker.id, selectedDateTime!);
                        //write time to databse
                        marker.reserveMarker(widget.userId,selectedDateTime).then((succes){setState(() {});});
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text("Confirmation"),
                  content: Text("Are you leaving?"),
                  actions: [
                    ElevatedButton(
                      child: Text("Leave"),
                      onPressed: () {
                        if (marker.reserved == true && widget.userId == marker.ownerReference) {
                          marker.ownerReference = marker.reservedReference;
                          marker.reservedReference = "";
                          marker.reserveMarker(null, marker.endtime.toDate());
                          
                        }
                        else if(marker.reserved == false && widget.userId == marker.ownerReference){
                          
                          marker.deleteMarkerhelp();
                          markerReserved.removeWhere((element) => element.id == marker.id);
                          markers.removeWhere((element) => element.point == LatLng(marker.location.latitude, marker.location.longitude));
                          setState(() {});
                        };
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.userId == marker.reservedReference) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Rate User'),
                              content: RatingWidget(userId: marker.ownerReference ?? "",  markerID: marker.id),
                            );
                          },
                        );
                      }else
                      {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("you can't rate yourself"),
                            );
                          },
                        );
                      }},
                      child: Text('rate the user before you'),
                    ),
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
            },
          );
        
        },
        child: Container(
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                size: 40,
                color: marker.reserved ? Colors.red : Colors.blue,
              ),
              SizedBox(height: 8), // Optional spacing between icon and text
              Text(
                'End ${marker.endtime.toDate().hour}:${marker.endtime.toDate().minute}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentLocation,
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.none,
          onTap: (tapPosition, point) => createMarker(point),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }
}

