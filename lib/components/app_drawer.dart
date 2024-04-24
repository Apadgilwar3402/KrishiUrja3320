import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/about_us_screen.dart';
import 'package:modernlogintute/pages/home_page.dart';
import 'package:modernlogintute/pages/Profile.dart';

class AppDrawer extends StatelessWidget {
  final User? user;

  AppDrawer({required this.user}) : assert(user != null, 'User must not be null');

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = user?.photoURL ?? '';

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
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
                    user!.email!,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Profile'),
                    leading: Icon(Icons.person),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Home'), // Add a new ListTile for the Home page
                    leading: Icon(Icons.home),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('About Us'),
                    leading: Icon(Icons.info),
                    onTap: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutUsScreen()),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Logout'),
                    leading: Icon(Icons.logout),
                    onTap: () => signUserOut(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}