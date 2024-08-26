import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:fleetmanagement/admin/view/driverperformance.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../counters.dart';
import '../widget.dart';

class Drivers extends StatefulWidget {
  const Drivers({Key? key}) : super(key: key);

  @override
  State<Drivers> createState() => _DriversState();
}

class _DriversState extends State<Drivers> {
  String searchQuery = '';
  bool isSortingAscending = true;
  TextEditingController _textEditingController = TextEditingController();

  late List<DocumentSnapshot> filteredProducts = [];

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
        title: AppBarr(foodtitle: 'Drivers'),
        leading: SizedBox(),
        actions: [
          ActionsWidget(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllocateDriver(),
              ),
            );
          }),
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
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                      .where((product) => product['firstname'].toLowerCase().contains(searchQuery))
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 5;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3;
                      } else {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 2.0,
                          crossAxisSpacing: 2.0,
                          childAspectRatio: 2.5 / 2,
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
          content: Text(
            "Are you sure you want to delete this driver?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
                Navigator.of(context).pop(true);
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
      await FirebaseFirestore.instance.collection('users').doc(product.id).delete();
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverPerformancePage(driverEmail: product['email']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.orange.shade300)),
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
                      color: Colors.black),
                ),
                Container(
                  child: Text(
                    product['firstname'],
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.orange),
                Text(
                  'Tel: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  width: 90,
                  child: Text(
                    product['phonenumber'],
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.email, color: Colors.orange),
                Text(
                  'Email: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  width: 120,
                  child: Text(
                    product['email'],
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.airplane_ticket, color: Colors.orange),
                Text(
                  'DL: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  width: 110,
                  child: Text(
                    product['dl'],
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.car_repair, color: Colors.orange),
                Text(
                  'Vehicle: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  child: DriversNamesss(avatar: product['email']),
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
                      color: Colors.black),
                ),
                Container(
                  child: DriversRoutess(email: product['email']),
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
                      color: Colors.black),
                ),
                Container(
                  child: DriverTripsCounter(email: product['email']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DriversNamesss extends StatelessWidget {
  final String avatar;
  const DriversNamesss({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverallocated')
          .where('email', isEqualTo: avatar)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('No car yet');
        }

        String name = snapshot.data!.docs[0].get('vehicleid');

        return Column(
          children: [
            VehicleName(email: name),
          ],
        );
      },
    );
  }
}

class VehicleName extends StatelessWidget {
  final String email;

  const VehicleName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('id', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No car found');
        }

        var userData = snapshot.data!.docs[0];
        String name = userData.get('name');

        return Text(
          '$name',
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

class DriversRoutess extends StatelessWidget {
  final String email;
  const DriversRoutess({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverroutes')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('No route yet');
        }

        String name = snapshot.data!.docs[0].get('routeid');

        return Column(
          children: [
            RouteName(email: name),
          ],
        );
      },
    );
  }
}

class RouteName extends StatelessWidget {
  final String email;

  const RouteName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('routes')
          .where('id', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No route found');
        }

        var userData = snapshot.data!.docs[0];
        String name = userData.get('name');

        return Text(
          '$name',
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
