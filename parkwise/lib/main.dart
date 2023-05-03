import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map.dart';

import 'package:crypto/crypto.dart';



/*
  TODO:
  D use cars instead of plate
  D add change password
  D add a logout popup
  D put markers in database 
  E change hardcoded location to current location 
  - add encrytion to password
  D add a field to marker that records the car that's parked there
  - make a option so that you can add more cars to your account
  D dropdown field
  ? change the lookup method to database id instead of e-mail
  E add a timeslot 

  - add that car is written to databasefield in marker so that when loading in on other account it is checked if the car is empty on marker
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'ParkWise App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<DocumentSnapshot?> checkUserByEmail(String email, String password) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot allUsers = await users.get();

      for (DocumentSnapshot user in allUsers.docs) {
        String storedEmail = user['email'];
        String storedPassword = user['password'];

        if (storedEmail == email && storedPassword == password) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(),
            ),
          );
        } else 
        {
          // show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
      // No user found with matching email and password
      return null;
    } catch (error) {
      print('Error checking user: $error');
      return null;
    }
  }

  Future<void> changePassword(String email, String currentPassword, String newPassword) async {
  try {
    final users = FirebaseFirestore.instance.collection('users');
    final snapshot = await users.where('email', isEqualTo: email).get();

    if (snapshot.docs.isNotEmpty) {
      final userDoc = snapshot.docs.first;
      final storedPassword = userDoc['password'];

      if (storedPassword == currentPassword) {
        await users.doc(userDoc.id).update({'password': newPassword});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect current password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
               Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/logo.png',
                width: 225,
                height: 225,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  checkUserByEmail(emailController.value.text,passwordController.value.text);
                },
                child: Text('LOGIN'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text('register'),
            
            ),
            ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String email = "";
        String password = "";
        String oldPassword = "";

        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'old Password',
                ),
                onChanged: (value) {
                  oldPassword = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call function to change password with email and password variables
                // Example: await FirebaseAuth.instance.currentUser.updatePassword(password);
                changePassword(email, oldPassword, password);
                Navigator.pop(context);
              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  },
  child: Text('Change Password'),
),
            ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController brandController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TextEditingController nameController = TextEditingController();

Future<void> addUser(String email, String password, String brand, String name) async {
  try {
    if (email.isEmpty || password.isEmpty || brand.isEmpty || name.isEmpty) {
      throw Exception('One or more required fields are empty');
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot existingUsers = await users.where('email', isEqualTo: email).get();

    if (existingUsers.size > 0) {
      throw Exception('User with email $email already exists');
    }

    var data = utf8.encode(password); // data being hashed
    var hashvalue = sha1.convert(data);

    print("SHA1 hashvalue: ${hashvalue.toString()}");


    DocumentReference newUser = await users.add({
      'email': email,
      'password': password,
        'cars': [
          {'brand': brand, 'name': name},
  ]
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
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  // Do registration logic here
                  String email = emailController.value.text;
                  String password = passwordController.value.text;
                  String brand = brandController.value.text;
                  String name = nameController.value.text;

                  addUser(email, password, brand, name );
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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<String> items = ['Item 1', 'Item 2', 'Item 3'];
  String selectedItem = 'Item 1';

  TextEditingController _LatController = TextEditingController();
  TextEditingController _LonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          ElevatedButton(
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
            child: Text('logout'),
          ),
          PopupMenuButton<String>(

            onSelected: (value) {
              setState(() {
                selectedItem = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return items.map((String item) {
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
                  Text(selectedItem),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Map(),
    );
  }
}


/**
 *          voor het schrijven naar database
 *          CollectionReference users = FirebaseFirestore.instance.collection('users');

            DocumentReference newUser = await users.add({
                  'email': "testemail",
                  'password': "testpassword"
                  'plate': "123-bel"
            });

            voor het ophalen van database
            
            CollectionReference users2 = FirebaseFirestore.instance.collection('users');
            QuerySnapshot existingUsers = await users.where('email', isEqualTo: "testemail").get();
            if (existingUsers.size > 0) {
              DocumentSnapshot userDocument = existingUsers.docs.first;
              String storedPassword = userDocument['password'];
              print(userDocument.toString() + storedPassword);
            }

            ENCRYPTION

            import 'package:encrypt/encrypt.dart';

            final plainText = 'my secret message';
            final key = Key.fromLength(32);
            final iv = IV.fromLength(16);

            final encrypter = Encrypter(AES(key));

            final encrypted = encrypter.encrypt(plainText, iv: iv);

            print(encrypted.base64);

 */
