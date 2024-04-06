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
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress?? '';
    _currentAddress = widget.initialAddress;
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
        _currentAddress = address;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve address'),
        ),
      );
    }
  }

  Future<void> _saveAddress() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'address': _addressController.text,
    });
    Navigator.pop(context, _addressController.text);
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
          ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: Text('Get Current Location'),
          ),
          ElevatedButton(
            onPressed: _saveAddress,
            child: Text('Save Address'),
          ),
        ],
      ),
    );
  }
}