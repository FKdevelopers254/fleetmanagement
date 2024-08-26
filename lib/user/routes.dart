



import 'dart:async';

import 'package:fleetmanagement/admin/view/maintainance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fleetmanagement/admin/counters.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../admin/add/addfuel.dart';

import '../admin/widget.dart';

import 'package:fleetmanagement/auth/glassbox.dart';

class AllRoutes extends StatefulWidget
{


  const AllRoutes({Key? key,}) : super(key: key);

  @override
  State<AllRoutes> createState() => _AllRoutesState();
}

class _AllRoutesState extends State<AllRoutes> {
  String searchQuery = '';
  bool isSortingAscending = true;
  static const Color myAppBarColor = Colors.yellow; // Blue color
  static const Color myIconColor = Colors.orange; // Blue color
  static const Color myBorderColor = Colors.orange; // Blue color
  // static const Color myTextColor = Color(0xFF42A5F5); // Blue color

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(

        title:    AppBarr( foodtitle:'Routes',),
        leading: SizedBox(),
        actions: [



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




                    return kIsWeb ? _buildWebGridView(filteredProducts) : _buildMobileGridView(filteredProducts);
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


Widget _buildWebGridView(List<DocumentSnapshot> filteredProducts) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 4.5 / 2,
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
      childAspectRatio: 2.5/2,
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
          content: Text('${product['name']} deleted successfully'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {


    return GestureDetector(
    //  onLongPress: () => _confirmDelete(context),
      //   onDoubleTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditFarm(farmId: product['id'], ),),);},

      //    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SingleRoutesMap( routeId: product['id'],),),);},
      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SingleRoutesMap( routeId: product['id'],),),);},
      onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SSingleRoutesMap( routeId: product['id'],),),);},


      child:  Container(
        // padding: const EdgeInsets.only(right: 3.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1,color: _AllRoutesState.myBorderColor),
            borderRadius: BorderRadius.circular(5)
        ),


        child: Column(

          children: [
            Row(

              children: [
                Icon(Icons.route,color: _AllRoutesState.myIconColor,),
                Text(
                  'Route Name: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 90,
                  child: Text(
                    product['name'],
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,  ),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.start,color: _AllRoutesState.myIconColor,),
                Text(
                  'Start: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //     width: 115,
                  child: Text(
                    product['start'] ,
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,   ),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.pin_end_rounded,color: _AllRoutesState.myIconColor,),
                Text(
                  'End: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 90,
                  child: Text(
                    product['end'],
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,  ),
                ),
              ],
            ),

            Row(

              children: [
                Icon(Icons.car_repair,color: _AllRoutesState.myIconColor,),
                Text(
                  'Vehicles: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //  width: 90,
                  child: RouteVehiclesCounter(routeId: product['id'],),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.car_repair,color: _AllRoutesState.myIconColor,),
                Text(
                  'Drivers: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //  width: 90,
                  child: RoutesDriverCounter(routeId: product['id'],),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.trip_origin,color: _AllRoutesState.myIconColor,),
                Text(
                  'Trips: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //    width: 90,
                  child: RouteTripsCounter(routeId: product['id'],),
                ),
              ],
            ),



          ],
        ),
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







class SSingleRoutesMap extends StatefulWidget {
  static const String route = '/map_controller_animated';
  final String routeId;

  const SSingleRoutesMap({Key? key, required this.routeId}) : super(key: key);

  @override
  SSingleRoutesMapState createState() => SSingleRoutesMapState();
}

class SSingleRoutesMapState extends State<SSingleRoutesMap> with TickerProviderStateMixin {
  final mapController = MapController();
  List<Marker> markers = [];
  List<LatLng> polylinePoints = [];
  int vehicleCount = 0;
  int vehiclesOutOfRouteCount = 0;
  int vehiclesInRouteCount = 0;
  Map<String, double> distancesToNearestRoutePoint = {}; // Store distances to nearest route point

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

      setState(() {
        polylinePoints = routePoints;
      });

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
    final vehicles = FirebaseFirestore.instance.collection('vehicles').where('routeid', isEqualTo: widget.routeId);
    final QuerySnapshot snapshot = await vehicles.get();

    List<Marker> carMarkers = [];
    double tolerance = 50; // Tolerance in meters
    vehicleCount = snapshot.docs.length; // Update vehicle count
    vehiclesOutOfRouteCount = 0; // Reset count
    vehiclesInRouteCount = 0; // Reset count
    distancesToNearestRoutePoint.clear(); // Clear previous distances

    print('Fetched ${snapshot.docs.length} vehicles');

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];
      String plateNumber = doc['regno'];

      LatLng carPosition = LatLng(latitude, longitude);
      bool onRoute = isVehicleOnRoute(carPosition, polylinePoints, tolerance);

      if (onRoute) {
        vehiclesInRouteCount++;
      } else {
        vehiclesOutOfRouteCount++;
        double distanceToNearest = calculateDistanceToNearestRoutePoint(carPosition);
        distancesToNearestRoutePoint[plateNumber] = distanceToNearest;
      }

      carMarkers.add(
        Marker(
          width: 80,
          height: 80,
          point: carPosition,
          child: BlinkingVehicleMarker(
            carPosition: carPosition,
            onRoute: onRoute,
            plateNumber: plateNumber,
          ),
        ),
      );
    }

    print('Total vehicles: $vehicleCount, Vehicles in route: $vehiclesInRouteCount, Vehicles out of route: $vehiclesOutOfRouteCount');

    return carMarkers;
  }

  double calculateDistanceToNearestRoutePoint(LatLng vehiclePosition) {
    double minDistance = double.infinity;
    for (LatLng point in polylinePoints) {
      double distance = Geolocator.distanceBetween(
        vehiclePosition.latitude,
        vehiclePosition.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance / 1000.0; // Convert to kilometers
  }

  bool isVehicleOnRoute(LatLng vehiclePosition, List<LatLng> polylinePoints, double tolerance) {
    for (LatLng point in polylinePoints) {
      double distance = Geolocator.distanceBetween(
        vehiclePosition.latitude,
        vehiclePosition.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance <= tolerance) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
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
                      markers: [
                        // Marker for user's current location
                        Marker(
                          width: 20,
                          height: 20,
                          point: LatLng(userLocation.latitude, userLocation.longitude),
                          child: Container(
                            child: Icon(
                              Icons.my_location,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
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
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Vehicles: $vehicleCount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Vehicles In Route: $vehiclesInRouteCount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    'Vehicles Out of Route: $vehiclesOutOfRouteCount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicles Out of Route Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: distancesToNearestRoutePoint.length,
                    itemBuilder: (context, index) {
                      var plateNumber = distancesToNearestRoutePoint.keys.elementAt(index);
                      var distance = distancesToNearestRoutePoint[plateNumber];
                      return ListTile(
                        title: Text('Plate Number: $plateNumber'),
                        subtitle: Text('Distance to Nearest Route Point: ${distance!.toStringAsFixed(2)} km'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> getUserLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw 'Could not get user location: $e';
    }
  }
}

class BlinkingVehicleMarker extends StatefulWidget {
  final LatLng carPosition;
  final bool onRoute;
  final String plateNumber;

  const BlinkingVehicleMarker({
    Key? key,
    required this.carPosition,
    required this.onRoute,
    required this.plateNumber,
  }) : super(key: key);

  @override
  _BlinkingVehicleMarkerState createState() => _BlinkingVehicleMarkerState();
}

class _BlinkingVehicleMarkerState extends State<BlinkingVehicleMarker> {
  late Timer _timer;
  Color vehicleColor = Colors.green;

  @override
  void initState() {
    super.initState();
    if (!widget.onRoute) {
      _startBlinking();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        vehicleColor = (vehicleColor == Colors.green) ? Colors.red : Colors.green;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                        Text('Plate Number: ${widget.plateNumber}'),
                        Text('Latitude: ${widget.carPosition.latitude}'),
                        Text('Longitude: ${widget.carPosition.longitude}'),
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
              Icons.bus_alert,
              size: 40,
              color: widget.onRoute ? Colors.green : vehicleColor,
            ),
          ),
          // Display marker information here
        ],
      ),
    );
  }
}
