//import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'map.dart';



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
        title: 'Namer App',
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

  Future<void> checkUserByEmail(String email, String password) async {
  try {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot existingUsers = await users.where('email', isEqualTo: email).get();

    if (existingUsers.size > 0) {
      DocumentSnapshot userDocument = existingUsers.docs.first;
      String storedPlate = userDocument['plate'];
      String storedPassword = userDocument['password'];

      if (storedPassword == password) {
         // ignore: use_build_context_synchronously
         Navigator.push(context,MaterialPageRoute(builder: (context) => MapPage(plate: storedPlate)));
      }
    }
  } catch (error) {
    print('Error checking user: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
               Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
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
)
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
  TextEditingController plateNumberController = TextEditingController();

Future<void> addUser(String email, String password, String plate) async {
  try {
    if (email.isEmpty || password.isEmpty || plate.isEmpty) {
      throw Exception('One or more required fields are empty');
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot existingUsers = await users.where('email', isEqualTo: email).get();

    if (existingUsers.size > 0) {
      throw Exception('User with email $email already exists');
    }

    DocumentReference newUser = await users.add({
      'email': email,
      'password': password,
      'plate': plate
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
              TextFormField(
                controller: plateNumberController,
                decoration: InputDecoration(
                  labelText: 'Plate Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  // Do registration logic here
                  addUser(emailController.value.text, passwordController.value.text, plateNumberController.value.text);
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

class MapPage extends StatelessWidget { 
  final String plate;
  MapPage({required this.plate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plate: " + plate),
        actions: <Widget>[
          ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text('logout'),
        )]
      ),
      body: Map(location: LatLng(51.2298087, 4.4158815))
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
 */
