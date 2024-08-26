



import 'package:fleetmanagement/admin/view/maintainance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:fleetmanagement/admin/add/allocatedriverroute.dart';
import 'package:fleetmanagement/admin/counters.dart';
import 'package:fleetmanagement/admin/view/drivers.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';



import 'package:flutter/foundation.dart' show kIsWeb;

import '../add/addroute.dart';
import '../widget.dart';
class SingleRoutes extends StatefulWidget

{
  final String routeId;

  const SingleRoutes({Key? key, required this.routeId,}) : super(key: key);

  @override
  State<SingleRoutes> createState() => _SingleRoutesState();
}

class _SingleRoutesState extends State<SingleRoutes> {
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

        title:    AppBarr( foodtitle:'Route Details',),
        leading: LeadingAppBar(),
        actions: [

          ActionsWidget(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AllocateDriverRoute(routeid: widget.routeId),),);},),

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
              stream: FirebaseFirestore.instance.collection('vehicles').where('routeid' , isEqualTo: widget.routeId ).snapshots(),
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
          Expanded(
            flex: 2,
            child: SingleRoutesMap(routeId: widget.routeId),
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
      childAspectRatio: 4/2,
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
            "Are you sure you want to delete this route?",
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
      await FirebaseFirestore.instance.collection('routes').doc(product.id).delete();
      // Show a notification that the season has been deleted
      ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${product['routename']} deleted successfully'),
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


      child:  Row(
        children: [
          Container(
            // padding: const EdgeInsets.only(right: 3.0),



            child: Column(

              children: [



                Row(

                  children: [
                    Icon(Icons.car_repair,color: Colors.orange,),
                    Text(
                      'Vehicle: ',
                      style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Container(
                      width: 90,
                      child: Text(product['name'], style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ],
                ),
                Row(

                  children: [
                    Icon(Icons.route,color: Colors.orange,),
                    Text(
                      'Driver: ',
                      style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Container(
                      width: 90,
                      child: DriversNamesss(avatar: product['id'],),
                    ),
                  ],
                ),

                Row(

                  children: [
                    Icon(Icons.trip_origin,color: Colors.orange,),
                    Text(
                      'Trips: ',
                      style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Container(
                      width: 90,
                      child: RouteTripsCounter(routeId: product['id'],),
                    ),
                  ],
                ),



              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SingleRoutesMap extends StatefulWidget {

  static const String route = '/map_controller_animated';
  final String routeId;

  const SingleRoutesMap({Key? key, required this.routeId}) : super(key: key);

  @override
  SingleRoutesMapState createState() => SingleRoutesMapState();
}
class SingleRoutesMapState extends State<SingleRoutesMap>
    with TickerProviderStateMixin {
  final mapController = MapController();
  List<Marker> markers = [];
  List<LatLng> polylinePoints = [];
  double radiusInMeters = 50000; // Example radius in meters


  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
  }


  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Permissions are still denied
        setState(() {
          // Handle permission denied case
        });
        return;
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      getUserLocation().then((Position userLocation) async {
        List<Marker> mechanicMarkers = await getMechanicMarkers(userLocation);
        List<Marker> carMarkers = await getCarMarkers(userLocation);
        setState(() {
          markers = mechanicMarkers + carMarkers;
        });
      });
    }
  }


  Future<List<Marker>> getMechanicMarkers(Position userLocation) async {
    final mechanics = FirebaseFirestore.instance.collection('routes').where('id', isEqualTo: widget.routeId);
    final QuerySnapshot snapshot = await mechanics.get();

    List<Marker> mechanicMarkers = [];
    double minDistance = double.infinity;

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      double startLatitude = doc['startLatitude'];
      double startLongitude = doc['startLongitude'];
      double endLongitude = doc['endLongitude'];
      double endLatitude = doc['endLatitude'];
      List<dynamic> routePointsData = doc['routePoints'] ?? [];

      List<LatLng> routePoints = routePointsData.map((point) {
        return LatLng(point['latitude'], point['longitude']);
      }).toList();

      // Add start and end points to the route points list
      routePoints.insert(0, LatLng(startLatitude, startLongitude));
      routePoints.add(LatLng(endLatitude, endLongitude));

      double totalDistance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );

      // Create markers for all route points
      for (LatLng point in routePoints) {
        mechanicMarkers.add(
          Marker(
            width: 80,
            height: 80,
            point: point,
            child: GestureDetector(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Route Point'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Latitude: ${point.latitude}'),
                                Text('Longitude: ${point.longitude}'),
                                // Add more details as needed
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.location_on,
                      size: 40,
                      color: totalDistance == minDistance ? Colors.orange : Colors.orangeAccent,
                    ),
                    tooltip: 'Distance: ${totalDistance.toStringAsFixed(0)} kms',
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (totalDistance < minDistance) {
        minDistance = totalDistance;
      }
    }

    return mechanicMarkers;
  }


  Future<List<Marker>> getCarMarkers(Position userLocation) async {
    final mechanics = FirebaseFirestore.instance.collection('vehicles').where('routeid', isEqualTo: widget.routeId);
    final QuerySnapshot snapshot = await mechanics.get();

    List<Marker> carMarkers = [];
    double minDistance = 0;

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];



      carMarkers.add(
        Marker(
          width: 80,
          height: 80,
          point: LatLng(latitude, longitude),
          child:   GestureDetector(

            child: Column(
              children: [
                IconButton(

                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Current Location'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Text('Humidity: 45%'),
                              // Add more weather details as needed
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.bus_alert,
                    size: 40,
                    color:  Colors.green,
                  ),

                ),
                // Display marker information here
              ],
            ),
          ),
        ),

      );



    }

    return carMarkers;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder(
        future: getUserLocation(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Position userLocation = snapshot.data!;
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(userLocation.latitude, userLocation.longitude),
                //   initialCenter: LatLng(-1.5, 36.8),
                initialZoom: 8, // Default zoom level
                maxZoom: 10,
                minZoom: 3,
              ),
              children: [

                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),

                MarkerLayer(
                  //  rotate: true,
                  markers: [
                    // Marker for user's current location
                    Marker(
                      //   rotate: true,
                      width: 20,
                      height:20,
                      point: LatLng(userLocation.latitude, userLocation.longitude),
                      child: Container(
                        child: Icon(
                          Icons.my_location,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    // Mechanics markers
                    ...markers,
                  ],
                ),
                FlutterMapZoomButtons(
                  minZoom: 4,
                  maxZoom: 50,
                  mini: true,
                  padding: 10,
                  alignment: Alignment.bottomRight,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}



Future<Position> getUserLocation() async {
  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      forceAndroidLocationManager: true,
    );
  } catch (e) {
    print('Error getting user location: $e');
    throw e;
  }
}

Future<LocationPermission> getP() async {
  return await Geolocator.checkPermission(
  );
}








class DriversNamesss extends StatelessWidget {
  final String avatar;
  const DriversNamesss({required this.avatar});

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
          return const Text('No car yet');
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


