import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/weather.dart';

import '../pages/scheme.dart';

class AppDrawer extends StatelessWidget {
  final User user;

  const AppDrawer({super.key, required this.user});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = user.photoURL ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
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
                      : const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user.email!,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Renting'),
            leading: const Icon(Icons.agriculture),
            onTap: () {
              // Navigate to the renting module
            },
          ),
          ListTile(
            title: const Text('Weather Forecast'),
            leading: const Icon(Icons.cloud),
            onTap: () {
              // Navigate to the weather forecast module
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const weather() ),);
            },
          ),
          ListTile(
            title: const Text('Rates'),
            leading: const Icon(Icons.attach_money),
            onTap: () {
              // Navigate to the rates and schemes module
            },
          ),
          ListTile(
            title: const Text('Scheme'),
            leading: const Icon(Icons.file_copy),
            onTap: () {
              // Navigate to the weather forecast module
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => scheme() ),);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: signUserOut,
          ),
        ],
      ),
    );
  }
}
