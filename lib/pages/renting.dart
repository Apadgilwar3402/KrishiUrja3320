import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
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

class Renting extends StatefulWidget {
  @override
  _RentingState createState() => _RentingState();
}

class _RentingState extends State<Renting> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
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
                if (!itemIds.contains(product.id)) {
                  itemIds.add(product.id);
                  await cartDoc.set({'itemIds': itemIds});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added to Cart.'),
                    ),
                  );
                  fetchCartAndWishlistItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product already in Cart.'),
                    ),
                  );
                }
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
                if (!itemIds.contains(product.id)) {
                  itemIds.add(product.id);
                  await wishlistDoc.set({'itemIds': itemIds});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added to Wishlist.'),
                    ),
                  );
                  fetchCartAndWishlistItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product already in Wishlist.'),
                    ),
                  );
                }
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
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text('No products found'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ProductTile(product: product);
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      final productData = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              return Product.fromDocument(doc);
            } else {
              print('Invalid product data: $data');
              return null;
            }
          })
          .whereType<Product>()
          .toList();

      return productData;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}

class ProductTile extends StatefulWidget {
  final Product product;

  const ProductTile({Key? key, required this.product}) : super(key: key);

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isExpanded = false;

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
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final cartDoc =
                    FirebaseFirestore.instance.collection('carts').doc(userId);
                final cartData = (await cartDoc.get()).data();
                final itemIds = cartData?['itemIds'] ?? [];
                if (!itemIds.contains(product.id)) {
                  itemIds.add(product.id);
                  await cartDoc.set({'itemIds': itemIds});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added to Cart.'),
                    ),
                  );
                  // Fetch the updated cart and wishlist items
                  await (context as _RentingState).fetchCartAndWishlistItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product already in Cart.'),
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text('Add to Wishlist'),
              onTap: () async {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final wishlistDoc = FirebaseFirestore.instance
                    .collection('wishlists')
                    .doc(userId);
                final wishlistData = (await wishlistDoc.get()).data();
                final itemIds = wishlistData?['itemIds'] ?? [];
                if (!itemIds.contains(product.id)) {
                  itemIds.add(product.id);
                  await wishlistDoc.set({'itemIds': itemIds});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added to Wishlist.'),
                    ),
                  );
                  // Fetch the updated cart and wishlist items
                  await (context as _RentingState).fetchCartAndWishlistItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product already in Wishlist.'),
                    ),
                  );
                }
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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Image.network(
              widget.product.imageUrl,
              width: 50,
              height: 50,
            ),
            title: Text(widget.product.name),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.product.vehicleNumber),
                Text('\₹${widget.product.price.toStringAsFixed(1)}'),
                // Display price on the right side
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(widget.product.imageUrl),
                  SizedBox(height: 8.0),
                  Text(
                    widget.product.name,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(widget.product.description),
                  SizedBox(height: 8.0),
                  Text('Vehicle Number: ${widget.product.vehicleNumber}'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}