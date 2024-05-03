import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  File? _profilePicture;
  String? _profilePictureUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      setState(() {
        _nameController.text = userData?['name'] ?? '';
        _emailController.text = userData?['email'] ?? '';
        _addressController.text = userData?['address'] ?? '';
        _mobileNumberController.text = userData?['mobile_number'] ?? '';
        _profilePictureUrl = userData?['profile_picture_url'];
      });
    }
  }

  Future<void> _getProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
      final Reference storageReference = FirebaseStorage.instance.ref().child('profile_pictures/${FirebaseAuth.instance.currentUser!.uid}');
      await storageReference.putFile(_profilePicture!);
      final String downloadUrl = await storageReference.getDownloadURL();
      setState(() {
        _profilePictureUrl = downloadUrl;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        final userSnapshot = await userDoc.get();

        if (userSnapshot.exists) {
          await userDoc.update({
            'name': _nameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'mobile_number': _mobileNumberController.text,
          });

          if (_profilePictureUrl != null) {
            await userDoc.update({
              'profile_picture_url': _profilePictureUrl,
            });
          }
        } else {
          await userDoc.set({
            'name': _nameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'mobile_number': _mobileNumberController.text,
            'profile_picture_url': _profilePictureUrl,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );
        _loadUserData();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_profilePicture != null)...[
              Image.file(
                _profilePicture!,
                height: 100,
              ),
              SizedBox(height: 8.0),
            ] else if (_profilePictureUrl != null) ...[
              Image.network(
                _profilePictureUrl!,
                height: 100,
              ),
              SizedBox(height: 8.0),
            ],
            ElevatedButton(
              onPressed: _getProfilePicture,
              child: Text('Choose Profile Picture'),
            ),
            SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _mobileNumberController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Save'),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16.0),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}