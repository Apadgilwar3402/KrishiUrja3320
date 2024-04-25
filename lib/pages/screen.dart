import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/admin_login.dart';
import 'package:modernlogintute/pages/auth_page.dart';
import 'broker_login.dart';

void main() => runApp(const Screen());

class Screen extends StatelessWidget {
  const Screen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/screen2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: double.infinity,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const MyStatefulWidget(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrokerLoginPage()),
              ).then((_) {
                setState(() {}); // Refresh UI if needed
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              backgroundColor: Colors.transparent,
            ),
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Broker Login',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginPage()),
              ).then((_) {
                setState(() {}); // Refresh UI if needed
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              backgroundColor: Colors.transparent,
            ),
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Admin Login',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              ).then((_) {
                setState(() {}); // Refresh UI if needed
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
              backgroundColor: Colors.transparent,
            ),
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'User Login',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}