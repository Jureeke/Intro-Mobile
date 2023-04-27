import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map.dart';



/*
  TODO:
  - use cars instead of plate
  - add change password
  - add a logout popup
  - put markers in database 
  * change hardcoded location to current location 
  - add encrytion to password and plate
  - add a field to marker that records the car that's parked there
  - make a option so that you can add more cars to your account, dropdown field
  - change the lookup method to database id instead of e-mail
  * add a timeslot 
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

  TextEditingController brandController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TextEditingController nameController = TextEditingController();

Future<void> addUser(String email, String password, String brand, String plate, String name) async {
  try {
    if (email.isEmpty || password.isEmpty || brand.isEmpty || plate.isEmpty || name.isEmpty) {
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
                controller: plateController,
                decoration: InputDecoration(
                  labelText: 'plate',
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
                  String plate = plateController.value.text;
                  String name = nameController.value.text;

                  addUser(email, password, brand, plate, name );
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
        ),
        ]
      ),
      body: Map()
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
