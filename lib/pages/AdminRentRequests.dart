import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'RentRequestsScreen.dart';
import 'renting.dart';

class AdminRentRequestsScreen extends StatefulWidget {
  const AdminRentRequestsScreen({Key? key}) : super(key: key);

  @override
  _AdminRentRequestsScreenState createState() =>
      _AdminRentRequestsScreenState();
}

class _AdminRentRequestsScreenState extends State<AdminRentRequestsScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final adminDoc = await FirebaseFirestore.instance
          .collection('adminUsers')
          .doc(user.uid)
          .get();
      setState(() {
        _isAdmin = adminDoc.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Rent Requests'),
      ),
      body: _isAdmin
          ? StreamBuilder<List<RentRequest>>(
              stream: _getRentRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final rentRequests = snapshot.data!;

                return ListView.builder(
                  itemCount: rentRequests.length,
                  itemBuilder: (context, index) {
                    final rentRequest = rentRequests[index];
                    return FutureBuilder<List<dynamic>>(
                      future: _loadProductAndUserData(rentRequest),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(title: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return ListTile(
                              title: Text('Error: ${snapshot.error}'));
                        }

                        final data = snapshot.data!;
                        final product = data[0] as Product;
                        final renterData = data[1] as Map<String, dynamic>;
                        final ownerData = data[2] as Map<String, dynamic>;

                        return ListTile(
                          leading: Image.network(product.imageUrl),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Broker Email: ${product.brokerMailId}'),
                              Text('Renter Name: ${rentRequest.renterName}'),
                              Text('Renter Email: ${rentRequest.renterEmail}'),
                              Text(
                                  'Renter Address: ${rentRequest.renterAddress}'),
                              Text(
                                  'Requested on: ${rentRequest.timestamp.toDate()}'),
                              Text('Product Owner: ${ownerData['name']}'),
                              Text(
                                  'Product Owner Email: ${ownerData['email']}'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )
          : Center(
              child: Text('You are not an admin.'),
            ),
    );
  }

  Stream<List<RentRequest>> _getRentRequestsStream() {
    return FirebaseFirestore.instance
        .collectionGroup('rentRequests')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final productIds = List<String>.from(data['productIds'] ?? []);
        return RentRequest(
          id: doc.id,
          renterId: data['renterId'] ?? '',
          renterName: data['renterName'] ?? '',
          renterEmail: data['renterEmail'] ?? '',
          renterAddress: data['renterAddress'] ?? '',
          productIds: productIds,
          timestamp: data['timestamp'] ?? Timestamp.now(),
        );
      }).toList();
    });
  }

  Future<List<dynamic>> _loadProductAndUserData(RentRequest rentRequest) async {
    final productId = rentRequest.productIds.first;
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    final product = Product.fromDocument(productDoc);

    final renterDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(rentRequest.renterId)
        .get();
    final renterData = renterDoc.data();

    final ownerId = productDoc.data()?['brokerId'];
    final ownerDoc = await FirebaseFirestore.instance
        .collection('brokerUsers')
        .doc(ownerId)
        .get();
    final ownerData = ownerDoc.data();

    return [product, renterData ?? {}, ownerData ?? {}];
  }
}
