import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'renting.dart';

class RentRequestsScreen extends StatefulWidget {
  @override
  _RentRequestsScreenState createState() => _RentRequestsScreenState();
}

class _RentRequestsScreenState extends State<RentRequestsScreen> {
  Stream<QuerySnapshot>? _rentRequestsStream;
  bool _isBroker = false;

  @override
  void initState() {
    super.initState();
    _checkIfBroker();
    _loadRentRequests();
  }

  void _checkIfBroker() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('brokerUsers').doc(userId).get();
    setState(() {
      _isBroker = userDoc.data()?['isBroker']?? false;
    });
  }

  void _loadRentRequests() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _rentRequestsStream = FirebaseFirestore.instance
        .collectionGroup('rentRequests')
        .where('productIds', arrayContainsAny: [userId])
        .snapshots();
  }

  void _showProducts(List<String> productIds) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentingScreen(productIds: productIds),
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
          ? StreamBuilder<QuerySnapshot>(
        stream: _rentRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final rentRequests = snapshot.data!.docs;
          if (rentRequests.isEmpty) {
            return Center(
              child: Text('No rent requests yet.'),
            );
          }

          return ListView.builder(
            itemCount: rentRequests.length,
            itemBuilder: (context, index) {
              final rentRequest = rentRequests[index].data() as Map<String, dynamic>;
              final renterName = rentRequest['renterName'];
              final renterEmail = rentRequest['renterEmail'];
              final renterAddress = rentRequest['renterAddress'];
              final productIds = List<String>.from(rentRequest['productIds']);

              return ListTile(
                title: Text('$renterName ($renterEmail)'),
                subtitle: Text('Address: $renterAddress'),
                trailing: Text('Products: ${productIds.length}'),
                onTap: () {
                  _showProducts(productIds);
                },
              );
            },
          );
        },
      )
          : Center(
        child: Text('You are not a broker.'),
      ),
    );
  }
}

class RentingScreen extends StatefulWidget {
  final List<String> productIds;

  const RentingScreen({required this.productIds});

  @override
  _RentingScreenState createState() => _RentingScreenState();
}

class _RentingScreenState extends State<RentingScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    _productsFuture = _fetchProducts();
    super.initState();
  }

  Future<List<Product>> _fetchProducts() async {
    final products = await Future.wait(
      widget.productIds.map((id) =>
          FirebaseFirestore.instance.collection('products').doc(id).get()),
    );
    return products.map((doc) => Product.fromDocument(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  leading: Image.network(product.imageUrl),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
