import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/address_screen.dart';
import 'order.dart';
import 'renting.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class RentingScreen extends StatefulWidget {
  final List<Product> selectedProducts;
  final Map<String, dynamic>? userData;

  RentingScreen({required this.selectedProducts, this.userData});

  @override
  _RentingScreenState createState() => _RentingScreenState();
}

class _RentingScreenState extends State<RentingScreen> {
  final _addressController = TextEditingController();
  String? _selectedAddress;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _rentProducts() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final selectedProductIds =
    widget.selectedProducts.map((product) => product.id).toList();

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
    if (userData == null ||
        userData['name'] == null ||
        userData['email'] == null) {
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(productOwnerId)
          .collection('rentRequests')
          .add(rentData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rent request sent successfully.'),
      ),
    );

    // Redirect the user to the order screen after placing the order
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserOrdersScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }

  Future<void> _showAddressScreen() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(initialAddress: _selectedAddress),
      ),
    );

    if (address!= null) {
      setState(() {
        _selectedAddress = address as String;
      });
    }
  }

  Future<void> _sendEmailToBroker(String renterName, String renterEmail,
      String renterAddress, List<String> productIds) async {
    final brokerEmail = await _getBrokerEmail(productIds
        .first); // Replace with your logic to fetch the broker's email

    if (brokerEmail!= null) {
      final productNames = await _getProductNames(productIds);
      final message = Message()
        ..from = Address('your_email@gmail.com')
        ..recipients.add(brokerEmail)
        ..subject = 'New Rent Request'
        ..text =
            'Rent Request from $renterName ($renterEmail)\n\nAddress: $renterAddress\n\nProducts:\n${productNames.join('\n')}';

      final smtpServer = gmail('your_email@gmail.com', 'your_app_password');

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broker email not found.'),
        ),
      );
    }
  }

  Future<List> _getProductNames(List<String> productIds) async {
    final products = await Future.wait(
      productIds.map((id) =>
          FirebaseFirestore.instance.collection('products').doc(id).get()),
    );
    return products.map((doc) => doc.data()?['name'] ?? 'Unknown').toList();
  }

  Future<String?> _getBrokerEmail(String productId) async {
    final productRef =
    FirebaseFirestore.instance.collection('products').doc(productId);
    final productDoc = await productRef.get();

    if (productDoc.exists) {
      final productData = productDoc.data();
      if (productData != null && productData['brokerMailId'] != null) {
        final brokerRef = FirebaseFirestore.instance
            .collection('brokerUsers')
            .doc(productData['brokerMailId']);
        final brokerDoc = await brokerRef.get();

        if (brokerDoc.exists) {
          final brokerData = brokerDoc.data();
          if (brokerData != null && brokerData['email'] != null) {
            return brokerData['email'];
          }
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Products'),
      ),
      body: Column(
        children: [
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
          ListTile(
            title: TextField(
              controller: _addressController,
              onTap: _showAddressScreen,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Send Email to Broker'),
            onTap: () async {
              final userRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid);
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
              if (userData == null ||
                  userData['name'] == null ||
                  userData['email'] == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User profile incomplete.'),
                  ),
                );
                return;
              }

              _sendEmailToBroker(
                userData['name'] ?? '',
                userData['email'] ?? '',
                _selectedAddress ?? '',
                widget.selectedProducts.map((product) => product.id).toList(),
              );
            },
          ),
          ElevatedButton(
            onPressed: _rentProducts,
            child: Text('Rent Products'),
          ),
        ],
      ),
    );
  }
}