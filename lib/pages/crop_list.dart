//Admin Side
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/admin_drawer.dart';
import 'package:modernlogintute/pages/rates_console.dart';
import 'package:modernlogintute/pages/Rice.dart';
import 'package:modernlogintute/pages/Jowar.dart';

class CropList extends StatelessWidget {
  const CropList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop List'),
        backgroundColor: Colors.lightGreen[50],
      ),
      drawer: AppDrawer1(user: user, context: context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/crop3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildElevatedButton(
                        'Wheat', Icons.grass, Colors.blue, RateConsole(),
                        context),
                    SizedBox(height: 40),
                    buildElevatedButton(
                        'Rice', Icons.grass, Colors.green, RateConsole1(),
                        context),
                    SizedBox(height: 40),
                    buildElevatedButton(
                        'Jowar', Icons.grass,
                        const Color.fromARGB(255, 244, 151, 12), RateConsole2(),
                        context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildElevatedButton(String text, IconData icon, Color color,
      Widget navigateTo, BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navigateTo),
          );
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: color, width: 4),
          ),
          primary: Colors.transparent,
          onPrimary: Colors.transparent,
        ),
      ),
    );
  }
}