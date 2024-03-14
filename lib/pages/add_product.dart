import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
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

    // Check if the vehicle number already exists in the database
    final querySnapshot = await _firestore.collection('products').where('vehicleNumber',isEqualTo: vehicleNumber).get();
    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A product with this vehicle number already exists.'),
        ),
      );
      return;
    }

    // Rest of the addProduct() function logic

    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image for the product.'),
        ),
      );
      return;
    }

    final productId = FirebaseFirestore.instance.collection('products').doc().id;
    final imageUrl = await uploadProductImage(pickedImage!, productId);

    await FirebaseFirestore.instance.collection('products').doc(productId).set({
      'name': productNameController.text,
      'description': productDescriptionController.text,
      'price': double.parse(productPriceController.text),
      'imageUrl':imageUrl,
      'vehicleNumber': vehicleNumber,
    });

    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    vehicleNumberController.clear();
    setState(() {
      pickedImage = null;
    });

    // Navigate back to the ProductListPage
    Navigator.pop(context, true);
    Navigator.pop(context);
  }

  Future<String> uploadProductImage(File imageFile, String productId) async {
    final storageRef = FirebaseStorage.instance.ref().child('products/$productId');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          pickedImage != null
              ? Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Image.file(
              pickedImage!,
              fit: BoxFit.cover,
            ),
          )
              : IconButton(
            onPressed: () async {
              final picked = await pickImage(ImageSource.gallery);
              if (picked != null) {
                setState(() {
                  pickedImage = picked;
                });
              }
            },
            icon: Icon(Icons.camera_alt),
          ),
          TextField(
            controller: productNameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
            ),
          ),
          TextField(
            controller: productDescriptionController,
            decoration: InputDecoration(
              labelText: 'Product Description',
            ),
          ),
          TextField(
            controller: productPriceController,
            decoration: InputDecoration(
              labelText: 'Product Price',
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: vehicleNumberController,
            decoration: InputDecoration(
              labelText: 'Vehicle Number',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading symbol
              setState(() {
                isLoading = true;
              });
              // Add product
              await addProduct();
              // Hide loading symbol
              setState(() {
                isLoading = false;
              });
              // Navigate back to the Renting page
              Navigator.pop(context, true);
            },
            child: isLoading
                ? CircularProgressIndicator()
                : Text('Add Product'),
          ),
        ],
      ),
    );
  }
}