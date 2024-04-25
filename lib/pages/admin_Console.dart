//admin scheme side
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/admin_drawer.dart';

class AdminConsole extends StatefulWidget {
  @override
  _AdminConsoleState createState() => _AdminConsoleState();
}

class _AdminConsoleState extends State<AdminConsole> {
  final String _adminUid = 'replace_with_secure_admin_id';

  String _schemeName = '';
  String _schemeDescription = '';
  String _schemeEligibility = '';
  String _newSchemeName = '';
  String _newSchemeDescription = '';
  String _newSchemeEligibility = '';

  final _formKey = GlobalKey<FormState>();

  bool _showCreateSchemeForm = false;

  Future<void> _createScheme() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('schemes').add({
        'name': _schemeName,
        'description': _schemeDescription,
        'eligibility': _schemeEligibility,
        'uid': _adminUid,
      });
      _formKey.currentState?.reset();
      setState(() {
        _schemeName = '';
        _schemeDescription = '';
        _schemeEligibility = '';
        _showCreateSchemeForm = false; // Hide the form after creating scheme
      });
    }
  }

  Future<void> _updateScheme(String schemeId, String newSchemeName, String newSchemeDescription, String newSchemeEligibility) async {
    await FirebaseFirestore.instance.collection('schemes').doc(schemeId).update({
      'name': newSchemeName,
      'description': newSchemeDescription,
      'eligibility': newSchemeEligibility,
    });
  }

  Future<void> _deleteScheme(String schemeId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this scheme?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('schemes').doc(schemeId).delete();
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

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Text('Schemes for Welfare of Farmers'),
        backgroundColor: Colors.lightGreen[50],
      ),
      drawer: AppDrawer1(user: user, context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('schemes')
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
                      return Card(
                        color: Colors.lightGreen.withOpacity(0.7), // Set background color
                        child: ListTile(
                          title: Text(document['name']),
                          subtitle: Text(document['description']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    _newSchemeName = document['name'];
                                    _newSchemeDescription = document['description'];
                                    _newSchemeEligibility = document['eligibility'];
                                  });
                                  await showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Update Scheme'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            initialValue: _newSchemeName,
                                            decoration: const InputDecoration(
                                              labelText: 'Scheme Name',
                                              hintText: 'Enter scheme name',
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _newSchemeName = value),
                                            validator: (value) => value == null ||
                                                value.isEmpty
                                                ? 'Please enter a scheme name'
                                                : null,
                                          ),
                                          TextFormField(
                                            initialValue: _newSchemeDescription,
                                            decoration: const InputDecoration(
                                              labelText: 'Scheme Description',
                                              hintText: 'Enter scheme description',
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _newSchemeDescription = value),
                                            validator: (value) => value == null ||
                                                value.isEmpty
                                                ? 'Please enter a scheme description'
                                                : null,
                                          ),
                                          TextFormField(
                                            initialValue: _newSchemeEligibility,
                                            decoration: const InputDecoration(
                                              labelText: 'Scheme Eligibility',
                                              hintText: 'Enter scheme eligibility',
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _newSchemeEligibility = value),
                                            validator: (value) => value == null ||
                                                value.isEmpty
                                                ? 'Please enter a scheme eligibility'
                                                : null,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await _updateScheme(
                                                  document.id,
                                                  _newSchemeName,
                                                  _newSchemeDescription,
                                                  _newSchemeEligibility);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => _deleteScheme(document.id),
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: SingleChildScrollView(
                  child: AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Scheme Name',
                                hintText: 'Enter scheme name',
                              ),
                              onChanged: (value) => setState(() => _schemeName = value),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter a scheme name'
                                  : null,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Scheme Description',
                                hintText: 'Enter scheme description',
                              ),
                              onChanged: (value) => setState(() => _schemeDescription = value),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter a scheme description'
                                  : null,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Scheme Eligibility',
                                hintText: 'Enter scheme eligibility',
                              ),
                              onChanged: (value) => setState(() => _schemeEligibility = value),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter a scheme eligibility'
                                  : null,
                            ),
                            ElevatedButton(
                              onPressed: _createScheme,
                              child: const Text('Create Scheme'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightGreen.withOpacity(0.7),
      ),
    );
  }
}