import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/app_drawer.dart';

class RatesPage extends StatelessWidget {
  final User user;
  const RatesPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rates'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Rates').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                title: Text(document['cropName']),
                subtitle: Text('₹ ${document['price'].toStringAsFixed(2)}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(document['cropName']),
                      content: Text('Price: ₹ ${document['price'].toStringAsFixed(2)}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      drawer: AppDrawer(user: user),
    );
  }
}