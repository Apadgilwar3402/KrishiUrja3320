import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/app_drawer.dart';
import 'package:modernlogintute/pages/menu.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Text('KrishiUrja'),
        backgroundColor: Colors.lightGreen, // Set the background color
      ),
      drawer: AppDrawer(user: user), // Use your AppDrawer widget here
      body: menu(),
      //Center(child: Text("LOGGED IN AS : ${user.email!}")),
    );
  }
}