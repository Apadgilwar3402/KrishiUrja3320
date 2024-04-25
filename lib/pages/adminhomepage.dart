import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/admin_drawer.dart';

class AdminHomePage extends StatelessWidget {
  AdminHomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[50],
      ),
      drawer: AppDrawer1(user: user, context: context),
      // Pass the valid context here
      body: Center(
        child: Text("LOGGED IN AS : ${user.email!}"),
      ),
    );
  }
}