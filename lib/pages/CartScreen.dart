import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/models/address_model.dart';
import 'package:modernlogintute/models/item_model.dart';
import 'package:modernlogintute/screens/address_screen.dart';
import 'package:modernlogintute/screens/rent_request_screen.dart';
import 'package:modernlogintute/screens/rent_request_list_screen.dart';

import '../screens/rent_request.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Product> _selectedProducts = [];
  Address? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          // Display the selected address or "Select Address"
          _selectedAddress != null
              ? Text(_selectedAddress!.displayAddress)
              : Text('Select Address'),
          DropdownButton<Address?>(
            onChanged: (address) {
              setState(() {
                _selectedAddress = address;
              });
            },
            items: _getAddressItems(),
          ),
          IconButton(
            onPressed: _selectedAddress == null
                ? null
                : () async {
              final rentRequest = RentRequest(
                id: '',
                userId: _auth.currentUser!.uid,
                products: _selectedProducts,
                address: _selectedAddress!,
                requestedAt: Timestamp.now(),
                status: 'pending', selectedProducts: [], createdAt: DateTime.now(),
              );

              // Save the RentRequest to the Firestore
              await _firestore.collection('rent_requests').add(rentRequest.toJson());

              // Clear the selected products and address
              setState(() {
                _selectedProducts.clear();
                _selectedAddress = null;
              });

              // Show the RentRequestScreen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RentRequestScreen(
                    rentRequest: rentRequest, selectedProducts: [],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('cart')
            .doc('products')
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = (snapshot.data!.docs).map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>)).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return CheckboxListTile(
                value: _selectedProducts.contains(product),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedProducts.add(product);
                    } else {
                      _selectedProducts.remove(product);
                    }
                  });
                },
                title: Text(product.name),
                subtitle: Text(product.description),
                secondary: Image.network(product.imageUrl),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final address = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressScreen(address: null,),
            ),
          );

          if (address != null) {
            setState(() {
              _selectedAddress = address;
            });
          }
        },
        child: const Icon(Icons.add_location),
      ),
    );
  }

  List<DropdownMenuItem<Address?>> _getAddressItems() {
    final items = _auth.currentUser!.uid.isNotEmpty
        ? _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Address.fromJson(doc.data())).toList())
        .map((addresses) => DropdownMenuItem<Address?>(
      value: addresses.isNotEmpty ? addresses.first : null,
      child: Text(addresses.isNotEmpty ? addresses.first.displayAddress : ''),
    ))
        .toList()
        : [];

    return [
      DropdownMenuItem<Address?>(
        value: null,
        child: const Text('Select Address'),
      ),

    ];
  }
}
