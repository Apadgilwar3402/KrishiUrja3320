//user side
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/app_drawer.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({Key? key}) : super(key: key);

  @override
  _RatesPageState createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wheat Rates')),
      drawer: AppDrawer(user: user), // Add the app drawer here
      body: Column(
        children: [
          GifWidget(), // Add the GIF widget here
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('Rates').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final documents = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final price = document['price'];
                    final formattedPrice = _formatPrice(price);
                    final cropName = document['name'];
                    final cityName = document['city']; // Get the city name from the document
                    return ListTile(
                      leading: _buildLeavesIcon(),
                      title: Text(cropName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('₹ $formattedPrice per quintal'),
                          Text('City: $cityName'), // Display the city name
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(cropName),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Price: ₹ $formattedPrice per quintal'),
                                Text('City: $cityName'), // Display the city name in the dialog
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavesIcon() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset('lib/images/crop.jpg'), // path to leaves image
    );
  }

  String _formatPrice(String price) {
    // Try parsing the price string to a double
    final doublePrice = double.tryParse(price);
    // If parsing is successful, format the price with two decimal places
    if (doublePrice != null) {
      return doublePrice.toStringAsFixed(2);
    } else {
      // If parsing fails, return the original price string
      return price;
    }
  }
}

class GifWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Adjust the height as needed
      child: Center(
        child: Image.asset(
          'lib/images/Animation.gif', // Replace with the path to your GIF file
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}