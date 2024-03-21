import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/AdminProductConsole.dart';
import '../pages/admin_Console.dart';
import '../pages/rates_console.dart';

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
                  'Admin Name',
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
            title: const Text('Products'),
            leading: const Icon(Icons.agriculture),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProductScreen()),
              );
            },
          ),
           ListTile(
            title: const Text('Scheme'),
            leading: const Icon(Icons.people),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RateConsole()),
              );
            },
          ),
          ListTile(
            title: const Text('Rates'),
            leading: const Icon(Icons.agriculture),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminConsole() ),);
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