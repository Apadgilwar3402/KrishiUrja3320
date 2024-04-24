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
  );}}
// Import the ProductList widget

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  bool _isAddingProduct = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  File? pickedImage;
  final productPriceController = TextEditingController();
  final vehicleNumberController = TextEditingController();

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
        'brokerMailId': _auth.currentUser!.email, // Set the brokerMailId to the current user's email
      });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
      _isAddingProduct = false;
    });

    //fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(FirebaseAuth.instance.currentUser!.displayName ?? ''),
              accountEmail: Text(FirebaseAuth.instance.currentUser!.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  FirebaseAuth.instance.currentUser!.email!.substring(0, 1).toUpperCase(),
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
                  MaterialPageRoute(builder: (context) => RentRequestsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Products'),
              onTap: () {
                // Navigate to the ProductList widget
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductList()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () => signUserOut(context),
            ),
          ],
        ),
      ),
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
                      decoration: InputDecoration(labelText: 'Product Description'),
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
                      controller: TextEditingController(text: _auth.currentUser!.email), // Set the controller to the current user's email
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

  signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
      Navigator.popUntil(context, ModalRoute.withName('/'));
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

// ProductList widget definition here
class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('brokerMailId', isEqualTo: user.email)
          .get();

      final List<Product> fetchedProducts = querySnapshot.docs
          .map((doc) => Product.fromDocument(doc))
          .toList();

      setState(() {
        products = fetchedProducts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Products')),
      body: products.isEmpty
          ? Center(
        child: Text('No products found.'),
      )
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.network(product.imageUrl),
            title: Text(product.name),
            subtitle: Text(product.vehicleNumber),
            trailing: Text('\$${product.price.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}