import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/screens/rent_request.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class RentRequestListScreen extends StatefulWidget {
  @override
  _RentRequestListScreenState createState() => _RentRequestListScreenState();
}

class _RentRequestListScreenState extends State<RentRequestListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<RentRequest> _rentRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchRentRequests();
  }

  Future<void> _fetchRentRequests() async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final rentRequests =
    await _firestoreService.getRentRequests(userID);

    setState(() {
      _rentRequests = rentRequests;
    });
  }

  Future<void> _acceptRentRequest(RentRequest rentRequest) async {
    try {
      // Update the rent request status in Firestore
      await FirebaseFirestore.instance
          .collection('rent_requests')
          .doc(rentRequest.id)
          .update({'status': 'accepted'});

      // Remove the rent request from the list
      setState(() {
        _rentRequests.remove(rentRequest);
      });
    } catch (e) {
      // Handle any errors that occur during the update operation
      print('Error updating rent request status: $e');
    }
  }

  Future<void> _rejectRentRequest(RentRequest rentRequest) async {
    try {
      await FirebaseFirestore.instance
          .collection('rent_requests')
          .doc(rentRequest.id)
          .update({
        'status': 'rejected',
        'rejected_at': Timestamp.now(),
        'rejected_by': FirebaseAuth.instance.currentUser!.uid,
      });

      _fetchRentRequests();
    } catch (e) {
      print('Error updating rent request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broker Console'),
      ),
      body: _rentRequests.isEmpty
          ? Center(
        child: Text('No rent requests yet'),
      )
          : ListView.builder(
        itemCount: _rentRequests.length,
        itemBuilder: (context, index) {
          final rentRequest = _rentRequests[index];
          return ListTile(
            leading: Image.network(
              rentRequest.selectedProducts.first.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              rentRequest.selectedProducts.first.name!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              rentRequest.selectedProducts.first.description!,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _acceptRentRequest(rentRequest),
                  child: Text('Accept'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      _rejectRentRequest(rentRequest),
                  child: Text('Reject'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}