import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


class Map2 extends StatefulWidget {
  @override
  _MapPage createState() => _MapPage();

  final String currentCar;
  Map2({required this.currentCar});
}

class _MapPage extends State<Map2> {
  MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);

  List<Marker> markers = [];
  List<MarkerInfo> markerReserved = []; 

  Color _markerColor = Colors.green;

  late String currentCar;

  int index = 0;

  @override
  void initState() {
    super.initState();
    currentCar = widget.currentCar;

    _getCurrentLocation();
    _getAllMarkers();
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
    CollectionReference markers = FirebaseFirestore.instance.collection('markers');
    QuerySnapshot markerData = await markers.get();
    List<DocumentSnapshot> markersDocs = markerData.docs;

    for (var doc in markersDocs) {
      //check if reserved and put into list
      bool reserved = doc.get('reserved');
      var id = doc.id;
      var marker = MarkerInfo(id, reserved); // Create a new MarkerInfo object
      markerReserved.add(marker);
    }
}

  void createMarker(LatLng markerLocation) async {
  String markerID = "";

  try {
    CollectionReference markers = FirebaseFirestore.instance.collection('markers');

    GeoPoint _markerLocation = GeoPoint(markerLocation.latitude, markerLocation.longitude);

    DocumentReference newMarker = await markers.add({
      'location': _markerLocation,
      'endtime': 1,
      'reserved': true,
        'car': {'brand': "", 'name': ""},
    });

    markerID = newMarker.id;
    
    _reloadMap();
    print("marker succesfully added");

  } catch (error) {
    print('Error adding marker: $error');
  }
  
  markers.add(
  Marker(
    width: 80.0,
    height: 80.0,
    point: markerLocation,
    builder: (ctx) => GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            if (markerReserved[0].reserved == false) {
              return AlertDialog(
              title: Text("Confirmation"),
              content: Text("Do you want to reserve this place?"),
              actions: [
                ElevatedButton(
                  child: Text("Yes"),
                  onPressed: () {
                  setState(() {
                    markerReserved[0].reserved = true;
                  });
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("No"),
                  onPressed: () {
                    setState(() {
                      markerReserved[0].reserved = false; // Update the reserved status of this marker
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
            } else {
              return AlertDialog(
              title: Text("Confirmation"),
              content: Text("are you leaving"),
              actions: [
                ElevatedButton(
                  child: Text("Yes"),
                  onPressed: () {
                    setState(() {
                      markerReserved[0].reserved = false; // Update the reserved status of this marker
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("No"),
                  onPressed: () {
                    setState(() {
                      markerReserved[0].reserved = true; // Update the reserved status of this marker
                    });
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
      child: Icon(Icons.location_on, size: 40, color: markerReserved[0].reserved ? Colors.red : Colors.blue)), // Use red color if the marker is reserved, blue otherwise
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
          onTap: (tapPosition, point) => {
              createMarker(point)
            },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers
              ),
            ],
          ),
      );
  }
}



class MarkerInfo {
  String id;
  bool reserved;
  
  MarkerInfo(this.id, this.reserved);
}

