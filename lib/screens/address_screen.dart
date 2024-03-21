import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/address_model.dart'; // Make sure to import the `Address` class from your `address_model.dart`.
import '../services/firestore_service.dart';
import '../services/success.dart';

class AddressScreen extends StatefulWidget {
  final Address? address;

  AddressScreen({required this.address});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String? _name;
  String? _addressLine1;
  String? _addressLine2;
  String? _city;
  String? _state;
  String? _country;
  String? _postalCode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      _name = widget.address!.name;
      _addressLine1 = widget.address!.addressLine1;
      _addressLine2 = widget.address!.addressLine2;
      _city = widget.address!.city;
      _state = widget.address!.state;
      _country = widget.address!.country;
      _postalCode = widget.address!.postalCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                onSaved: (value) => _name = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'Name cannot be empty',
              ),
              TextFormField(
                initialValue: _addressLine1,
                decoration: InputDecoration(
                  labelText: 'Address line 1',
                ),
                onSaved: (value) => _addressLine1 = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'Address line 1 cannot be empty',
              ),
              TextFormField(
                initialValue: _addressLine2,
                decoration: InputDecoration(
                  labelText: 'Address line 2 (optional)',
                ),
                onSaved: (value) => _addressLine2 = value,
              ),
              TextFormField(
                initialValue: _city,
                decoration: InputDecoration(
                  labelText: 'City',
                ),
                onSaved: (value) => _city = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'City cannot be empty',
              ),
              TextFormField(
                initialValue: _state,
                decoration: InputDecoration(
                  labelText: 'State',
                ),
                onSaved: (value) => _state = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'State cannot be empty',
              ),
              TextFormField(
                initialValue: _country,
                decoration: InputDecoration(
                  labelText: 'Country',
                ),
                onSaved: (value) => _country = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'Country cannot be empty',
              ),
              TextFormField(
                initialValue: _postalCode,
                decoration: InputDecoration(
                  labelText: 'Zip Code',
                ),
                onSaved: (value) => _postalCode = value,
                validator: (value) =>
                value!.isNotEmpty ? null : 'Zip Code cannot be empty',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        Address address = Address(
                          id: widget.address!.id,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          name: _name!,
                          addressLine1: _addressLine1!,
                          addressLine2: _addressLine2 ?? '',
                          city: _city!,
                          state: _state!,
                          country: _country!,
                          postalCode: _postalCode!,
                        );

                        setState(() {
                          _isLoading = true;
                        });

                        if (widget.address == null) {
                          final result =
                          await _firestoreService.addAddress(address);

                          if (result is Success) {
                            Navigator.pop(context);
                          } else {
                            _scaffoldKey.currentState!.showSnackBar(
                              SnackBar(
                                content: Text('Failed to add address'),
                                backgroundColor: Colors.red,
                              ),
                            );

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          final result =
                          await _firestoreService.updateAddress(
                              widget.address!.id!, address);

                          if (result is Success) {
                            Navigator.pop(context);
                          } else {
                            _scaffoldKey.currentState!.showSnackBar(
                              SnackBar(
                                content: Text('Failed to update address'),
                                backgroundColor: Colors.red,
                              ),
                            );

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
                    },
                    child: Text(
                      widget.address == null ? 'Save' : 'Update',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}