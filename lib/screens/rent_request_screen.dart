import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/CartScreen.dart';
import 'package:modernlogintute/screens/rent_request.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentRequestScreen extends StatefulWidget {
  final List<Product> selectedProducts;

  RentRequestScreen({required this.selectedProducts, required RentRequest rentRequest});

  @override
  _RentRequestScreenState createState() => _RentRequestScreenState();
}

class _RentRequestScreenState extends State<RentRequestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Request'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selected Products:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedProducts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      widget.selectedProducts[index].imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      widget.selectedProducts[index].name!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      widget.selectedProducts[index].description!,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      '\₹${widget.selectedProducts[index].price}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                // Create a new rent request document in the Firestore
                await _firestoreService.createRentRequest(
                  widget.selectedProducts,
                );

                // Clear the selected products list
                widget.selectedProducts.clear();

                // Navigate back to the CartScreen
                Navigator.pop(context);
              },
              child: Text('Submit Rent Request'),
            ),
          ],
        ),
      ),
    );
  }
}
