import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'broker_console.dart';

class BrokerLoginPage extends StatefulWidget {
  const BrokerLoginPage({super.key});

  @override
  _BrokerLoginPageState createState() => _BrokerLoginPageState();
}

class _BrokerLoginPageState extends State<BrokerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
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

                      // Check if the user's email exists in the 'brokerUsers' collection
                      final brokerUsers = FirebaseFirestore.instance.collection('brokerUsers');
                      final brokerUserSnapshot = await brokerUsers.where('email', isEqualTo: _emailController.text).get();

                      if (brokerUserSnapshot.docs.isNotEmpty) {
                        // Check if the user's email is verified
                        final user = FirebaseAuth.instance.currentUser;

                        if (user?.emailVerified ?? false) {
                          // Show successful login message and redirect
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Broker logged in successfully!'),
                            ),
                          );
                          // Uncomment and modify if you want to redirect to a specific page:
                          final User? user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) => AddProductPage(),
                              ),
                            );
                          }
                        } else {
                          // Show email verification error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email address not verified. Please verify your email to continue.'),
                            ),
                          );
                        }
                      } else {
                        // Show user authorization error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid broker credentials'),
                          ),
                        );}
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
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}