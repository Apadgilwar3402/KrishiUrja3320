// CartScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'RentingScreen.dart';
import 'renting.dart'; // Import the Renting class

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product>? cartItems = [];
  List<Product>? selectedProducts = [];
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartSnapshot =
    await FirebaseFirestore.instance.collection('carts').doc(userId).get();
    final cartData = cartSnapshot.data();
    if (cartData != null && cartData.containsKey('itemIds')) {
      final cartItemIds = List<String>.from(cartData['itemIds']);
      final cartItemDocs = await Future.wait(
        cartItemIds.map((id) =>
            FirebaseFirestore.instance.collection('products').doc(id).get()),
      );

      final existingProductIds = cartItems?.map((item) => item.id).toSet() ?? {};
      final newCartItems = cartItemDocs
          .map((doc) => Product.fromDocument(doc))
          .where((product) => !existingProductIds.contains(product.id))
          .toList();

      setState(() {
        cartItems = [...?cartItems, ...newCartItems];
      });
    }
  }

  Future<void> _moveToWishlist(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final wishlistDoc =
    FirebaseFirestore.instance.collection('wishlists').doc(userId);
    final wishlistData = (await wishlistDoc.get()).data();
    final itemIds = wishlistData?['itemIds'] ?? [];
    itemIds.add(product.id);
    await wishlistDoc.set({'itemIds': itemIds});

    // Remove the item from the cart
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(userId);
    final cartData = (await cartDoc.get()).data();
    final cartItemIds = cartData?['itemIds'] ?? [];
    cartItemIds.remove(product.id);
    await cartDoc.set({'itemIds': cartItemIds});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product moved to Wishlist.'),
      ),
    );

    _loadCart(); // Refresh the cart items
  }

  Future<void> _deleteFromCart(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(userId);
    final cartData = (await cartDoc.get()).data();
    final cartItemIds = cartData?['itemIds'] ?? [];
    cartItemIds.remove(product.id);
    await cartDoc.set({'itemIds': cartItemIds});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product removed from Cart.'),
      ),
    );

    _loadCart(); // Refresh the cart items
  }

  void _selectProduct(Product product) {
    setState(() {
      if (selectedProducts!.contains(product)) {
        selectedProducts!.remove(product);
      } else {
        selectedProducts!.add(product);
      }
    });
  }

  Future<void> _rentProducts() async {
    if (selectedProducts!.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userSnapshot.data();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RentingScreen(
            selectedProducts: selectedProducts!,
            userData: userData, productIds: [],
          ),
        ),
      );
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _selectProduct(product),
                  icon: Icon(
                    selectedProducts!.contains(product)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                ),
                IconButton(
                  onPressed: () => _moveToWishlist(product),
                  icon: Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () => _deleteFromCart(product),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _rentProducts,
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

