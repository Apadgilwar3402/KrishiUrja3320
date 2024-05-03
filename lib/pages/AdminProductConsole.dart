import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product_model.dart';

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
        stream: FirebaseFirestore.instance.collection('rentRequests').orderBy('timestamp', descending: true).snapshots(),
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
              final rentRequest = snapshot.data!.docs[index];
              final rentRequestData = rentRequest.data() as Map<String, dynamic>;
              final productId = rentRequestData['productId'] as String?;
              final userId = rentRequestData['renterId'] as String?;


              final productsRef = FirebaseFirestore.instance.collection('products');
              final productsSnapshot = productsRef.where('id', isEqualTo: productId).get();

              return FutureBuilder<QuerySnapshot>(
                future: productsSnapshot,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> productsSnapshot) {
                  if (productsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (productsSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${productsSnapshot.error}'),
                    );
                  }

                  if (productsSnapshot.data == null || productsSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Product not found.'),
                    );
                  }

                  final product = productsSnapshot.data!.docs[0];
                  final versions = (product.data() as Map<String, dynamic>)['versions'] as List<dynamic>;
                  final versionHistory = versions.map((version) {
                    final versionData = version as Map<String, dynamic>;
                    return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(versionData['timestamp'].toDate()));
                  }).toList();

                  return Column(
                    children: [
                      ListTile(
                        leading: Image.network((product as Product).imageUrl),
                        title: Row(
                          children: [
                            Text((product as Product).name),
                            SizedBox(width: 8),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                }

                                if (!userSnapshot.hasData || userSnapshot.data!.exists == false) {
                                  return Text('Renter not found.');
                                }

                                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                return Text('Rented by: ${userData['name']}');
                              },
                            ),
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
          );
        },
      ),
    );
  }
}