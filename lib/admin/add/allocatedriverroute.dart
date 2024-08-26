import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../widget.dart';

class AllocateDriverRoute extends StatefulWidget {
  final String routeid;
  const AllocateDriverRoute({Key? key, required this.routeid}) : super(key: key);

  @override
  State<AllocateDriverRoute> createState() => _AllocateDriverRouteState();
}

class _AllocateDriverRouteState extends State<AllocateDriverRoute> {
  String? selectedDriver;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> getUser() async {
    // Fetch all users
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();

    // Fetch all allocated drivers
    QuerySnapshot allocatedDriversSnapshot = await FirebaseFirestore.instance.collection('driverroutes').get();
    Set<String> allocatedDrivers = allocatedDriversSnapshot.docs.map((doc) => doc['email'] as String).toSet();

    List<String> availableDrivers = [];
    for (var doc in userSnapshot.docs) {
      if (!allocatedDrivers.contains(doc['email'])) {
        availableDrivers.add(doc['firstname']);
      }
    }

    return availableDrivers;
  }

  Future<void> addFarm() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDetailsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDetailsSnapshot.docs.isNotEmpty) {
        final documentId = userDetailsSnapshot.docs[0].id;
        final userDetails = userDetailsSnapshot.docs.first.data();
        final email = userDetails['email'];
        final sm = await FirebaseFirestore.instance
            .collection('users')
            .where('firstname', isEqualTo: selectedDriver)
            .get();

        String userid = '';

        if (sm.docs.isNotEmpty) {
          final details = sm.docs.first.data();
          userid = details['email'];
        }

        final user = selectedDriver;
        final routeid = widget.routeid;

        String docId = FirebaseFirestore.instance.collection('driverroutes').doc().id;
        await FirebaseFirestore.instance.collection('driverroutes').doc(docId).set({
          'adminemail': email,
          'email': userid,
          'routeid': routeid,

          'drivername': user,
          'availability': true,
          'id': docId,
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // User details not found dialog...
      }
    } catch (e) {
      print('Error writing farm details to Firestore: $e');
      Navigator.pop(context); // dismiss the progress indicator dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred while saving your farm details. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarr(foodtitle: 'Allocate Driver Route',),
        leading: const LeadingAppBar(),
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: FutureBuilder<List<String>>(
                        future: getUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<String> makes = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedDriver,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDriver = newValue;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select Driver',
                                  ),
                                  items: makes.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: Text('Select Driver'),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SubmitWidget(onPressed: addFarm, title: 'Add Driver Route'),
                    const SizedBox(height: 25,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
