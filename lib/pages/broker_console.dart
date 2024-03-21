import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  final String? productId;
  final String? vehicleNumber;
  final String? name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? currentUserId;

  const AddProductPage({
    super.key,
    this.productId,
    this.vehicleNumber,
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    required this.currentUserId,
  });

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? pickedImage;
  bool isLoading = false;
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
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
    final storageRef =FirebaseStorage.instance.ref().child(
        'products/$productId');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> addProduct() async {
    final vehicleNumber = vehicleNumberController.text.trim();
    if (vehicleNumber.isEmpty || vehicleNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid vehicle number.'),
      ));
      return;
    }

    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please pick an image for the product.'),
      ));
      return;
    }

    final querySnapshot = await _firestore.collection('products').where(
        'vehicleNumber', isEqualTo: vehicleNumber).get();
    if (querySnapshot.docs.isNotEmpty && widget.productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('A product with this vehicle number already exists.'),
      ));
      return;
    }

    final productId = widget.productId ?? FirebaseFirestore.instance
        .collection('products')
        .doc()
        .id;
    final imageUrl = await uploadProductImage(pickedImage!, productId);

    await FirebaseFirestore.instance.collection('products').doc(productId).set({
      'name': productNameController.text,
      'description': productDescriptionController.text,
      'price': double.parse(productPriceController.text),
      'imageUrl': imageUrl,
      'vehicleNumber': vehicleNumber,
      'userId': widget.currentUserId,
    });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Product added successfully.'),
    ));

    final userProducts = await _firestore
        .collection('products')
        .where('userId', isEqualTo: widget.currentUserId)
        .get();

    setState(() {
      _products = userProducts.docs;
    });
  }

  Future<void> updateProduct() async {
    final vehicleNumber = vehicleNumberController.text.trim();
    if (vehicleNumber.isEmpty || vehicleNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid vehicle number.'),
      ));
      return;
    }

    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please pick an image for the product.'),
      ));
      return;
    }

    final querySnapshot = await _firestore.collection('products').where(
        'vehicleNumber', isEqualTo: vehicleNumber).get();
    if (querySnapshot.docs.isNotEmpty && widget.productId != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('A product with this vehicle number already exists.'),
      ));
      return;
    }

    final imageUrl = await uploadProductImage(pickedImage!, widget.productId!);

    await FirebaseFirestore.instance.collection('products').doc(
        widget.productId).update({
      'name': productNameController.text,
      'description': productDescriptionController.text,
      'price': double.parse(productPriceController.text),
      'imageUrl': imageUrl,
      'vehicleNumber': vehicleNumber,
      'userId': widget.currentUserId,
    });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Product updated successfully.'),
    ));

    final userProducts = await _firestore
        .collection('products')
        .where('userId', isEqualTo: widget.currentUserId)
        .get();

    setState(() {
      _products = userProducts.docs;
    });
  }

  Future<void> deleteProduct() async {
    await FirebaseFirestore.instance.collection('products').doc(
        widget.productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Product deleted successfully.'),
    ));

    final userProducts = await _firestore
        .collection('products')
        .where('userId', isEqualTo: widget.currentUserId)
        .get();

    setState(() {
      _products = userProducts.docs;
    });
  }

  List<QueryDocumentSnapshot>? _products;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      productNameController.text = widget.name ?? '';
      productDescriptionController.text = widget.description ?? '';
      productPriceController.text = widget.price?.toString() ?? '';
      vehicleNumberController.text = widget.vehicleNumber ?? '';
    }

    _getUserProducts();
  }

  Future<void> _getUserProducts() async {
    final userProducts = await _firestore
        .collection('products')
        .where('userId', isEqualTo: widget.currentUserId)
        .get();

    setState(() {
      _products = userProducts.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product'),),
      body: Column(
        children: [
          // ... (existing code)

// Display rent requests
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.currentUserId)
                .collection('rentRequests')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final rentRequest = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Renter: ${rentRequest['renterName']}'),
                      subtitle: Text('Address: ${rentRequest['renterAddress']}'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          // Handle rent request acceptance or rejection
                          // ...
                        },
                        child: Text('Accept'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}