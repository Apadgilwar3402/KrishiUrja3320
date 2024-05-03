import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'RentingScreen.dart';
import 'renting.dart';

class RentRequestsScreen extends StatefulWidget {
  @override
  _RentRequestsScreenState createState() => _RentRequestsScreenState();
}

class _RentRequestsScreenState extends State<RentRequestsScreen> {
  Stream<List<RentRequest>>? _rentRequestsStream;
  bool _isBroker = false;

  @override
  void initState() {
    super.initState();
    _checkIfBroker();
    _loadRentRequests();
  }

  void _checkIfBroker() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is signed in: ${user.uid}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('brokerUsers')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final brokerData = querySnapshot.docs.first.data();
        setState(() {
          _isBroker = brokerData['isBroker'] ?? false;
          print('Is broker: $_isBroker');
        });
      } else {
        setState(() {
          _isBroker = false;
          print('Is broker: $_isBroker');
        });
      }
    } else {
      print('User is not signed in');
    }
  }

  void _loadRentRequests() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _rentRequestsStream = FirebaseFirestore.instance
          .collection('users/${user.uid}/rentRequests')
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
    } else {
      print('User is not signed in');
    }
  }

  void _showProducts(RentRequest rentRequest, Function(String) updatebrokerMailId) {
    rentRequest.fetchbrokerMailId(updatebrokerMailId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentingScreen(
          productIds: rentRequest.productIds,
          selectedProducts: [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Requests'),
      ),
      body: _isBroker
          ? StreamBuilder<List<RentRequest>>(
        stream: _rentRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
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
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        final data = snapshot.data!;
                        final product = data[0] as Product;
                        final userData = data[1] as Map<String, dynamic>;

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
                            ],
                          ),
                        );
                },
              );
            },
          );
        },
      ):
      Center(
        child: Text('You are not a broker.'),
      ),
    );
  }

  Future<Product> _loadProduct(String productId) async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
    final data = doc.data()!;
    final brokerId = data['brokerId'];
    final broker = await FirebaseFirestore.instance.collection('brokerUsers').doc(brokerId).get();
    final brokerData = broker.data();
    final imageUrl = data['imageUrl'];
    final name = data['name'];
    final description = data['description'];
    final price = data['price'];
    final vehicleNumber = data['vehicleNumber'];

    return Product(
      id: doc.id,
      brokerId: brokerId,
      brokerMailId: brokerData?['brokerMailId'],
      description: description,
      imageUrl: imageUrl,
      name: name,
      price: price,
      vehicleNumber: vehicleNumber,
    );
  }
}

Future<List<dynamic>> _loadProductAndUserData(RentRequest rentRequest) async {
  final productId = rentRequest.productIds.first;
  final productDoc = await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .get();
  final product = Product.fromDocument(productDoc);

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(rentRequest.renterId)
      .get();
  final userData = userDoc.data();

  return [product, userData];
}

class RentRequest {
  final String id;
  final String renterId;
  final String renterName;
  final String renterEmail;
  final String renterAddress;
  final List<String> productIds;
  final Timestamp timestamp;
  String? brokerMailId;

  RentRequest({
    required this.id,
    required this.renterId,
    required this.renterName,
    required this.renterEmail,
    required this.renterAddress,
    required this.productIds,
    required this.timestamp,
  });

  void fetchbrokerMailId(Function(String) updatebrokerMailId) async {
    final productDocs = await FirebaseFirestore.instance.collection('products').where('productId', whereIn: productIds).get();
    final productData = productDocs.docs.first.data();
    final brokerId = productData['brokerId'];
    final broker = await FirebaseFirestore.instance.collection('brokerUsers').doc(brokerId).get();
    final brokerData = broker.data();
    updatebrokerMailId(brokerData?['brokerMailId'] ?? '');
    this.brokerMailId = brokerData?['brokerMailId'] ?? '';
  }
}