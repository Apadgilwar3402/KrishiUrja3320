import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/app_drawer.dart';
 // Import the app drawer

class scheme extends StatefulWidget {
  @override
  _schemeState createState() => _schemeState();
}

class _schemeState extends State<scheme> {
  get user => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schemes')),
      drawer: AppDrawer(user: user), // Add the app drawer here
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('schemes').snapshots(),
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
                title: Text(document['name']),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(document['name']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Description: ${document['description']}'),
                            Text('Eligibility: ${document['eligibility']}'),
                          ],
                        ),
                      );
                    },
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