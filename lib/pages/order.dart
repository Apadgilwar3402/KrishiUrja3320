import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserOrdersScreen extends StatefulWidget {
  final String rentRequestId;

  const UserOrdersScreen({Key? key, required this.rentRequestId})
      : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  late Stream<DocumentSnapshot> _rentRequestStream;

  @override
  void initState() {
    super.initState();
    if (widget.rentRequestId.isNotEmpty) {
      _rentRequestStream = FirebaseFirestore.instance
          .collection('rentRequests')
          .doc(widget.rentRequestId)
          .snapshots();
    } else {
      // Handle the case where rentRequestId is empty or null
      _rentRequestStream = Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Request'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _rentRequestStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Rent request not found.'),
            );
          } else {
            final rentRequest = snapshot.data!.data() as Map<String, dynamic>?;
            if (rentRequest == null) {
              return const Center(
                child: Text('Invalid rent request data.'),
              );
            }

            final productIds = List<String>.from(rentRequest['productIds']);
            final renterName = rentRequest['renterName'];
            final renterEmail = rentRequest['renterEmail'];
            final renterAddress = rentRequest['renterAddress'];
            final timestamp = rentRequest['timestamp'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Renter Name: $renterName'),
                Text('Renter Email: $renterEmail'),
                Text('Renter Address: $renterAddress'),
                Text('Product IDs: ${productIds.join(', ')}'),
                Text('Requested on: $timestamp'),
                // Display product details
                FutureBuilder(
                  future: Future.wait(productIds.map((productId) async {
                    final productDoc = await FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .get();
                    return productDoc.data() as Map<String, dynamic>?;
                  })),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      final products =
                          snapshot.data as List<Map<String, dynamic>>?;
                      if (products == null) {
                        return const Center(
                          child: Text('No products found.'),
                        );
                      }

                      return Column(
                        children: products.map((product) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product Name: ${product['name']}'),
                              Text(
                                  'Product Description: ${product['description']}'),
                              Text('Product Image URL: ${product['imageUrl']}'),
                              Text('Product Price: ${product['price']}'),
                              Text(
                                  'Product Vehicle Number: ${product['vehicleNumber']}'),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}