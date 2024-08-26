import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../admin/libb/widget - Copy.dart';

class TripPage extends StatefulWidget {
  const TripPage({Key? key}) : super(key: key);

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool isTripStarted = false;
  bool isAtStartLocation = false;
  bool isAtEndLocation = false;
  Map<String, dynamic>? selectedRoute;
  Position? currentPosition;
  Position? previousPosition;
  String? tripId;
  late String userEmail;
  double distanceCovered = 0.0;
  double remainingDistance = 0.0;

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  Future<void> getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email!;
      await checkOngoingTrips();
    } else {
      // Handle user not logged in scenario
    }
  }

  Future<void> fetchRoutes() async {
    final snapshot = await FirebaseFirestore.instance.collection('routes').get();
    final List<Map<String, dynamic>> fetchedRoutes = snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'startLatitude': doc['startLatitude']?.toDouble() ?? 0.0,
      'startLongitude': doc['startLongitude']?.toDouble() ?? 0.0,
      'endLatitude': doc['endLatitude']?.toDouble() ?? 0.0,
      'endLongitude': doc['endLongitude']?.toDouble() ?? 0.0,
      'routePoints': doc['routePoints'], // assuming 'routePoints' is an array field
      'start': doc['start'],
      'end': doc['end'],
    })
        .toList();

    if (fetchedRoutes.isNotEmpty) {
      setState(() {
        selectedRoute = fetchedRoutes.first;
      });
      await checkAtStartLocation();
    }
  }

  Future<void> checkOngoingTrips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('email', isEqualTo: userEmail)
        .where('endTime', isEqualTo: null)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isTripStarted = true;
        tripId = snapshot.docs.first.id;
        selectedRoute = {
          'id': snapshot.docs.first['routeId'],
          'name': '', // Add route name if needed
          'startLatitude': snapshot.docs.first['startLatitude']?.toDouble() ?? 0.0,
          'startLongitude': snapshot.docs.first['startLongitude']?.toDouble() ?? 0.0,
          'endLatitude': snapshot.docs.first['endLatitude']?.toDouble() ?? 0.0,
          'endLongitude': snapshot.docs.first['endLongitude']?.toDouble() ?? 0.0,
          'routePoints': [], // Initialize routePoints if needed
          'start': snapshot.docs.first['startTime'],
          'end': null, // end time will be updated when trip ends
        };
      });
      // Start tracking location updates
      _startLocationTracking();
    } else {
      await fetchRoutes(); // Fetch routes if no ongoing trip
    }
  }

  void _startLocationTracking() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (isTripStarted) {
        await getCurrentPosition();
        if (previousPosition != null && currentPosition != null) {
          double distance = Geolocator.distanceBetween(
            previousPosition!.latitude,
            previousPosition!.longitude,
            currentPosition!.latitude,
            currentPosition!.longitude,
          );
          setState(() {
            distanceCovered += distance;
          });
        }
        previousPosition = currentPosition;
      }
    });
  }
  Future<void> checkLocationPermission() async {
    // Check the current status of location permission
    PermissionStatus permission = await Permission.location.status;

    // If permission is not granted, request it
    if (!permission.isGranted) {
      permission = await Permission.location.request();
    }

    // Handle the case where permission is denied permanently
    if (permission.isDenied || permission.isRestricted) {
      // You can show a message to the user here, or direct them to the app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Location permission is required to track your trip.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> getCurrentPosition() async {
    await checkLocationPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = position;
    });
  }

  Future<void> checkAtStartLocation() async {
    await getCurrentPosition();
    if (selectedRoute == null || currentPosition == null) return;

    double distance = await Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      selectedRoute!['startLatitude'],
      selectedRoute!['startLongitude'],
    );

    setState(() {
      isAtStartLocation = distance < 100;
      remainingDistance = distance;
    });
  }

  Future<void> checkAtEndLocation() async {
    await getCurrentPosition();
    if (selectedRoute == null || currentPosition == null) return;

    double distance = await Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      selectedRoute!['endLatitude'],
      selectedRoute!['endLongitude'],
    );

    setState(() {
      isAtEndLocation = distance < 100;
      remainingDistance = distance;
    });
  }

  void startTrip() async {
    if (selectedRoute == null) return;
    DocumentReference tripDoc = await FirebaseFirestore.instance.collection('trips').add({
      'email': userEmail,
      'routeId': selectedRoute!['id'],
      'startLatitude': selectedRoute!['startLatitude'],
      'startLongitude': selectedRoute!['startLongitude'],
      'endLatitude': selectedRoute!['endLatitude'],
      'endLongitude': selectedRoute!['endLongitude'],
      'startTime': Timestamp.now(),
      'endTime': null,
    });
    setState(() async {
      isTripStarted = true;
      tripId = tripDoc.id;
      previousPosition = null; // Reset previous position
      distanceCovered = 0.0; // Reset distance covered
      remainingDistance = await Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        selectedRoute!['endLatitude'],
        selectedRoute!['endLongitude'],
      );
    });
  }

  void endTrip() async {
    if (isAtEndLocation && tripId != null) {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'endTime': Timestamp.now(),
      });
      setState(() {
        isTripStarted = false;
        tripId = null;
        previousPosition = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Trip completed successfully',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You are not at the end location yet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd\'th\' EEE MMM yyyy, h:mma').format(dateTime);
  }

  String formatElapsedTime(DateTime startDateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(startDateTime);

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    StringBuffer buffer = StringBuffer();

    if (days > 0) {
      buffer.write('$days day${days > 1 ? 's' : ''} ');
    }
    if (hours > 0) {
      buffer.write('$hours hr${hours > 1 ? 's' : ''} ');
    }
    if (minutes > 0) {
      buffer.write('$minutes min${minutes > 1 ? 's' : ''}');
    }

    return buffer.toString().trim();
  }


  String shortenCoordinates(double value) {
    return value.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarr(foodtitle: 'Add Trip'),

      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedRoute != null) ...[
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route: ${selectedRoute!['name']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Location',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${shortenCoordinates(selectedRoute!['startLatitude'])}, ${shortenCoordinates(selectedRoute!['startLongitude'])}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Location',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${shortenCoordinates(selectedRoute!['endLatitude'])}, ${shortenCoordinates(selectedRoute!['endLongitude'])}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Start Time: ${selectedRoute!['start'] != null ? formatTimestamp(selectedRoute!['start']) : 'Not started'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      if (selectedRoute!['end'] != null)
                        Text(
                          'End Time: ${formatTimestamp(selectedRoute!['end'])}',
                          style: TextStyle(fontSize: 16),
                        ),
                      SizedBox(height: 12),

                      if (isTripStarted && selectedRoute != null && selectedRoute!['start'] != null)
                          Text(
                            'Elapsed Time: ${formatElapsedTime(selectedRoute!['start'].toDate())}',
                            style: TextStyle(fontSize: 16),
                          ),

                      SizedBox(height: 12),
                      Text(
                        'Distance Covered: ${distanceCovered.toStringAsFixed(2)} meters',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Remaining Distance: ${remainingDistance.toStringAsFixed(2)} meters',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            if (currentPosition != null)
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${shortenCoordinates(currentPosition!.latitude)}, ${shortenCoordinates(currentPosition!.longitude)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (!isTripStarted)
              ElevatedButton(
                onPressed: isAtStartLocation ? startTrip : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Start Trip', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            if (isTripStarted)
              ElevatedButton(
                onPressed: endTrip,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('End Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (isTripStarted)
              Text(
                'Trip in progress...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            if (isAtStartLocation && !isTripStarted)
              Text(
                'You are at the start location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            if (isAtEndLocation && isTripStarted)
              Text(
                'You are at the end location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
