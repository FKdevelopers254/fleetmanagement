import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:fleetmanagement/admin/view/singleroutes.dart';
import 'package:fleetmanagement/auth/glassbox.dart';
import 'package:fleetmanagement/user/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../user/routes.dart';
import '../add/addroute.dart';
import '../counters.dart';
import '../widget.dart';

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  String searchQuery = '';
  bool isSortingAscending = true;
  static const Color myAppBarColor = Colors.yellow;
  static const Color myIconColor = Colors.orange;
  static const Color myBorderColor = Colors.orange;

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: AppBarr(foodtitle: 'Routes'),
        leading: SizedBox(),
        actions: [
          ActionsWidget(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRoute(),
                ),
              );
            },
          ),
        ],
      ),
      body: GlassBoxxx(
        child: Column(
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
                stream: FirebaseFirestore.instance.collection('routes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                        .where((product) =>
                        product['start'].toLowerCase().contains(searchQuery))
                        .toList();

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;
                        if (constraints.maxWidth >= 1200) {
                          crossAxisCount = 5;
                        } else if (constraints.maxWidth >= 800) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
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
            "Are you sure you want to delete this route?",
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
      await FirebaseFirestore.instance.collection('routes').doc(product.id).delete();
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
  //    onLongPress: () => _confirmDelete(context),
      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SingleRoutes(routeId: product['id']),),);},
      onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SSingleRoutesMap( routeId: product['id'],),),);},

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: _RoutesState.myBorderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: _RoutesState.myIconColor),
                Text(
                  'Route Name: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 90,
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
                Icon(Icons.start, color: _RoutesState.myIconColor),
                Text(
                  'Start: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: Text(
                    product['start'],
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
                Icon(Icons.pin_end_rounded, color: _RoutesState.myIconColor),
                Text(
                  'End: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 90,
                  child: Text(
                    product['end'],
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
                Icon(Icons.car_repair, color: _RoutesState.myIconColor),
                Text(
                  'Vehicles: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: RouteVehiclesCounter(routeId: product['id']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.car_repair, color: _RoutesState.myIconColor),
                Text(
                  'Drivers: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: RoutesDriverCounter(routeId: product['id']),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.trip_origin, color: _RoutesState.myIconColor),
                Text(
                  'Trips: ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: RouteTripsCounter(routeId: product['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
