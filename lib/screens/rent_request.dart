import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modernlogintute/models/address_model.dart';

import '../models/item_model.dart';

class RentRequest {
  RentRequest({
    required this.id,
    required this.userId,
    required this.selectedProducts,
    required this.createdAt,
    required this.status,
    Address? address,
    Timestamp? requestedAt, required List<Product> products,
  })  : this.address = address ?? Address(id: '', userId: '', name: '', addressLine1: '', addressLine2: '', city: '', state: '', country: '', postalCode: ''),
        this.requestedAt = requestedAt ?? Timestamp.now();

  final String id;
  final String userId;
  final List<Product> selectedProducts;
  final DateTime createdAt;
  final String status;
  final Address address;
  final Timestamp requestedAt;

  factory RentRequest.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    Address? address;
    Timestamp? requestedAt;

    if (data.containsKey('address')) {
      address = Address.fromJson(data['address']);
    }

    if (data.containsKey('requested_at')) {
      requestedAt = data['requested_at'];
    }

    return RentRequest(
      id: doc.id,
      userId: data['user_id'],
      selectedProducts: (data['selected_products'] as List)
          .map((productData) => Product.fromJson(productData))
          .toList(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      status: data['status'],
      address: address,
      requestedAt: requestedAt, products: [],
    );
  }

  Map<String, dynamic> toJSON() => {
    'id': this.id,
    'userId': this.userId,
    'selected_products': this.selectedProducts.map((p) => p.toJSON()).toList(),
    'created_at': this.createdAt,
    'status': this.status,
  };

  Map<String, dynamic> toJson() {
    //final createdAt = this.createdAt.toDate();
    final requestedAt = this.requestedAt.toDate();

    return {
      'id': this.id,
      'user_id': this.userId,
      'selected_products': this.selectedProducts.map((product) => product.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'status': this.status,
      'address': this.address.toJson(),
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
