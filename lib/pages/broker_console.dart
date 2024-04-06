import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'RentRequestsScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return AppBar(
      title: Text('Add Product'),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.displayName ?? ''),
                accountEmail: Text(user.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user.email!.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Rent Request'),
                leading: const Icon(Icons.file_copy),
                onTap: () {
                  // Navigate to the weather forecast module
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RentRequestsScreen() ),);
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  bool _isAddingProduct = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  List<Product> products = [];

  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  File? pickedImage;
  final productPriceController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  String? brokerMailId; // Add brokerMailId field

  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> uploadProductImage(File imageFile, String productId) async {
    final storageRef = _storage
        .ref()
        .child('users/${_auth.currentUser!.uid}/products/$productId');

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
      'brokerMailId': brokerMailId, // Add brokerMailId field
    });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
      _isAddingProduct = false;
    });

    // fetchProducts();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                    ),
                    TextField(
                      controller: productDescriptionController,
                      decoration:
                          InputDecoration(labelText: 'Product Description'),
                    ),
                    TextField(
                      controller: productPriceController,
                      decoration: InputDecoration(labelText: 'Product Price'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: vehicleNumberController,
                      decoration: InputDecoration(labelText: 'Vehicle Number'),
                    ),
                    TextField(
                      controller: TextEditingController(text: brokerMailId),
                      decoration: InputDecoration(labelText: 'Broker Mail Id'),
                    ),
                    ElevatedButton(
                      child: Text('Select Product Image'),
                      onPressed: () async {
                        final picked = await pickImage(ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            pickedImage = picked;
                          });
                        }
                      },
                    ),
                    if (pickedImage != null) Image.file(pickedImage!),
                    ElevatedButton(
                      child: Text('Add Product'),
                      onPressed: addProduct,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Product class definition here
class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String vehicleNumber;
  final String? brokerMailId; // Add brokerMailId field

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.vehicleNumber,
    this.brokerMailId,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      name: doc['name'],
      description: doc['description'],
      price: doc['price'].toDouble(),
      imageUrl: doc['imageUrl'],
      vehicleNumber: doc['vehicleNumber'],
      brokerMailId: doc['brokerMailId'],
    );
  }
}
