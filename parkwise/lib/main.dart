import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';

/*
  TODO:
  - add encrytion to password
  - add time
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
