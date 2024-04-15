import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'RentingScreen.dart';
import 'renting.dart';

class Product {
  final String id;
  final String brokerId;
  final String? brokerMailId;
  final String description;
  final String imageUrl;
  final String name;
  final int price;
  final String vehicleNumber;

  Product({
    required this.id,
    required this.brokerId,
    this.brokerMailId,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.vehicleNumber,
  });
}

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
              final productId = rentRequest.productIds.first;

              return FutureBuilder<Product>(
                future: _loadProduct(productId),
                builder: (context, productSnapshot) {
                  if (productSnapshot.hasError) {
                    return Text('Error: ${productSnapshot.error}');
                  }

                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final product = productSnapshot.data!;

                  return ListTile(
                    leading: Image.network(product.imageUrl),
                    title: Text(product.name),
                    subtitle: Text('${product.brokerMailId}\n${rentRequest.renterName} - ${rentRequest.renterEmail}\n${rentRequest.renterAddress}'),
                    trailing: Text(rentRequest.timestamp.toDate().toString()),
                    onTap: () {
                      _showProducts(rentRequest, (brokerMailId) {
                        // Handle the broker email here
                      });
                    },
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