//rate console
// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RateConsole extends StatefulWidget {
  const RateConsole({super.key});

  @override
  _RateConsoleState createState() => _RateConsoleState();
}

class _RateConsoleState extends State<RateConsole> {
  // Use a secure authentication mechanism to identify the admin
  // (e.g., Firebase Authentication with secure user management)
  final String _adminUid = 'replace_with_secure_admin_id';

  String _CropName = '';
  String _CropPrice = '0.0';
  String _newCropName = '';
  String _newCropPrice = '0.0';

  final _formKey = GlobalKey<FormState>();

  Future<void> _createRates() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('Rates').add({
        'name': _CropName,
        'price': _CropPrice,
        'uid': _adminUid, // Use the secure admin ID
      });
      _formKey.currentState?.reset();
      setState(() {
        _CropName = '';
        _CropPrice = '';

      });
    }
  }

  Future<void> _updateRates(String RatesId, String newRatesName, String newRatesprice, ) async {
    await FirebaseFirestore.instance.collection('sRates').doc(RatesId).update({
      'name': newRatesName,
      'price': newRatesprice,
    });
  }

  Future<void> _deleteRates(String RatesId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Rates?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('Rates').doc(RatesId).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // Add your logout logic here, such as calling Firebase Auth's signOut method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rates Console')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              child: Text('Rates Console'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  hintText: 'Enter Crop name',
                ),
                onChanged: (value) => setState(() => _CropName = value),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a Crop name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Crop price',
                  hintText: 'Enter Crop price',
                ),
                onChanged:(value) => setState(() => _CropPrice = value),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a Crop price' : null,
              ),
              ElevatedButton(
                onPressed: _createRates,
                child: const Text('Create Crop'),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Rates')
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
                          title: Text(document['name']),
                          //subtitle: Text(document['price']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _newCropName = document['name'];
                                    _newCropPrice = document['price'];

                                  });
                                  await showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Update Rates'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            initialValue: _newCropName,
                                            decoration: const InputDecoration(
                                              labelText: 'Crop Name',
                                              hintText: 'Enter Crop name',
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _newCropName = value),
                                            validator: (value) => value == null ||
                                                value.isEmpty
                                                ? 'Please enter a Crop name'
                                                : null,
                                          ),
                                          TextFormField(
                                            initialValue: _newCropPrice,
                                            decoration: const InputDecoration(
                                              labelText: 'Crop price',
                                              hintText: 'Enter Crop price',
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _newCropPrice = value),
                                            validator: (value) => value == null ||
                                                value.isEmpty
                                                ? 'Please enter a Crop price'
                                                : null,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),                                            ),
                                        TextButton(
                                          onPressed: () async {
                                            await _updateRates(
                                                document.id,
                                                _newCropName,
                                                _newCropPrice);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Update'),
                              ),
                              ElevatedButton(
                                onPressed: () => _deleteRates(document.id),
                                child: const Text('Delete'),
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
      ),
    );
  }
}