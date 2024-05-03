// WishlistScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
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
    final wishlistSnapshot =
    await FirebaseFirestore.instance.collection('wishlists').doc(userId).get();
    final wishlistData = wishlistSnapshot.data();
    if (wishlistData != null && wishlistData.containsKey('itemIds')) {
      final wishlistItemIds = List<String>.from(wishlistData['itemIds']);
      final wishlistItemDocs = await Future.wait(
        wishlistItemIds.map((id) =>
            FirebaseFirestore.instance.collection('products').doc(id).get()),
      );

      final existingProductIds = wishlistItems?.map((item) => item.id).toSet() ?? {};
      final newWishlistItems = wishlistItemDocs
          .map((doc) => Product.fromDocument(doc))
          .where((product) => !existingProductIds.contains(product.id))
          .toList();

      setState(() {
        wishlistItems = [...?wishlistItems, ...newWishlistItems];
      });
    }
  }

  Future<void> _moveToCart(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(userId);
    final cartData = (await cartDoc.get()).data();
    final itemIds = cartData?['itemIds'] ?? [];
    itemIds.add(product.id);
    await cartDoc.set({'itemIds': itemIds});

    // Remove the item from the wishlist
    final wishlistDoc = FirebaseFirestore.instance.collection('wishlists').doc(userId);
    final wishlistData = (await wishlistDoc.get()).data();
    final wishlistItemIds = wishlistData?['itemIds'] ?? [];
    wishlistItemIds.remove(product.id);
    await wishlistDoc.set({'itemIds': wishlistItemIds});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product moved to Cart.'),
      ),
    );

    _loadWishlist(); // Refresh the wishlist items
  }

  Future<void> _deleteFromWishlist(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final wishlistDoc = FirebaseFirestore.instance.collection('wishlists').doc(userId);
    final wishlistData = (await wishlistDoc.get()).data();
    final wishlistItemIds = wishlistData?['itemIds'] ?? [];
    wishlistItemIds.remove(product.id);
    await wishlistDoc.set({'itemIds': wishlistItemIds});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product removed from Wishlist.'),
      ),
    );

    _loadWishlist(); // Refresh the wishlist items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlistItems!.isEmpty
          ? Center(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _moveToCart(product),
                  icon: Icon(Icons.shopping_cart),
                ),
                IconButton(
                  onPressed: () => _deleteFromWishlist(product),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}