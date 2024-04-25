import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'broker_console.dart';

class BrokerLoginPage extends StatefulWidget {
  @override
  _BrokerLoginPageState createState() => _BrokerLoginPageState();
}

class _BrokerLoginPageState extends State<BrokerLoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign broker in method
  void signBrokerIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        ); // Center
      },
    );

    try {
      // Try to sign in
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Check if the user's email exists in the 'brokerUsers' collection
      final brokerUsers = FirebaseFirestore.instance.collection('brokerUsers');
      final brokerUserSnapshot = await brokerUsers.where('email', isEqualTo: emailController.text).get();

      Navigator.pop(context); // Close the dialog

      if (brokerUserSnapshot.docs.isNotEmpty) {
        // Check if the user's email is verified
        final user = FirebaseAuth.instance.currentUser;

        if (user?.emailVerified ?? false) {
          // Show successful login message and potentially redirect:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Broker logged in successfully!'),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        } else {
          // Show email verification error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email address not verified. Please verify your email to continue.'),
            ),
          );
        }
      } else {
        // Show user authorization error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid broker credentials'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the dialog

      // Wrong email or password
      showErrorMessage(e.code);
    }
  }

  // wrong email message popup
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ); // AlertDialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              // welcome back, you've been missed!
              Text(
                'Welcome back you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // email textfield
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                text: "Login",
                onTap: signBrokerIn,
              ),

              const SizedBox(height: 50),

            ],
          ),
        ),
      ),
    );
  }
}