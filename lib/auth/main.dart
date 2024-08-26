import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/view/dashboard.dart';
import '../driver/dashboard.dart';
import 'authpage.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return UserChooser();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}

class UserChooser extends StatefulWidget {
  const UserChooser({super.key});

  @override
  State<UserChooser> createState() => _UserChooserState();
}

class _UserChooserState extends State<UserChooser> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // User is not an admin, show driver dashboard
          return FleetDriverDashboard();
        } else {
          // User is an admin, show admin dashboard
          return FleetManagementDashboard();
        }
      },
    );
  }
}
