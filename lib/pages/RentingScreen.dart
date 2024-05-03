import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/address_screen.dart';
import 'order.dart';
import 'renting.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;

class RentingScreen extends StatefulWidget {
  final List<Product> selectedProducts;
  final Map<String, dynamic>? userData;
  final String? selectedAddress;

  const RentingScreen({super.key, required this.selectedProducts, this.userData, this.selectedAddress, required List<String> productIds});

  @override
  _RentingScreenState createState() => _RentingScreenState();
}

class _RentingScreenState extends State<RentingScreen> {
  final _addressController = TextEditingController();
  String? _selectedAddress;
  List<RentRequest> _rentRequests= [];

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.selectedAddress ?? '';
    _selectedAddress = widget.selectedAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _rentProducts() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final selectedProductIds = widget.selectedProducts.map((product) => product.id).toList();

    // Get the renter's details from the user profile
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile not found.'),
        ),
      );
      return;
    }
    final userData = userDoc.data();
    if (userData == null || userData['name'] == null || userData['email'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile incomplete.'),
        ),
      );
      return;
    }

    // Get the user who added the products
    final productOwnerIds = await FirebaseFirestore.instance
        .collection('products')
        .where(FieldPath.documentId, whereIn: selectedProductIds)
        .get()
        .then((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data()['userId'])
        .toSet()
        .toList());

    // Exclude the current user from the product owner ids
    productOwnerIds.remove(userId);

    // Send the rent request to the product owners
    for (final productOwnerId in productOwnerIds) {
      final rentData = {
        'renterId': userId,
        'renterName': userData['name'],
        'renterEmail': userData['email'],
        'renterAddress': _selectedAddress,
        'productIds': selectedProductIds,
        'timestamp': FieldValue.serverTimestamp(),
      };
      final rentRequest = await FirebaseFirestore.instance
          .collection('users')
          .doc(productOwnerId)
          .collection('rentRequests')
          .add(rentData);
      _rentRequests.add(RentRequest(
        id: rentRequest.id,
        userId: userId,
        productId: selectedProductIds.join(','),
        name: userData['name'] ?? '',
        price: widget.selectedProducts.fold(0, (sum, product) => sum + product.price),
        timestamp: Timestamp.now(),
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rent request sent successfully.'),
      ),
    );

    // Send email to broker
    for (final productId in selectedProductIds) {
      final brokerEmail = await _getBrokerEmail(productId);
      if (brokerEmail != null) {
        _sendEmailToBroker(
          userData['name'] ?? '',
          userData['email'] ?? '',
          _selectedAddress ?? '',
          productId,
          brokerEmail,
        );
      }
    }

    // Redirect the user to the order screen after placing the order
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserOrdersScreen(
          rentRequests: _rentRequests,
        ),
      ),
    );
  }

  Future<void> _showAddressScreen() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(
          initialAddress: _selectedAddress,
        ),
      ),
    );
    if (address != null) {
      setState(() {
        _selectedAddress = address as String;
        _addressController.text = _selectedAddress!;
      });
    }
  }

  Future<void> _sendEmailToBroker(String renterName, String renterEmail, String renterAddress, String productId, String brokerEmail) async {
    final productNames = await _getProductNames(productId);
    final message = Message()
      ..from = const Address('krishiurja3320@gmail.com')
      ..recipients.add(brokerEmail)
      ..subject = 'New Rent Request'
      ..text = 'Rent Request from $renterName ($renterEmail)\n\nAddress: $renterAddress\n\nProduct: ${productNames.join(', ')}';

    final smtpServer = gmail('krishiurja3320@gmail.com', 'Aks@3320');
    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sent to the broker successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send email to the broker.'),
        ),
      );
      print('Error sending email: $e');
    }
  }

  Future<List<String>> _getProductNames(String productId) async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final productDoc = await productRef.get();
    if (productDoc.exists) {
      return [productDoc.data()!['name']];
    }
    return [];
  }

  Future<String?> _getBrokerEmail(String productId) async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final productDoc = await productRef.get();
    if (productDoc.exists) {
      final brokerMailId = productDoc.data()!['brokerMailId'];
      if (brokerMailId != null) {
        final brokerRef = FirebaseFirestore.instance.collection('brokerUsers').doc(brokerMailId);
        final brokerDoc = await brokerRef.get();
        if (brokerDoc.exists) {
          return brokerDoc.data()!['email'];
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Products'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
            ),
            onTap: _showAddressScreen,
          ),
          TextButton(
            onPressed: _rentProducts,
            child: const Text('Rent Products'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.selectedProducts.length,
              itemBuilder: (context, index) {
                final product = widget.selectedProducts[index];
                return ListTile(
                  leading: Image.network(product.imageUrl),
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Text('\₹${product.price}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserOrdersScreen extends StatefulWidget {
  final List<RentRequest> rentRequests;
  const UserOrdersScreen({Key? key, required this.rentRequests}) : super(key: key);

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
    return Stream.value(widget.rentRequests);
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
                  title: Text(order.name),
                  subtitle: Text('Requested on: ${order.timestamp.toDate()}'),
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

class RentRequest {
  final String id;
  final String userId;
  final String productId;
  final String name;
  final double price;
  final Timestamp timestamp;

  RentRequest({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.price,
    required this.timestamp,
  });

  factory RentRequest.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return RentRequest(
      id: snapshot.id,
      userId: data['userId'],
      productId: data['productId'],
      name: data['name'],
      price: data['price'],
      timestamp: data['timestamp'],
    );
  }
}