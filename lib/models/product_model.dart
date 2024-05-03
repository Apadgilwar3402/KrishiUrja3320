// product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String vehicleNumber;
  final String brokerId;
  final String? brokerEmail;
  final String? brokerMailId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.vehicleNumber,
    required this.brokerId,
    this.brokerEmail,
    this.brokerMailId,
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
      brokerId: data['brokerId'],
      brokerEmail: data['brokerEmail'],
      brokerMailId: data['brokerMailId'],
    );
  }
}