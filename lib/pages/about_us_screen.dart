//user side
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/app_drawer.dart';

void main() {
  runApp(AboutUsScreen());
}

class AboutUsScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('About KrishiUrja'),
        ),
        drawer: AppDrawer(user: user),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green[200]!, Colors.green[400]!],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your existing content here
                Text(
                  'Welcome to KrishiUrja!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'KrishiUrja is a revolutionary app designed to empower farmers and enhance the future of farming. Our unique platform integrates four key modules:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                _buildModule('Renting Devices', 'Helps farmers rent devices like tractors and sprinklers.', Icons.build),
                _buildModule('Rates in Different Towns/Cities', 'Enables farmers to access crop rates in various cities.', Icons.attach_money),
                _buildModule('Schemes for Farmers', 'Provides information on government and organizational schemes for farmers.', Icons.lightbulb_outline),
                _buildModule('Weather Forecasting', 'Offers accurate weather forecasts to aid farming decisions.', Icons.wb_sunny),
                SizedBox(height: 16),
                Text(
                  'KrishiUrja is a one-of-a-kind solution that addresses the daily challenges faced by farmers. Our app combines essential functionalities in a single platform, making it unique and highly beneficial for farmers.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModule(String title, String description, IconData iconData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(iconData),
          title: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}