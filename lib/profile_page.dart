import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileCard(
                  icon: Icons.person,
                  title: 'Full Name',
                  value:
                      '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}',
                ),
                _buildProfileCard(
                  icon: Icons.male,
                  title: 'Gender',
                  value: userData!['gender'] ?? 'N/A',
                ),
                _buildProfileCard(
                  icon: Icons.person_pin,
                  title: 'Role',
                  value: userData!['role'] ?? 'N/A',
                ),
                _buildProfileCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: userData!['email'] ?? 'N/A',
                ),
                _buildProfileCard(
                  icon: Icons.calendar_today,
                  title: 'Registration Date',
                  value: formatTimestamp(userData!['registrationDate']),
                ),
              ],
            ),
    );
  }

  // Helper widget to create profile cards
  Widget _buildProfileCard(
      {required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  // Helper function to format Firestore timestamps
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
