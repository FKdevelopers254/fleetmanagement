

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:intl/intl.dart';

import '../widget.dart';








class AddVehicleType extends StatefulWidget {

  const AddVehicleType({Key? key}) : super(key: key);

  @override
  State<AddVehicleType> createState() => _AddVehicleTypeState();
}

class _AddVehicleTypeState extends State<AddVehicleType> {



  final _nameController = TextEditingController();









  @override
  void dispose(){



    _nameController.dispose();




    super.dispose();
  }



  Future<void> addHotel() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final user = FirebaseAuth.instance.currentUser!;
    print(user.email);
    final userDetailsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (userDetailsSnapshot.docs.isNotEmpty) {
      final documentId = userDetailsSnapshot.docs[0].id;
      final userDetails = userDetailsSnapshot.docs.first.data();
      final email = userDetails['email'];



      final name = _nameController.text;

      print('User details found: ${userDetails.toString()}');

      try {
        String docId = FirebaseFirestore.instance.collection('vehicletypes').doc().id;
        await FirebaseFirestore.instance.collection('vehicletypes').doc(docId).set({


          'name': name,





          'availability': true,


          'id': docId


        });

        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Column(
                children: [
                  //     Lottie.asset('lib/images/90690-shopping.json'),
                  Text('Success'),
                ],
              ),
              content: Text(name + 'has been saved'),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context); Navigator.pop(context);},

                  // onPressed: () {  },
                  child: Text('OK'),
                  // onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PointPages())),
                ),
              ],
            );
          },
        );// dismiss the progress indicator dialog
      } catch (e) {
        print('Error writing Events details to Firestore: $e');
        Navigator.pop(context); // dismiss the progress indicator dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while saving your car details. Please try again later.'),
              actions: [
                TextButton(
                    child: Text('OK'),
                    onPressed: () { Navigator.pop(context); Navigator.pop(context);}
                  //  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      }
    } else {
      // handle the case where the user details document doesn't exist
      Navigator.pop(context); // dismiss the progress indicator dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('User Details Not Found'),
            content: Text('We could not find your user details. Please try again later.'),
            actions: [
              TextButton(
                  child: Text('OK'),
                  onPressed: () { Navigator.pop(context); Navigator.pop(context);}
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: const BoxDecoration(color: Colors.white,
        //   borderRadius: BorderRadius.circular(30),
        //  image: DecorationImage(image: AssetImage('lib/images/shop.png'), fit: BoxFit.cover,)
      ),
      child:
      Scaffold(
        appBar: AppBar(
          title: AppBarr(foodtitle: 'Add Vehicle Type',),
          leading: LeadingAppBar(),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [




                const SizedBox(height: 20),

                // Dropdown menu to select car model based on selected make

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
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
                        prefixIcon: Icon(Icons.car_repair_sharp),
                        hintText: 'Vehicle Type Name',
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),



                const SizedBox(height: 10,),
                SubmitWidget(onPressed: addHotel, title: 'Add  Vehicle Type Name'),

//AddButton

                const SizedBox(height: 25,),


              ],
            ),
          ),
        ),
      ),

    );
  }
}