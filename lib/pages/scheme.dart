import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/app_drawer.dart';

class SchemePage extends StatefulWidget {
  @override
  _SchemePageState createState() => _SchemePageState();
}

class _SchemePageState extends State<SchemePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schemes for Welfare of Farmers'),
        backgroundColor: Colors.lightGreen[50],
      ),
      drawer: AppDrawer(user: user), // Make sure to provide the correct user object
      backgroundColor: Colors.lightGreen[50],
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
              return Card(
                color: Colors.lightGreen.withOpacity(0.7),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
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
                              Text(
                                'Description: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(document['description']),
                              SizedBox(height: 8), // Add a bit of gap here
                              Text(
                                'Eligibility: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(document['eligibility']),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}