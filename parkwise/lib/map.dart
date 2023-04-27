import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  @override
  _Map createState() => _Map();
}

class _Map extends State<Map> {
  final LatLng location = LatLng(51.2298087, 4.4158815);

  List<LatLng> markerLocations = [
    LatLng(51.2298087, 4.4158),
    LatLng(51.2298087, 4.4156),    
    LatLng(51.2298087, 4.4160),    
    LatLng(51.2298087, 4.4165),  
    ];

  List<Marker> markers = [];
    List<bool> markerReserved = List.generate(4, (index) => false); // Initialize the markerReserved list with false values

  // Variable to track the color of the marker
  Color _markerColor = Colors.green;

  @override 
  Widget build(BuildContext context) {
    for (int i = 0; i < markerLocations.length; i++) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: markerLocations[i],
          builder: (ctx) => GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (markerReserved[i] == false) {
                    return AlertDialog(
                    title: Text("Confirmation"),
                    content: Text("Do you want to reserve this place?"),
                    actions: [
                      ElevatedButton(
                        child: Text("Yes"),
                        onPressed: () {
                          setState(() {
                            markerReserved[i] = true; // Update the reserved status of this marker
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text("No"),
                        onPressed: () {
                          setState(() {
                            markerReserved[i] = false; // Update the reserved status of this marker
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
                            markerReserved[i] = false; // Update the reserved status of this marker
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text("No"),
                        onPressed: () {
                          setState(() {
                            markerReserved[i] = true; // Update the reserved status of this marker
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
              child: Icon(Icons.location_on, color: markerReserved[i] ? Colors.red : Colors.blue), // Use red color if the marker is reserved, blue otherwise
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: location,
          zoom: 18.0,
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
