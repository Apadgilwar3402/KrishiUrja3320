import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserOrdersScreen extends StatefulWidget {
  final String userId;

  UserOrdersScreen({required this.userId});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  late Stream<List<Order>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = _getOrdersStream();
  }

  Stream<List<Order>> _getOrdersStream() {
    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('orders');

    return ordersRef.orderBy('timestamp', descending: true).snapshots().map(
          (querySnapshot) => querySnapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: StreamBuilder<List<Order>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No orders found.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return ListTile(
                  title: Text(order.name.join(', ')),
                  subtitle: Text('Ordered on: ${order.timestamp.toDate()}'),
                  trailing: Text('\₹${order.price}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class Order {
  final String id;
  final List<String> productIds;
  final List<String> name;
  final double price;
  final Timestamp timestamp;

  Order({
    required this.id,
    required this.productIds,
    required this.name,
    required this.price,
    required this.timestamp,
  });

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Order(
      id: snapshot.id,
      productIds: List<String>.from(data['productIds']),
      name: List<String>.from(data['name']),
      price: data['price'],
      timestamp: data['timestamp'],
    );
  }
}