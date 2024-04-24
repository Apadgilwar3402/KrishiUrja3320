import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/crop_list1.dart';
import 'package:modernlogintute/pages/weather.dart';
import 'package:modernlogintute/pages/scheme.dart';
import 'package:modernlogintute/pages/renting.dart';

class menu extends StatefulWidget {
  const menu({super.key});

  @override
  _menuState createState() => _menuState();
}

class _menuState extends State<menu> {

  Widget buildMenuButton(String text, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(13.0),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        margin: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.0),
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.3),
              ),
              Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          height: double.infinity,
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildMenuButton('Renting', 'lib/images/rent.jpeg', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => Renting(),
                    ),
                  );
                }),
              ),
              Expanded(
                child: buildMenuButton('Weather', 'lib/images/weather.jpeg', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => Forecaste(),
                    ),
                  );
                }),
              ),
              Expanded(
                child: buildMenuButton('Rate', 'lib/images/rate.jpeg', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => CropList1(),
                    ),
                  );
                }),
              ),
              Expanded(
                child: buildMenuButton('Scheme', 'lib/images/schemes.jpg', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => SchemePage(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}