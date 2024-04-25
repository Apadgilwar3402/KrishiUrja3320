import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String vehicleNumber;
  String userId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.vehicleNumber,
    required this.userId, required String ownerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      vehicleNumber: json['vehicleNumber'],
      userId: json['userId'], ownerId: '',
    );
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      price: doc['price'].toDouble(),
      imageUrl: doc['imageUrl'],
      vehicleNumber: doc['vehicleNumber'],
      userId: doc['userId'], ownerId: '',
    );
  }
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      price: data['price'], vehicleNumber: data['vehicleNumber'], userId: data['userId'], ownerId: data['ownerId'],
    );
  }

  Map<String, dynamic> toMap() {
  return {
  'id': id,
  'name': name,
  'description': description,
  'image_url': imageUrl,
  'price': price,
  };
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'vehicleNumber': vehicleNumber,

    };
  }

  Map<String, dynamic> toJSON() => {
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'vehicleNumber': vehicleNumber,
  };
}