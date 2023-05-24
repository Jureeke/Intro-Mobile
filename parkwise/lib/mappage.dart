import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkwise/ratingfunctions.dart';
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

  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    getCars();
    RatingFunctions.showRating(userId);
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
        String carName = '${car['brand']} ${car['color']}';
        carNames.add(carName);
      }
      if (carNames.isNotEmpty) {
        selectedCar = carNames[0]; // Select the first car by default
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
    }
  } catch (error) 
  {
    print('Error checking user: $error');
  }
}

  void addCar(String brand, String color) async{
    try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await userRef.get();
        List<dynamic> carsList = userSnapshot.get('cars');

        var newCar = <String, String>{
          'brand': brand,
          'color': color
          };
          carsList.add(newCar);
        // Update the user document with the new list of cars
        await userRef.update({'cars': carsList});
        getCars();

      } catch (error) {
        print('Error checking user: $error');
      }
      }

  void deleteCar(String carName) async {
  try {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();
    List<dynamic> carsList = userSnapshot.get('cars');

    // Find the car to be deleted by its name
    for (var car in carsList) {
      String carBrand = car['brand'];
      String carColor = car['color'];
      String fullName = '$carBrand $carColor';
      if (fullName == carName) {
        carsList.remove(car);
        break;
      }
    }

    // Update the user document with the modified list of cars
    await userRef.update({'cars': carsList});
    getCars();
  } catch (error) {
    print('Error deleting car: $error');
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
              controller: _colorController,
              decoration: InputDecoration(
                hintText: 'Enter car color',
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
              String color = _colorController.text.trim();
              String brand = _brandController.text.trim();
              addCar(brand, color);
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

  void _showDeleteCarDialog(String carName) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this car?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteCar(carName);
              Navigator.pop(context);
            },
            child: Text('Delete'),
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
          Text('Rating: ${RatingFunctions.ratingShow}'),
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
            child: Text('choose Car'),
          ),  
          ElevatedButton(
          onPressed: () {
            _showDeleteCarDialog(selectedCar);
          },
          child: Text('Delete Car'),
),
        ],
      ),
       body: Map2(currentCar: selectedCar, userId: userId,)
    );
  }
}
