import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/services/success.dart';

import '../models/address_model.dart';
import '../models/item_model.dart';
import '../screens/Failure.dart';
import '../screens/Result.dart';
import '../screens/rent_request.dart';

class FirestoreService {
  final String? uid;

  FirestoreService({
    this.uid,
  });

  final CollectionReference _rentRequests =
  FirebaseFirestore.instance.collection('rent_requests');

  Future<void> createRentRequest(
      List<Product> selectedProducts,
      ) async {
    final rentRequestRef =
    _rentRequests.doc(FirebaseAuth.instance.currentUser!.uid);

    await rentRequestRef.set({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'productIds':
      selectedProducts.map((product) => product.id).toList(),
      'status': 'pending',
    });
  }

  Future<List<RentRequest>> getRentRequests(String userID) async {
    final queries =
    _rentRequests.where('userId', isEqualTo: userID).get();

    final rentRequests =
    (await queries).docs.map((doc) => RentRequest.fromDocumentSnapshot(doc)).toList();

    return rentRequests;
  }

  Future<void> updateRentRequestStatus(
      String rentRequestId,
      String status,
      ) async {
    await _rentRequests.doc(rentRequestId).update({
      'status': status,
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object> addAddress(Address address) async {
  try {
  await _firestore.collection('addresses').add(address.toMap());
  return Success('Address added successfully');
  } catch (e) {
  return Failure('Failed to add address: $e');
  }
  }

  Future<Object> updateAddress(String addressId, Address address) async {
  try {
  await _firestore.collection('addresses').doc(addressId).update(address.toMap());
  return Success('Address updated successfully');
  } catch (e) {
  return Failure('Failed to update address: $e');
  }
  }
}