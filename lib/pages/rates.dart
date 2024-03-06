import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/app_drawer.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  _RatesPageState createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  get user => null; // Placeholder for potential user data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rates')),
      drawer: AppDrawer(user: user), // Add the app drawer here
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Rates').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                title: Text(document['cropName']),
                subtitle: Text('₹ ${document['price'].toStringAsFixed(2)}'), // Format price with two decimal places
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(document['cropName']),
                      content: Text('Price: ₹ ${document['price'].toStringAsFixed(2)}'), // Display price in dialog
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}