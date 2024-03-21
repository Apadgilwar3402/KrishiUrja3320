// screens page
import 'package:flutter/material.dart';
import 'Admin_Login.dart';
import 'auth_page.dart';
import 'broker_login.dart';


void main() => runApp(const Screen());

class Screen extends StatelessWidget {
  const Screen({super.key});

  //static const String _title = 'KrishiUrja';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightGreen[50],
        // appBar: AppBar(
        //     backgroundColor: Colors.lightGreen, title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  //get onTap => AdminLoginPage(onTap: () {  },);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Added for spacing
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute
                    (builder: (context) =>  BrokerLoginPage(),));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.fromLTRB(55, 30, 55, 30)),
            child: const Text('Broker Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute
                    (builder: (context) =>  AdminLoginPage(),));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.fromLTRB(60, 30, 60, 30)),
            child: const Text('Admin Login'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute
                    (builder: (context) => const AuthPage(),));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.fromLTRB(65, 30, 65, 30)),
            child: const Text('User Login'),
          ),
        ],
      ),
    );
  }
}