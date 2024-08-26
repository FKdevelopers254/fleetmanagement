import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../widget.dart';

class AllocateDriver extends StatefulWidget {
  const AllocateDriver({Key? key}) : super(key: key);
  @override
  State<AllocateDriver> createState() => _AllocateDriverState();
}

class _AllocateDriverState extends State<AllocateDriver> {
  String? selectedDriver;
  String? selectedVehicle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> getUser() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').get();
    List<String> makes = [];
    snapshot.docs.forEach((doc) {
      makes.add(doc['firstname']);
    });
    return makes;
  }

  Future<List<String>> getOffice() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('vehicles').get();
    List<String> offices = [];
    snapshot.docs.forEach((doc) {
      offices.add(doc['name']);
    });
    return offices;
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
        final sme = await FirebaseFirestore.instance
            .collection('vehicles')
            .where('name', isEqualTo: selectedVehicle)
            .get();

        String vehicleid = '';
        String userid = '';

        if (sm.docs.isNotEmpty) {
          final details = sm.docs.first.data();
          userid = details['email'];
        }
        if (sme.docs.isNotEmpty) {
          final details = sme.docs.first.data();
          vehicleid = details['id'];
        }

        // Check if the selected driver is already allocated to another vehicle
        final existingDriverAllocation = await FirebaseFirestore.instance
            .collection('driverallocated')
            .where('email', isEqualTo: userid)
            .get();

        // Check if the selected vehicle is already allocated to another driver
        final existingVehicleAllocation = await FirebaseFirestore.instance
            .collection('driverallocated')
            .where('vehicleid', isEqualTo: vehicleid)
            .get();

        if (existingDriverAllocation.docs.isNotEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Driver is already allocated to another vehicle'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        if (existingVehicleAllocation.docs.isNotEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vehicle is already allocated to another driver'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final user = selectedDriver;
        final vehicle = selectedVehicle;

        String docId =
            FirebaseFirestore.instance.collection('driverallocated').doc().id;
        await FirebaseFirestore.instance
            .collection('driverallocated')
            .doc(docId)
            .set({
          'adminemail': email,
          'email': userid,
          'vehicleid': vehicleid,
          'name': vehicle,
          'drivername': user,
          'availability': true,
          'id': docId,
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Driver allocated successfully'),
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
            content: Text(
                'An error occurred while saving your farm details. Please try again later.'),
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
        title: const AppBarr(
          foodtitle: 'Allocate Driver',
        ),
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
                    const SizedBox(height: 10),
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<String> makes = snapshot.data!;
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25.0),
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
                                  items: makes.map<DropdownMenuItem<String>>(
                                          (String value) {
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
                        future: getOffice(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<String> offices = snapshot.data!;
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedVehicle,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedVehicle = newValue;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select Vehicle',
                                  ),
                                  items: offices.map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  hint: Text('Select Vehicle'),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SubmitWidget(onPressed: addFarm, title: 'Allocate Driver'),
                    const SizedBox(height: 25),
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
