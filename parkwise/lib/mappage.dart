import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkwise/rating.dart';
import './map.dart';
import 'loginpage.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
  final String userId;
  MapPage({required this.userId});

}

class _MapPageState extends State<MapPage> {
  TextEditingController _LatController = TextEditingController();
  TextEditingController _LonController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    getCars();
  }

  List<String> carNames = [];
  String selectedCar = "";

  void getCars() async { 
  try {
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      carNames.clear();

      List<dynamic> storedCars = userSnapshot.get('cars');
      for (var car in storedCars) {
        String carName = 'brand: ${car['brand']}, name: ${car['name']}';
        carNames.add(carName);
      }
      if (carNames.isNotEmpty) {
        selectedCar = carNames[0]; // Select the first car by default
      }
      setState(() {}); // Update the widget tree to show the dropdown
    } else {
      // User not found, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
    }
  } catch (error) 
  {
    print('Error checking user: $error');
  }
}

  void addCar(String brand, String name) async{
    try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await userRef.get();
        List<dynamic> carsList = userSnapshot.get('cars');

        var newCar = <String, String>{
          'brand': brand,
          'name': name
          };
          carsList.add(newCar);
        // Update the user document with the new list of cars
        await userRef.update({'cars': carsList});
        getCars();

      } catch (error) {
        print('Error checking user: $error');
      }
      }

void _showAddCarDialog() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Car'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter car name',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                hintText: 'Enter car brand',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String name = _nameController.text.trim();
              String brand = _brandController.text.trim();
              addCar(brand, name);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // perform logout action
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('car'),
            onPressed: () {
              _showAddCarDialog();
        
            }
          ),
          RatingWidget(userId: userId),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        if (selectedCar == "") {
                          String selectedCar = carNames.first;
                        }

                        return PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              selectedCar = value;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return carNames.map((String item) {
                              return PopupMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Text(selectedCar),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Text('Select a Car'),
          ),
          
        ],
      ),
       body: Map2(currentCar: selectedCar)
    );
  }
}
