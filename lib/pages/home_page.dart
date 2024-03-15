// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/app_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseAuth auth = FirebaseAuth.instance; // Create an instance

  Future<void> signUserOut() async {
    try {
      await auth.signOut();
      print('User signed out successfully.');
    } on FirebaseAuthException catch (e) {
      print('Error signing out: ${e.message}');
    }
  }

  String getGreetingMessage() {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      return "LOGGED IN AS: ${currentUser.email}";
    } else {
      return "Not logged in";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getGreetingMessage()), // Dynamically update the text
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          getGreetingMessage(), // Use the getter method here too
          style: const TextStyle(fontSize: 20),
        ),
      ),
      drawer: _buildAppDrawer(), // Call helper method to conditionally build the drawer
    );
  }

  Widget _buildAppDrawer() {
    // Check if user is signed in before providing access to AppDrawer
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      return AppDrawer(user: currentUser);
    } else {
      return const SizedBox(); // Empty widget placeholder when user is not signed in
    }
  }
}