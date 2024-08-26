import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../widget.dart';

class AddMaintenance extends StatefulWidget {
  const AddMaintenance({Key? key}) : super(key: key);

  @override
  State<AddMaintenance> createState() => _AddMaintenanceState();
}

class _AddMaintenanceState extends State<AddMaintenance> {

  final _costController = TextEditingController();

  String? selectedVehicle;
  String? selectedServiceType;



  @override
  void initState() {
    super.initState();

  }


  @override
  void dispose() {
    _costController.dispose();

    super.dispose();
  }

  Future<List<String>> getVehicles() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('vehicles').get();
    List<String> routes = [];
    snapshot.docs.forEach((doc) {
      routes.add(doc['name']);
    });
    return routes;
  }

  Future<List<String>> getServiceType() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('servicetypes').get();
    List<String> vehicleTypes = [];
    snapshot.docs.forEach((doc) {
      vehicleTypes.add(doc['name']);
    });
    return vehicleTypes;
  }

  Future<void> addVehicle() async {
    if (_costController.text.isEmpty ) {
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
        final sm = await FirebaseFirestore.instance
            .collection('vehicles')
            .where('name', isEqualTo: selectedVehicle)
            .get();
        final sme = await FirebaseFirestore.instance
            .collection('servicetypes')
            .where('name', isEqualTo: selectedServiceType)
            .get();

        String vehicleid = '';
        String servicetypeid = '';

        if (sm.docs.isNotEmpty) {
          final details = sm.docs.first.data();
          vehicleid = details['id'];
        }
        if (sme.docs.isNotEmpty) {
          final details = sme.docs.first.data();
          servicetypeid = details['id'];
        }

        final cost = _costController.text;
        final vehicle = selectedVehicle;
        final servicetype = selectedServiceType;



        String docId = FirebaseFirestore.instance.collection('maintenance').doc().id;
        await FirebaseFirestore.instance.collection('maintenance').doc(docId).set({
          'adminemail': email,
          'vehiclename': vehicle,
          'vehicleid': vehicleid,
          'servicetype': servicetype,
          'servicetypeid': servicetypeid,
          'cost': cost,
          'ondate': DateTime.now(),


          'availability': true,
          'id': docId,
        });



        _costController.clear();


        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$vehicle added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // User details not found dialog...
      }
    } catch (e) {
      print('Error writing farm details to Firestore: $e');
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarr(foodtitle: 'Add Maintenance',),
        leading: const LeadingAppBar(),
        actions: const [],
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
                    buildDropdownContainer(
                      future: getVehicles(),
                      value: selectedVehicle,
                      hint: 'Select Vehicle',
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehicle = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildDropdownContainer(
                      future: getServiceType(),
                      value: selectedServiceType,
                      hint: 'Select Service Type',
                      onChanged: (newValue) {
                        setState(() {
                          selectedServiceType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildTextField(_costController, 'Cost', Icons.title),
                    const SizedBox(height: 10),



                    const SizedBox(height: 20),
                    SubmitWidget(onPressed: addVehicle, title: 'Add Maintenance'),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildDropdownContainer({
    required Future<List<String>> future,
    required String? value,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 50,
      width: 280,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 231, 235),
        border: Border.all(color: const Color.fromARGB(255, 167, 180, 188)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<List<String>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(hint),
              ),
              isExpanded: true,
              underline: Container(),
              onChanged: onChanged,
              items: snapshot.data!.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(value),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  TextField buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
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
        title: AppBarr(foodtitle: 'Vehicle Location'),
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
              backgroundColor: zoomInColor ?? Colors.green,
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
              backgroundColor: zoomOutColor ?? Colors.green,
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
