import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleetmanagement/admin/add/routeseopoints.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';


import '../widget.dart';

class AddRoute extends StatefulWidget {
  const AddRoute({Key? key}) : super(key: key);
  @override
  State<AddRoute> createState() => _AddRouteState();
}
class _AddRouteState extends State<AddRoute> {

  PermissionStatus _permissionStatus = PermissionStatus.denied;
  final _nameController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  late LatLng startLocation;
  late LatLng endLocation;
  List<LatLng> routePoints = [];

//  late LatLng selectedLocation;

  @override
  void initState() {
    super.initState();
  //  selectedLocation =LatLng(0,0);
    startLocation = LatLng(0, 0);
    endLocation = LatLng(0, 0);
    requestLocationPermission();

  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      // Fetch location when permission is granted
      //   fetchLocation();
    }
  }



  @override
  void dispose(){




    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();





    super.dispose();
  }



  Future<void> addRoute() async {
    if (_nameController.text.isEmpty ||
        _startController.text.isEmpty ||
        _endController.text.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDetailsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDetailsSnapshot.docs.isNotEmpty) {
        final documentId = userDetailsSnapshot.docs[0].id;
        final userDetails = userDetailsSnapshot.docs.first.data();
        final email = userDetails['email'];

        final name = _nameController.text;
        final start = _startController.text;
        final end = _endController.text;
        final startLatitude = startLocation.latitude;
        final startLongitude = startLocation.longitude;
        final endLatitude = endLocation.latitude;
        final endLongitude = endLocation.longitude;
        List<Map<String, dynamic>> geoPoints = routePoints
            .map((point) => {'latitude': point.latitude, 'longitude': point.longitude})
            .toList();
        String docId = FirebaseFirestore.instance.collection('routes').doc().id;
        await FirebaseFirestore.instance.collection('routes').doc(docId).set({
          'adminemail': email,
          'name': name,
          'startLatitude': startLatitude,
          'startLongitude': startLongitude,
          'endLatitude': endLatitude,
          'endLongitude': endLongitude,
          'end': end,
          'start': start,
          'availability': true,
          'id': docId,
          'routePoints': geoPoints,
        });

        // Clear text fields
        _nameController.clear();
        _startController.clear();
        _endController.clear();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // User details not found dialog...
      }
    } catch (e) {
      print('Error writing farm details to Firestore: $e');
      Navigator.pop(context); // dismiss the progress indicator dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred while saving your farm details. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }
  void _selectRoutePoints() async {
    final points = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectRoutePointsPage(),
      ),
    );
    if (points != null && points is List<LatLng>) {
      setState(() {
        routePoints = points;
      });
      print('Selected route points: $points');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarr( foodtitle: 'Add Route',),
        leading: const LeadingAppBar(),
        actions: const [],
        //  leading: SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
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
                            prefixIcon: Icon(Icons.title),
                            hintText: 'Route Name',
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
                          controller: _startController,
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
                            prefixIcon: Icon(Icons.photo_size_select_actual_sharp),
                            hintText: 'Starting Point',
                            labelText: 'Starting Point',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10,),



                    if (startLocation != null && startLocation != LatLng(0, 0))
                      Column(
                        children: [
                          Text('Start Latitude: ${startLocation.latitude}'),
                          Text('Start Longitude: ${startLocation.longitude}'),
                        ],
                      ),

                    if (startLocation == LatLng(0, 0))
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimatedMechanicPage(),
                            ),
                          ).then((value) {
                            if (value != null && value is LatLng) {
                              setState(() {
                                startLocation = value;
                              });
                              print('Selected start location: $value');
                            }
                          });
                        },
                        child: Text('Select Starting Position'),
                      ),
                    const SizedBox(height: 10,),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _endController,
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
                            prefixIcon: Icon(Icons.photo_size_select_actual_sharp),
                            hintText: 'Ending Point',
                            labelText: 'Ending Point',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10,),
                    if (endLocation != null && endLocation != LatLng(0, 0))
                      Column(
                        children: [
                          Text('End Latitude: ${endLocation.latitude}'),
                          Text('End Longitude: ${endLocation.longitude}'),
                        ],
                      ),

                    if (endLocation == LatLng(0, 0))
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimatedMechanicPage(),
                            ),
                          ).then((value) {
                            if (value != null && value is LatLng) {
                              setState(() {
                                endLocation = value;
                              });
                              print('Selected end location: $value');
                            }
                          });
                        },
                        child: Text('Select Ending Position'),
                      ),



                    const SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: _selectRoutePoints,
                      child: Text('Select Route Points'),
                    ),
                    const SizedBox(height: 10,),
                    //AddButton
                    SubmitWidget(onPressed: addRoute, title:  'Add  Route')
                    ,
                    const SizedBox(height: 25,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class AnimatedMechanicPage extends StatefulWidget {
  static const String route = '/map_controller_animated';

  const AnimatedMechanicPage({Key? key}) : super(key: key);

  @override
  AnimatedMechanicPageState createState() => AnimatedMechanicPageState();
}

class AnimatedMechanicPageState extends State<AnimatedMechanicPage>
    with TickerProviderStateMixin {
  final mapController = MapController();
  LatLng? selectedLocation; // Store the selected location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarr(foodtitle: 'Routes'),
        leading: LeadingAppBar(),

      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(-1.5, 36.8),
          // Center map initially
          initialZoom: 6,
          maxZoom: 20,
          minZoom: 3,
          onTap: (tapPosition, latLng) {
            _handleTap(latLng);
          }, // Handle tap on map
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80,
                  height: 80,
                  point: selectedLocation!,
                  child: Draggable(
                    // Make marker draggable
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.blue,
                    ),
                    feedback: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.blue.withOpacity(0.5),
                    ),
                    onDragEnd: (details) {
                      // When drag ends, update selectedLocation
                      final LatLng newPosition = mapController.center;
                      setState(() {
                        selectedLocation = newPosition;
                      });
                      // Save the selected location to Firestore
                      //   _saveLocationToFirestore(selectedLocation!);
                    },
                  ),
                ),

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
      ),
    );
  }


  void _handleTap(LatLng? latlng) {
    if (latlng != null) {
      setState(() {
        selectedLocation = latlng;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Location selected successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context, selectedLocation);
      });
    }
  }

}




class FlutterMapZoomButtons extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;

  static const _fitBoundsPadding = EdgeInsets.all(12);

  const FlutterMapZoomButtons({
    super.key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
  });

  @override
  Widget build(BuildContext context) {
    final controller = MapController.of(context);
    final camera = MapCamera.of(context);
    final theme = Theme.of(context);

    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
            EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: zoomInColor ?? Colors.orange,
              onPressed: () {
                final paddedMapCamera = CameraFit.bounds(
                  bounds: camera.visibleBounds,
                  padding: _fitBoundsPadding,
                ).fit(camera);
                final zoom = min(paddedMapCamera.zoom + 1, maxZoom);
                controller.move(paddedMapCamera.center, zoom);
              },
              child: Icon(zoomInIcon,
                color: zoomInColorIcon ?? Colors.white,size: 30,),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: mini,
              backgroundColor: zoomOutColor ?? Colors.orange,
              onPressed: () {
                final paddedMapCamera = CameraFit.bounds(
                  bounds: camera.visibleBounds,
                  padding: _fitBoundsPadding,
                ).fit(camera);
                var zoom = paddedMapCamera.zoom - 1;
                if (zoom < minZoom) {
                  zoom = minZoom;
                }
                controller.move(paddedMapCamera.center, zoom);
              },
              child: Icon(zoomOutIcon,
                color: zoomOutColorIcon ?? Colors.white,size: 30,),
            ),
          ),
        ],
      ),
    );
  }




}
