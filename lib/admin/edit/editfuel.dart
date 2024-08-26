import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widget.dart';



class EditFuel extends StatefulWidget {
  final String pdId;

  const EditFuel({Key? key, required this.pdId}) : super(key: key);

  @override
  State<EditFuel> createState() => _EditFuelState();
}

class _EditFuelState extends State<EditFuel> {

  late TextEditingController _amountController;
  late TextEditingController _litresController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _litresController = TextEditingController();
    _locationController = TextEditingController();
    fetchCropDetails();
  }

  @override
  void dispose() {

    _amountController.dispose();
    _litresController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  Future<void> fetchCropDetails() async {
    try {
      DocumentSnapshot cropSnapshot = await FirebaseFirestore.instance.collection('fuel').doc(widget.pdId).get();
      if (cropSnapshot.exists) {
        setState(() {
          _amountController.text = cropSnapshot['amount'];
          _litresController.text = cropSnapshot['litres'];
          _locationController.text = cropSnapshot['location'];
        });
      }
    } catch (e) {
      print('Error fetching crop details: $e');
    }
  }

  Future<void> updateCrop() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDetailsSnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: user.email).get();

      if (userDetailsSnapshot.docs.isNotEmpty) {
        final documentId = userDetailsSnapshot.docs[0].id;
        final userDetails = userDetailsSnapshot.docs.first.data();
        final email = userDetails['email'];


        final amount = _amountController.text;
        final litres = _litresController.text;
        final location = _locationController.text;

        await FirebaseFirestore.instance.collection('fuel').doc(widget.pdId).update({
          'amount': amount,
          'litres': litres,
          'location': location,
          'ondate': DateTime.now(),

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('  updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating crop details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update crop details. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarr( foodtitle: 'Edit Fuel',),
        leading: const LeadingAppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.monetization_on),
                        hintText: 'Amount',
                        labelText: 'Amount',
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.liquor),
                        hintText: 'Litres',
                        labelText: 'Litres',
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.location_pin),
                        hintText: 'Location',
                        labelText: 'Location',
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SubmitWidget(onPressed: updateCrop, title: 'Update  Fuel'),

                const SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
