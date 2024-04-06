import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


import 'CartScreen.dart';
import 'WishlistScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renting App',
      home: Renting(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String vehicleNumber;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.vehicleNumber,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      price: data['price'],
      imageUrl: data['imageUrl'],
      vehicleNumber: data['vehicleNumber'],
    );
  }
}

class Renting extends StatefulWidget {
  @override
  _RentingState createState() => _RentingState();
}

class _RentingState extends State<Renting> {
  List<Product> products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartAndWishlistItems();
  }

  Future<void> fetchCartAndWishlistItems() async {
    final userId = _auth.currentUser!.uid;

    // Fetch cart items
    final cartSnapshot = await _firestore.collection('carts').doc(userId).get();
    final cartData = cartSnapshot.data();
    if (cartData != null && cartData.containsKey('itemIds')) {
      final cartItemIds = List<String>.from(cartData['itemIds']);
      final cartItems = await Future.wait(
        cartItemIds.map((id) => _firestore.collection('products').doc(id).get()),
      );
      // Update the UI with the fetched cart items
    }

    // Fetch wishlist items
    final wishlistSnapshot = await _firestore.collection('wishlists').doc(userId).get();
    final wishlistData = wishlistSnapshot.data();
    if (wishlistData != null && wishlistData.containsKey('itemIds')) {
      final wishlistItemIds = List<String>.from(wishlistData['itemIds']);
      final wishlistItems = await Future.wait(
        wishlistItemIds.map((id) => _firestore.collection('products').doc(id).get()),
      );
      // Update the UI with the fetched wishlist items
    }
  }

  Future<void> fetchProducts() async {
    final querySnapshot = await _firestore.collection('products').get();
    final productData = querySnapshot.docs.map((doc) => Product.fromDocument(doc)).toList();

    setState(() {
      products = productData;
    });
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('Add to Cart'),
              onTap: () async {
                final userId = _auth.currentUser!.uid;
                final cartDoc = _firestore.collection('carts').doc(userId);
                final cartData = (await cartDoc.get()).data();
                final itemIds = cartData?['itemIds'] ?? [];
                itemIds.add(product.id);
                await cartDoc.set({'itemIds': itemIds});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to Cart.'),
                  ),
                );
                fetchCartAndWishlistItems();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text('Add to Wishlist'),
              onTap: () async {
                final userId = _auth.currentUser!.uid;
                final wishlistDoc = _firestore.collection('wishlists').doc(userId);
                final wishlistData = (await wishlistDoc.get()).data();
                final itemIds = wishlistData?['itemIds'] ?? [];
                itemIds.add(product.id);
                await wishlistDoc.set({'itemIds': itemIds});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to Wishlist.'),
                  ),
                );
                fetchCartAndWishlistItems();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => WishlistScreen(),
                ),
              );
            },
            icon: Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => CartScreen(),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.network(product.imageUrl),
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\₹${product.price}'),
                Text(product.vehicleNumber),
              ],
            ),
            onTap: () {
              _showProductOptions(product);
            },
          );
        },
      ),
    );
  }
}