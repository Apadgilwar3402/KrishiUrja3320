// renting.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart' as item_model;
import '../models/item_model.dart';
import 'CartScreen.dart';
import 'WishlistScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}
class Renting extends StatefulWidget {
  final List<Product> selectedProducts;
  final Map<String, dynamic>? userData; // Make this nullable

  Renting({required this.selectedProducts, this.userData});

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

  List<Product> cartItems = [];
  List<Product> wishlistItems = [];

  Future<void> fetchCartAndWishlistItems() async {
    final userId = _auth.currentUser!.uid;

    // Fetch cart items
    final cartSnapshot = await _firestore.collection('carts').doc(userId).get();
    final cartData = cartSnapshot.data();
    if (cartData != null && cartData.containsKey('itemIds')) {
      final cartItemIds = List<String>.from(cartData['itemIds']);
      final cartItemsSnapshot = await Future.wait(
        cartItemIds.map((id) => _firestore.collection('products').doc(id).get()),
      );
      cartItems = cartItemsSnapshot.map((snapshot) => Product.fromDocument(snapshot)).toList();
      // Update the UI with the fetched cart items
    }

    // Fetch wishlist items
    final wishlistSnapshot = await _firestore.collection('wishlists').doc(userId).get();
    final wishlistData = wishlistSnapshot.data();
    if (wishlistData != null && wishlistData.containsKey('itemIds')) {
      final wishlistItemIds = List<String>.from(wishlistData['itemIds']);
      final wishlistItemsSnapshot = await Future.wait(
        wishlistItemIds.map((id) => _firestore.collection('products').doc(id).get()),
      );
      wishlistItems = wishlistItemsSnapshot.map((snapshot) => Product.fromDocument(snapshot)).toList();
      // Update the UI with the fetched wishlist items
    }
  }
  Future<void> fetchProducts() async {
    final querySnapshot = await _firestore.collection('products').get();
    final productData = querySnapshot.docs.map((doc) => Product(
      id: doc.id,
      name: doc.data()['name'],
      description: doc.data()['description'],
      price: doc.data()['price'],
      imageUrl: doc.data()['imageUrl'],
      vehicleNumber: doc.data()['vehicleNumber'], ownerId: '', userId: '',
    )).toList();

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
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Add to Cart'),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Add to Wishlist'),
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
        title: const Text('Product List'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => WishlistScreen(),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => CartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}