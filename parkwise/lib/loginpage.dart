import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './mappage.dart';
import 'registerpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

Future<DocumentSnapshot?> checkUserById(String userId, String password) async {
  try {
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      String storedPassword = userSnapshot.get('password');
      if (storedPassword == password) {
        // Passwords match, navigate to MapPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(userId: userId),
          ),
        );
      } else {
        // Passwords don't match, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid password')),
        );
      }
      return userSnapshot;
    } else {
      // User not found, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
      return null;
    }
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
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
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
                  checkUserById(usernameController.value.text,passwordController.value.text);
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
