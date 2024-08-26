import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';

import '../admin/add/addfuel.dart';
import '../admin/widget.dart';
class RoutesMap extends StatefulWidget {

  static const String route = '/map_controller_animated';
  final String routeId;

  const RoutesMap({Key? key, required this.routeId}) : super(key: key);

  @override
  RoutesMapState createState() => RoutesMapState();
}
class RoutesMapState extends State<RoutesMap>
    with TickerProviderStateMixin {
  final mapController = MapController();
  List<Marker> markers = [];


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
        setState(() {
          markers = mechanicMarkers;
        });
      });
    }
  }

  Future<List<Marker>> getMechanicMarkers(Position userLocation) async {
    final mechanics = FirebaseFirestore.instance.collection('vehicles').where('routeid', isEqualTo: widget.routeId);
    final QuerySnapshot snapshot = await mechanics.get();

    List<Marker> mechanicMarkers = [];
    double minDistance = 180000;

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        latitude,
        longitude,
      );

      mechanicMarkers.add(
        Marker(
          width: 80,
          height: 80,
          point: LatLng(latitude, longitude),
          child:   GestureDetector(
            onLongPress: () {
              // Handle marker tap
              print('Marker tapped: $latitude, $longitude');
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => FarmDetailScreen(doc),),);

              // You can implement logic to show detailed information about the marker
            },


            onTap: () {

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
                    color: distance == minDistance ? Colors.green : Colors.greenAccent,
                  ),
                  tooltip: '${distance.toStringAsFixed(0)} kms',
                ),
                // Display marker information here
              ],
            ),
          ),
        ),
      );

      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return mechanicMarkers;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title:    AppBarr( foodtitle:'Matatus',),
        leading: LeadingAppBar(),
      ),
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
                MarkerLayer(
                //  rotate: true,
                  markers: [
                    // Marker for user's current location
                    Marker(
                   //   rotate: true,
                      width: 40,
                      height:40,
                      point: LatLng(userLocation.latitude, userLocation.longitude),
                      child: Container(
                        child: Icon(
                          Icons.my_location,
                          size: 40,
                          color: Colors.deepPurple,
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
