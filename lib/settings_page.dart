import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser;
  String? firstName, lastName, gender, role;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      setState(() {
        firstName = userDoc['firstName'];
        lastName = userDoc['lastName'];
        gender = userDoc['gender'];
        role = userDoc['role'];
      });
    }
  }

  Future<void> _updatePassword(BuildContext context) async {
    String oldPassword = '';
    String newPassword = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Old Password'),
              onChanged: (value) => oldPassword = value,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
              onChanged: (value) => newPassword = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // Re-authenticate the user
                final cred = EmailAuthProvider.credential(
                  email: currentUser!.email!,
                  password: oldPassword,
                );
                await currentUser!.reauthenticateWithCredential(cred);

                // Update password
                await currentUser!.updatePassword(newPassword);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Password updated successfully!'),
                ));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: ${e.toString()}'),
                ));
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePersonalInfo(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Personal Info'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: firstName,
                decoration: InputDecoration(labelText: 'First Name'),
                onSaved: (value) => firstName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your first name' : null,
              ),
              TextFormField(
                initialValue: lastName,
                decoration: InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => lastName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your last name' : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Gender'),
                onChanged: (value) => gender = value,
                validator: (value) =>
                    value == null ? 'Please select your gender' : null,
              ),
              TextFormField(
                initialValue: role,
                decoration: InputDecoration(labelText: 'Role'),
                onSaved: (value) => role = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your role' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (currentUser != null) {
                  await _firestore
                      .collection('users')
                      .doc(currentUser!.uid)
                      .update({
                    'firstName': firstName,
                    'lastName': lastName,
                    'gender': gender,
                    'role': role,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Profile updated successfully!'),
                  ));
                }
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _updatePassword(context),
              icon: Icon(Icons.lock),
              label: Text('Update Password'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _updatePersonalInfo(context),
              icon: Icon(Icons.person),
              label: Text('Update Personal Info'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red, // Red color for logout button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
