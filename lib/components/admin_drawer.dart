import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/admin_Console.dart';
import 'package:modernlogintute/pages/admin_login.dart';

//import 'package:modernlogintute/pages/broker_console.dart';
import 'package:modernlogintute/pages/crop_list.dart';
import 'package:modernlogintute/pages/weather.dart';

import '../pages/AdminRentRequests.dart';
// Import the AdminLoginPage

class AppDrawer1 extends StatelessWidget {
  final User user;
  final BuildContext context;

  AppDrawer1({required this.user, required this.context});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginPage()), // Navigate back to AdminLoginPage
          (route) => false, // Clear all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = user.photoURL ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: photoUrl.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user.email!,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Renting'),
            leading: Icon(Icons.agriculture),
            onTap: () {
              //Navigate to the renting module
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminRentRequestsScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Weather Forecast'),
            leading: Icon(Icons.cloud),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Forecaste()),
              );
              // Navigate to the weather forecast module
            },
          ),
          ListTile(
            title: Text('Rates'),
            leading: Icon(Icons.attach_money),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CropList()),);
              // Navigate to the rates and schemes module
            },
          ),

          ListTile(
            title: Text('Schemes'),
            leading: Icon(Icons.attach_file),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminConsole()),
              );
              // Navigate to the rates and schemes module
            },
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.logout),
            onTap: signUserOut,
          ),
        ],
      ),
    );
  }
}