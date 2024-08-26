

import 'package:fleetmanagement/admin/add/addfuel.dart';
import 'package:fleetmanagement/admin/add/addservicetype.dart';
import 'package:fleetmanagement/admin/add/addvehicletype.dart';
import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';



import 'package:flutter/foundation.dart' show kIsWeb;

import '../widget.dart';
class VehicleTypes extends StatefulWidget
{


  const VehicleTypes({Key? key,}) : super(key: key);

  @override
  State<VehicleTypes> createState() => _VehicleTypesState();
}

class _VehicleTypesState extends State<VehicleTypes> {
  String searchQuery = '';
  bool isSortingAscending = true;
  TextEditingController _textEditingController = TextEditingController();


  late List<DocumentSnapshot> filteredProducts = []; // Initialize with an empty list


  // Function to toggle sorting order
  void toggleSortOrder() {
    setState(() {
      isSortingAscending = !isSortingAscending;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(

        title:    AppBarr( foodtitle:'Vehicle Types',),
        leading: LeadingAppBar(),
        actions: [

          ActionsWidget(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AddVehicleType(),),);},),

        ],

      ),



      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        controller: _textEditingController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Search...',
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                            });
                            _textEditingController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vehicletypes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                      .where((product) =>
                      product['name'].toLowerCase().contains(searchQuery))
                      .toList();




                  return kIsWeb ? _buildWebGridView(filteredProducts) : _buildMobileGridView(filteredProducts);
                }
              },
            ),
          ),
        ],
      ),

    );
  }
}


Widget _buildWebGridView(List<DocumentSnapshot> filteredProducts) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 2 / 2,
    ),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      DocumentSnapshot product = filteredProducts[index];
      return AdminproductItem(product: product);
    },
  );
}
Widget _buildMobileGridView(List<DocumentSnapshot> filteredProducts) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 6/2,
    ),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      DocumentSnapshot product = filteredProducts[index];
      return AdminproductItem(product: product,);
    },
  );
}

// ... (rest of your code remains unchanged)

class AdminproductItem extends StatelessWidget {
  final DocumentSnapshot product;

  const AdminproductItem({required this.product,});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Delete",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this service type?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on confirmation
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Perform the delete operation
      await FirebaseFirestore.instance.collection('servicetypes').doc(product.id).delete();
      // Show a notification that the season has been deleted
      ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${product['name']} deleted successfully'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      //   onDoubleTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditFarm(farmId: product['id'], ),),);},

      //   onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => FarmDetailScreen(product),),);},


      child:  Container(
        // padding: const EdgeInsets.only(right: 3.0),
        decoration: BoxDecoration(
          //     border: Border.all(width: 1,color: Colors.deepPurple.shade300)
        ),


        child: Column(

          children: [

            Row(

              children: [
                Icon(Icons.bus_alert,color: Colors.orange,),
                Text(
                  'Name: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //     width: 115,
                  child: Text(
                    product['name'] ,
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,   ),
                ),
              ],
            ),




          ],
        ),
      ),
    );
  }
}

























