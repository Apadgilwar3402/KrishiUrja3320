import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modernlogintute/pages/menu.dart';

import 'admin_Console.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      // Authenticate the user
                      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      // Check if the user's email exists in the 'adminUsers' collection
                      final adminUsers = FirebaseFirestore.instance.collection('adminUsers');
                      final adminUserSnapshot = await adminUsers.where('email', isEqualTo: _emailController.text).get();

                      if (adminUserSnapshot.docs.isNotEmpty) {
                        // Check if the user's email is verified
                        final user = FirebaseAuth.instance.currentUser;

                        if (user?.emailVerified ?? false) {
                          // Show successful login message and redirect
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin logged in successfully!'),
                            ),
                          );
                          // Uncomment and modify if you want to redirect to a specific page:
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) => AdminConsole(),
                            ),
                          );
                        } else {
                          // Show email verification error message
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                          content: Text('Email address not verified. Please verify your email to continue.'),
                          ),
                  );
                  }
                  } else {
                  // Show admin authorization error message
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                  content: Text('Invalid admin credentials'),
                  ),
                  );
                  }
                  } catch (error) {
                  // Show general error message
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text('An error occurred: ${error.toString()}'),
                  ),
                  );
                  }
                }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}