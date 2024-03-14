// CartScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'renting.dart'; // Import the Renting class

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product>? cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartSnapshot = await FirebaseFirestore.instance.collection('carts').doc(userId).get();
    final cartData = cartSnapshot.data();
    if (cartData != null && cartData.containsKey('itemIds')) {
      final cartItemIds = List<String>.from(cartData['itemIds']);
      final cartItems = await Future.wait(
        cartItemIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get()),
      );
      setState(() {
        this.cartItems = cartItems.map((doc) => Product.fromDocument(doc)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cartItems!.isEmpty
          ? Center(
        child: Text('Your cart is empty.'),
      )
          : ListView.builder(
        itemCount: cartItems?.length,
        itemBuilder: (context, index) {
          final product = cartItems?[index];
          return ListTile(
            leading: Image.network(product!.imageUrl),
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Text('\₹${product.price}'),
          );
        },
      ),
    );
  }
}