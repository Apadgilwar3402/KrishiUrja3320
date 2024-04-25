import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressScreen extends StatefulWidget {
  final String? initialAddress;

  const AddressScreen({Key? key, this.initialAddress}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _addressController = TextEditingController();
  String? _selectedAddress;
  List<String> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress ?? '';
    _selectedAddress = widget.initialAddress;
    _fetchSavedAddresses();
  }

  Future<void> _fetchSavedAddresses() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userDoc.data();
    if (userData != null && userData['savedAddresses'] != null) {
      setState(() {
        _savedAddresses = List<String>.from(userData['savedAddresses']);
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final address = '${placemarks[0].thoroughfare}, ${placemarks[0].locality}, ${placemarks[0].postalCode}';
      setState(() {
        _addressController.text = address;
        _selectedAddress = address;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve address'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Address'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
            ),
            onChanged: (value) {
              setState(() {
                _selectedAddress = value;
              });
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedAddress,
            decoration: InputDecoration(
              labelText: 'Saved Addresses',
            ),
            onChanged: (value) {
              setState(() {
                _addressController.text = value!;
                _selectedAddress = value;
              });
            },
            items: _savedAddresses.map((address) {
              return DropdownMenuItem<String>(
                value: address,
                child: Text(address),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: Text('Get Current Location'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedAddress != null) {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                final userData = await userRef.get();
                if (userData != null && userData['savedAddresses'] != null) {
                  final savedAddresses = List<String>.from(userData['savedAddresses']);
                  if (!savedAddresses.contains(_selectedAddress)) {
                    savedAddresses.add(_selectedAddress!);
                    await userRef.update({'savedAddresses': savedAddresses});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address saved successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address already exists'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User data not found'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an address'),
                  ),
                );
              }
              Navigator.pop(context, _selectedAddress);
            },
            child: Text('Save Address'),
          ),
        ],
      ),
    );
  }
}