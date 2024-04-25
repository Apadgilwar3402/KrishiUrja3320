//admin side
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/admin_drawer.dart';

class RateConsole1 extends StatefulWidget {
  const RateConsole1({Key? key}) : super(key: key);

  @override
  _RateConsole1State createState() => _RateConsole1State();
}

class _RateConsole1State extends State<RateConsole1> {
  final String _adminUid = 'replace_with_secure_admin_id';
  String _cropName = '';
  String _cropPrice = '0.0';
  String _cityName = ''; // New field for city name
  String _newCropName = ''; // New field for crop name
  String _newCropPrice = '0.0';
  String _newCityName = ''; // New field for city name

  final _formKey = GlobalKey<FormState>();

  String? validateCropName(String? value) {
    if (value != null && value.toLowerCase() != 'rice') {
      return 'Only Rice crop can be added here.';
    }
    return null;
  }

  Future<void> _createRates() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('RiceRates').add({
        'name': _cropName,
        'price': _cropPrice,
        'city': _cityName, // Add the city name field
        'uid': _adminUid,
      });
      _formKey.currentState?.reset();
      setState(() {
        _cropName = '';
        _cropPrice = '';
        _cityName = ''; // Reset the city name field
      });
      Navigator.of(context)
          .pop(); // Close the dialog after successful submission
    }
  }

  Future<void> _updateRates(String ratesId, String newRatesName,
      String newRatesPrice, String newCityName) async {
    await FirebaseFirestore.instance.collection('RiceRates')
        .doc(ratesId)
        .update({
      'name': newRatesName,
      'price': newRatesPrice,
      'city': newCityName, // Update the city name field
    });
  }

  Future<void> _deleteRates(String ratesId) async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this Rates?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('RiceRates')
                      .doc(ratesId)
                      .delete();
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(title: const Text('Rice Rates Console'),
        backgroundColor: Colors.lightGreen[50],),
      drawer: AppDrawer1(user: user, context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('RiceRates')
                    .where('uid', isEqualTo: _adminUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return ListTile(
                        leading: _buildLeavesIcon(),
                        // Use the leaves icon here
                        title: Text(document['name']),
                        subtitle: Text('City: ${document['city']}'),
                        // Display the city name
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                setState(() {
                                  _cropName = document['name'];
                                  _cropPrice = document['price'];
                                  _cityName =
                                  document['city']; // Set the new city name
                                });
                                await showDialog<void>(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: const Text('Update Rates'),
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                initialValue: _cropName,
                                                enabled: false,
                                                // Disable editing of crop name
                                                decoration: const InputDecoration(
                                                  labelText: 'Crop Name',
                                                  hintText: 'Enter Crop name',
                                                ),
                                                onChanged: (value) =>
                                                    setState(() =>
                                                    _newCropName = value),
                                                validator: validateCropName,
                                              ),
                                              TextFormField(
                                                initialValue: _cropPrice,
                                                decoration: const InputDecoration(
                                                  labelText: 'Crop price (per quintal)',
                                                  hintText: 'Enter Crop price',
                                                ),
                                                onChanged: (value) =>
                                                    setState(() =>
                                                    _newCropPrice = value),
                                                validator: (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Please enter a Crop price'
                                                    : null,
                                              ),
                                              TextFormField(
                                                initialValue: _cityName,
                                                decoration: const InputDecoration(
                                                  labelText: 'City Name',
                                                  hintText: 'Enter City name',
                                                ),
                                                onChanged: (value) =>
                                                    setState(() =>
                                                    _newCityName = value),
                                                validator: (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Please enter a City name'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  ?.validate() ?? false) {
                                                await _updateRates(
                                                  document.id,
                                                  _newCropName.isNotEmpty
                                                      ? _newCropName
                                                      : _cropName,
                                                  _newCropPrice,
                                                  _newCityName,
                                                );
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => _deleteRates(document.id),
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) =>
                Center(
                  child: AlertDialog(
                    title: const Text('Add New Crop'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Crop Name',
                              hintText: 'Enter Crop name',
                            ),
                            onChanged: (value) =>
                                setState(() => _cropName = value),
                            validator: validateCropName,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Crop price (per quintal)',
                              hintText: 'Enter Crop price',
                            ),
                            onChanged: (value) =>
                                setState(() => _cropPrice = value),
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter a Crop price'
                                : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'City Name',
                              hintText: 'Enter City name',
                            ),
                            onChanged: (value) =>
                                setState(() => _cityName = value),
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter a City name'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _createRates();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightGreen,
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

}

