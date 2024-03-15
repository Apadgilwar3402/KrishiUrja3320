// ignore_for_file: unused_local_variable, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_escapes

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'CartScreen.dart';
import 'WishlistScreen.dart';
import 'add_product.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAddingProduct = false;

  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  File? pickedImage;
  final productPriceController = TextEditingController();
  final vehicleNumberController = TextEditingController();

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
    final productData = querySnapshot.docs.map((doc) => Product(
      id: doc.id,
      name: doc.data()['name'],
      description: doc.data()['description'],
      price: doc.data()['price'],
      imageUrl: doc.data()['imageUrl'],
      vehicleNumber: doc.data()['vehicleNumber'],
    )).toList();

    setState(() {
      products = productData;
    });
  }

  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> uploadProductImage(File imageFile, String productId) async {
    final storageRef = _storage.ref().child('users/${_auth.currentUser!.uid}/products/$productId');

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> addProduct() async {
    final vehicleNumber = vehicleNumberController.text.trim();

    if (vehicleNumber.isEmpty || vehicleNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid vehicle number.'),
        ),
      );
      return;
    }

    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image for the product.'),
        ),
      );
      return;
    }

    final productId = _firestore.collection('products').doc().id;
    final imageUrl = await uploadProductImage(pickedImage!, productId);

    await _firestore.collection('products').doc(productId).set({
      'name': productNameController.text,
      'description': productDescriptionController.text,
      'price': double.parse(productPriceController.text),
      'imageUrl': imageUrl,
      'vehicleNumber': vehicleNumber,
    });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
      _isAddingProduct = false;
    });

    fetchProducts();
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
                fetchCartAndWishlistItems();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _isAddingProduct ? Renting() : const AddProductPage()),
              );
            },
            icon: Icon(_isAddingProduct ? Icons.close : Icons.add),
          ),
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
                  builder: (BuildContext context) => const CartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: _isAddingProduct
          ? Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingProduct = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: IconButton(
                        onPressed: () async {
                          final picked = await pickImage(ImageSource.gallery);
                          if (picked != null) {
                            setState(() {
                              pickedImage = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                      ),
                      title: TextField(
                        controller: productNameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                        ),
                      ),
                      subtitle: TextField(
                        controller: productDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Product Description',
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: productPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Product Price',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: vehicleNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Number',
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: addProduct,
                      child: const Text('Add Product'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      )
          : ListView.builder(
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