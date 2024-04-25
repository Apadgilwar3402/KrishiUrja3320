import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({Key? key}) : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  Stream<List<RentRequest>> _ordersStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    _ordersStream = _getOrdersStream();
  }

  Stream<List<RentRequest>> _getOrdersStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('rentRequests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) {
      return query.docs.map((doc) {
        final data = doc.data();
        final productIds = List<String>.from(data['productIds'] ?? []);
        return RentRequest(
          id: doc.id,
          userId: userId,
          productIds: productIds,
          renterName: data['renterName'] ?? '',
          renterEmail: data['renterEmail'] ?? '',
          renterAddress: data['renterAddress'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rent Requests'),
      ),
      body: StreamBuilder<List<RentRequest>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No rent requests found.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return ListTile(
                  title: Text('${order.renterName} (${order.renterEmail})'),
                  subtitle: Text(
                      'Address: ${order.renterAddress}\nProducts: ${order.productIds.length}'),
                  trailing: Text('Requested on: ${order.timestamp.toDate()}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RentRequest {
  final String id;
  final String userId;
  final List<String> productIds;
  final String renterName;
  final String renterEmail;
  final String renterAddress;
  final Timestamp timestamp;

  RentRequest({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.renterName,
    required this.renterEmail,
    required this.renterAddress,
    required this.timestamp,
  });
}