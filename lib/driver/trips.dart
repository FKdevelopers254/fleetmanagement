import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../admin/libb/widget - Copy.dart';
import 'addtrip.dart';




class DriverTrips extends StatefulWidget {
  const DriverTrips({Key? key}) : super(key: key);

  @override
  State<DriverTrips> createState() => _DriverTripsState();
}

class _DriverTripsState extends State<DriverTrips> {
  final user = FirebaseAuth.instance.currentUser!;
  String searchQuery = '';
  bool isSortingAscending = true;
  TextEditingController _textEditingController = TextEditingController();
  late List<DocumentSnapshot> filteredProducts = [];

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
        title: AppBarr(foodtitle: 'My Trips'),
        leading: SizedBox(),
        actions: [

          ActionsWidget(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TripPage(),),);},),

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
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where('email', isEqualTo: user.email!)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                      .where((product) =>
                      product['email'].toLowerCase().contains(searchQuery))
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1200) {
                        return _buildGridView(filteredProducts, 6);
                      } else if (constraints.maxWidth > 800) {
                        return _buildGridView(filteredProducts, 3);
                      } else {
                        return _buildGridView(filteredProducts, 2);
                      }
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

Widget _buildGridView(List<DocumentSnapshot> filteredProducts, int crossAxisCount) {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 3 / 2,
    ),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      DocumentSnapshot product = filteredProducts[index];
      return AdminproductItem(product: product);
    },
  );
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
            "Are you sure you want to delete this trip?",
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
      await FirebaseFirestore.instance.collection('trips').doc(product.id).delete();
      // Show a notification that the trip has been deleted
      ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${product['name']} deleted successfully'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    String formattedDate = DateFormat('d MMM').format(date);
    String day = formattedDate.split(' ')[0]; // Extract the day part
    String month = formattedDate.split(' ')[1]; // Extract the month part

    // Add suffix for day
    if (day.endsWith('1') && !day.endsWith('11')) {
      day += 'st';
    } else if (day.endsWith('2') && !day.endsWith('12')) {
      day += 'nd';
    } else if (day.endsWith('3') && !day.endsWith('13')) {
      day += 'rd';
    } else {
      day += 'th';
    }

    return '$day $month';
  }

  String _formatDateRange(DateTime start) {
    String formattedStart = _formatDate(start);
    return '$formattedStart';
  }

  String _calculateDuration(Timestamp startTimestamp, Timestamp? endTimestamp) {
    if (endTimestamp == null) {
      return 'Travelling';
    }

    DateTime start = startTimestamp.toDate();
    DateTime end = endTimestamp.toDate();
    Duration duration = end.difference(start);

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    Timestamp startDateTimestamp = product['startTime'];
    DateTime startDate = startDateTimestamp.toDate();
    Timestamp? endDateTimestamp = product['endTime'];

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.orange.shade300),
        ),
        child: Column(
          children: [
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
                Icon(Icons.person, color: Colors.orange),
                Text(
                  'Vehicle Name: ',
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
                Icon(Icons.drive_eta, color: Colors.orange),
                Text(
                  'Driver Name: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  child: DriverName(email: product['email']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.orange),
                Text(
                  'Date: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  width: 120,
                  child: Text(
                    _formatDateRange(startDate),
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 14, color: Colors.black),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.timelapse_sharp, color: Colors.orange),
                Text(
                  'Duration: ',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  width: 120,
                  child: Text(
                    _calculateDuration(
                        startDateTimestamp, endDateTimestamp),
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          return const Text('No office yet');
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
          return const Text('No user data found');
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
          return const Text('No office yet');
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
          return const Text('No user data found');
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