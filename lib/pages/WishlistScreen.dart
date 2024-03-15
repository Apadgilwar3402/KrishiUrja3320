// WishlistScreen.dart
// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, file_names, unnecessary_string_escapes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'renting.dart'; // Import the Renting class

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product>? wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final wishlistSnapshot = await FirebaseFirestore.instance.collection('wishlists').doc(userId).get();
    final wishlistData = wishlistSnapshot.data();
    if (wishlistData != null && wishlistData.containsKey('itemIds')) {
      final wishlistItemIds = List<String>.from(wishlistData['itemIds']);
      final wishlistItems = await Future.wait(
        wishlistItemIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get()),
      );
      setState(() {
        this.wishlistItems = wishlistItems.map((doc) => Product.fromDocument(doc)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: wishlistItems!.isEmpty
          ? const Center(
        child: Text('Your wishlist is empty.'),
      )
          : ListView.builder(
        itemCount: wishlistItems?.length,
        itemBuilder: (context, index) {
          final product = wishlistItems?[index];
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