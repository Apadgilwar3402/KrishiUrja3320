import 'package:flutter/material.dart';

import 'screen.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightGreen[50],
        body: MyStatefulWidget(),
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
    return buildHomePage(context);
  }

  Widget buildHomePage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      body: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'lib/images/man.png',
          width: 200,
          height: 200,
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'You have to start from Somewhere!!',
            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            "JAY JAWAN, JAY KISAN",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            'Building a community for a better farming future.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(50),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to Screen page
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Screen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              minimumSize: const Size(300, 20),
              padding: const EdgeInsets.all(22),
            ),
            child: const Text('Get Started',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}