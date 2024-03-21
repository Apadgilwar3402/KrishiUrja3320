import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item_model.dart';

class AdminProductScreen extends StatefulWidget {
  @override
  _AdminProductScreenState createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Product Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').orderBy('timestamp', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final product = snapshot.data!.docs[index];
              final versions = (product.data() as Map<String, dynamic>)['versions'] as List<dynamic>;
              final versionHistory = versions.map((version) {
                final versionData = version as Map<String, dynamic>;
                return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(versionData['timestamp'].toDate()));
              }).toList();

              return Column(
                children: [
                  ListTile(
                    leading: Image.network((product as Product).imageUrl),title: Row(
                    children: [
                      Text((product as Product).name),
                      SizedBox(width: 8),
                      Text('Added by: ${(product as Product).userId}'),
                    ],
                  ),
                    subtitle: Text((product as Product).description),
                    trailing: Text('\₹${(product as Product).price}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Version History'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: versionHistory,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}