import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:fleetmanagement/admin/view/drivers.dart';
import 'package:fleetmanagement/admin/view/vehiclesdetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../add/addvehicle.dart';
import '../counters.dart';
import '../widget.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({Key? key}) : super(key: key);

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
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
        title: const AppBarr(foodtitle: 'Vehicles'),
        leading: SizedBox(),
        actions: [
          ActionsWidget(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehicle(),
                ),
              );
            },
          ),
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
              stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      if (constraints.maxWidth >= 1200) {
                        crossAxisCount = 7;
                      } else if (constraints.maxWidth >= 800) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth >= 600) {
                        crossAxisCount = 3;
                      } else {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
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
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminproductItem extends StatelessWidget {
  final DocumentSnapshot product;

  const AdminproductItem({required this.product});

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
          content: Text("Are you sure you want to delete this vehicle?",
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
      await FirebaseFirestore.instance.collection('vehicles').doc(product.id).delete();
      // Show a notification that the vehicle has been deleted
      ScaffoldMessenger.of(context).showSnackBar(
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.orange.shade300),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange),
                Text(
                  'Name: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: Text(
                    product['name'],
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.confirmation_number_outlined, color: Colors.orange),
                Text(
                  'Reg No: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 90,
                  child: Text(
                    product['regno'],
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.filter_alt_outlined, color: Colors.orange),
                Text(
                  'Fuel Type: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 110,
                  child: Text(
                    product['fueltype'],
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.car_repair, color: Colors.orange),
                Text(
                  'Odometer: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 110,
                  child: Text(
                    product['odometer'],
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.route, color: Colors.orange),
                Text(
                  'Route Name: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 105,
                  child: RouteName(email: product['routeid']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_pin, color: Colors.orange),
                Text(
                  'Location: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 105,
                  child: Text(
                    product['location'],
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange),
                Text(
                  'Driver Name: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: DriversNamess(avatar: product['id']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.trip_origin, color: Colors.orange),
                Text(
                  'Trips: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: VehiclesTripsCounter(vehicleId: product['id']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.orange),
                Text(
                  'Fuel: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: VehiclesFuelCounter(vehicleId: product['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DriversNamess extends StatelessWidget {
  final String avatar;
  const DriversNamess({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverallocated')
          .where('vehicleid', isEqualTo: avatar)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('No driver yet');
        }

        String name = snapshot.data!.docs[0].get('email');

        return Column(
          children: [
            DriverName(email: name),
          ],
        );
      },
    );
  }
}

class DriverName extends StatelessWidget {
  final String email;

  const DriverName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No user data found');
        }

        var userData = snapshot.data!.docs[0];
        String name = userData.get('firstname');
        String lastname = userData.get('lastname');

        return Text(
          '$name $lastname',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }
}
