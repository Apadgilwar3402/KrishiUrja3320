// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/pages/scheme.dart';
import 'package:modernlogintute/pages/weather.dart';
import 'package:modernlogintute/pages/renting.dart';

class menu extends StatefulWidget {
  const menu({super.key});

  @override
  _menuState createState() => _menuState();
}

class _menuState extends State<menu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    await _auth.signOut();
    // Navigate to the login page or any other page after logout
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget logoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: const Text('Logout', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KrishiUrja',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KrishiUrja', style: TextStyle(color: Colors.white)),
          actions: [
            logoutButton(),
          ],
        ),

        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(16.0),
                  image: const DecorationImage(
                    image: AssetImage('lib/images/renting.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => Renting(selectedProducts: [],),
                    ),
                  );
                  },
                  child: const Center(child: Text('Renting', style: TextStyle(fontSize: 24 ,color:Colors.white),),),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(16.0),
                  image: const DecorationImage(
                    image: AssetImage('lib/images/weather.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const WeatherScreen(),
                    ),
                  );
                  },
                  child: const Center(child: Text('Weather', style: TextStyle(fontSize: 24 ,color:Colors.white),),),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(16.0),
                  image: const DecorationImage(
                    image: AssetImage('lib/images/rate.jpg'),
                    fit:BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                  },
                  child: const Center(
                    child: Text(
                      'Rate',
                      style: TextStyle(fontSize: 24 ,color:Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(16.0),
                  image: const DecorationImage(
                    image: AssetImage('lib/images/scheme.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const scheme(),
                    ),
                  );
                  },
                  child: const Center(child: Text('Scheme', style: TextStyle(fontSize: 24 ,color:Colors.white),),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}