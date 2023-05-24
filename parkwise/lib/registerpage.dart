import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkwise/encrypt.dart';
import './loginpage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController brandController = TextEditingController();
  TextEditingController colorController = TextEditingController();

Future<void> addUser(String username, String password, String brand, String color) async {
  try {
    if (username.isEmpty || password.isEmpty || brand.isEmpty || color.isEmpty) {
      throw Exception('One or more required fields are empty');
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot existingUsers = await users.where('username', isEqualTo: username).get();

    if (existingUsers.size > 0) {
      throw Exception('User with name $username already exists');
    }


    
    DocumentReference newUser = users.doc(username);
    await newUser.set({
      'username': username,
      'password': Encrypter.encrypt(password),
      'cars': [
        {'brand': brand, 'color': color},
      ],
      'timesRated':0,
      'currentRating': 0,
      'hasReserved': false
    });
    print("user succesfully added");

  } catch (error) {
    print('Error adding user: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("login"),
              SizedBox(height: 20.0),
              TextFormField(
                controller: userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              Text("car"),
              SizedBox(height: 20.0),
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),

              TextFormField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'color',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  // Do registration logic here
                  String username = userNameController.value.text;
                  String password = passwordController.value.text;
                  String brand = brandController.value.text;
                  String color = colorController.value.text;

                  addUser(username, password, brand, color);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('REGISTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
