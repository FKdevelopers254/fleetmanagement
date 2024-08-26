import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../admin/libb/widget - Copy.dart';

class DriverAnalytics extends StatefulWidget {
  @override
  _DriverAnalyticsState createState() => _DriverAnalyticsState();
}

class _DriverAnalyticsState extends State<DriverAnalytics> {
  final user = FirebaseAuth.instance.currentUser!;
  static const double fuelThreshold = 1000.0; // Fuel threshold in liters
  static const double efficiencyThreshold = 10.0; // Fuel efficiency threshold in km/L
  static const double routeEfficiencyThreshold = 1.1; // Example threshold for route efficiency (actual/planned)
  static const double speedThreshold = 80.0; // Speed threshold in km/h for performance analysis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:AppBarr(foodtitle:'Driver Analytics'),
      //  backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAnalyticsData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          double totalDistance = data['totalDistance'];
          double averageDistance = data['averageDistance'];
          Duration totalTime = data['totalTime'];
          int totalTrips = data['totalTrips'];
          double totalFuel = data['totalFuel'];
          double routeEfficiencyRatio = data['routeEfficiencyRatio'];
          bool inefficientRoutes = data['inefficientRoutes'];
          double averageSpeed = data['averageSpeed'];
          double maxSpeed = data['maxSpeed'];
          int longTripsCount = data['longTripsCount'];
          int shortTripsCount = data['shortTripsCount'];
          double averageTripDuration = data['averageTripDuration'];
          double longestTripDuration = data['longestTripDuration'];
          double shortestTripDuration = data['shortestTripDuration'];

          double fuelEfficiency = totalDistance / (totalFuel > 0 ? totalFuel : 1); // Avoid division by zero
          bool highFuelConsumption = totalFuel > fuelThreshold;
          bool lowFuelEfficiency = fuelEfficiency < efficiencyThreshold;

          String totalTimeFormatted = '${totalTime.inHours}h ${totalTime.inMinutes.remainder(60)}m';
          String averageSpeedFormatted = '${averageSpeed.toStringAsFixed(2)} km/h';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildAnalyticsCard(
                  title: 'Total Trips',
                  value: '$totalTrips',
                  icon: Icons.trip_origin,
                  color: Colors.orangeAccent,
                ),
                _buildAnalyticsCard(
                  title: 'Total Distance (km)',
                  value: totalDistance.toStringAsFixed(2),
                  icon: Icons.directions_car,
                  color: Colors.blueAccent,
                ),
                _buildAnalyticsCard(
                  title: 'Average Trip Distance (km)',
                  value: averageDistance.toStringAsFixed(2),
                  icon: Icons.map,
                  color: Colors.green,
                ),
                _buildAnalyticsCard(
                  title: 'Total Driving Time',
                  value: totalTimeFormatted,
                  icon: Icons.access_time,
                  color: Colors.redAccent,
                ),
                _buildAnalyticsCard(
                  title: 'Total Fuel (L)',
                  value: totalFuel.toStringAsFixed(2),
                  icon: Icons.local_gas_station,
                  color: Colors.teal,
                ),
                _buildAnalyticsCard(
                  title: 'Average Speed (km/h)',
                  value: averageSpeedFormatted,
                  icon: Icons.speed,
                  color: Colors.purpleAccent,
                ),
                _buildAnalyticsCard(
                  title: 'Max Speed (km/h)',
                  value: maxSpeed.toStringAsFixed(2),
                  icon: Icons.terrain,
                  color: Colors.cyanAccent,
                ),
                _buildAnalyticsCard(
                  title: 'Longest Trip Duration (h)',
                  value: longestTripDuration.toStringAsFixed(2),
                  icon: Icons.timer,
                  color: Colors.amber,
                ),
                _buildAnalyticsCard(
                  title: 'Shortest Trip Duration (h)',
                  value: shortestTripDuration.toStringAsFixed(2),
                  icon: Icons.timer,
                  color: Colors.lightGreen,
                ),
                _buildAnalyticsCard(
                  title: 'Long Trips Count',
                  value: '$longTripsCount',
                  icon: Icons.directions_car,
                  color: Colors.deepOrange,
                ),
                _buildAnalyticsCard(
                  title: 'Short Trips Count',
                  value: '$shortTripsCount',
                  icon: Icons.directions_car,
                  color: Colors.deepPurple,
                ),
                if (highFuelConsumption)
                  _buildAlertCard(
                    title: 'High Fuel Consumption',
                    message: 'Total fuel consumption exceeds $fuelThreshold liters.',
                    color: Colors.redAccent,
                  ),
                if (lowFuelEfficiency)
                  _buildAlertCard(
                    title: 'Low Fuel Efficiency',
                    message: 'Fuel efficiency is below $efficiencyThreshold km/L.',
                    color: Colors.orangeAccent,
                  ),
                if (inefficientRoutes)
                  _buildAlertCard(
                    title: 'Inefficient Routes',
                    message: 'Some routes have efficiency ratios above $routeEfficiencyThreshold.',
                    color: Colors.redAccent,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    var firestore = FirebaseFirestore.instance;
    var now = DateTime.now();
    var userEmail = FirebaseAuth.instance.currentUser!.email!;

    // Fetch vehicle IDs for the driver
    var driverAllocationSnapshot = await firestore
        .collection('driverallocated')
        .where('email', isEqualTo: userEmail)
        .get();

    List<String> vehicleIds = driverAllocationSnapshot.docs
        .map((doc) => doc['vehicleid'] as String)
        .toList();

    // Fetch trips data
    var tripsSnapshot = await firestore
        .collection('trips')
        .where('userEmail', isEqualTo: userEmail)
        .get();

    List<DocumentSnapshot> trips = tripsSnapshot.docs;
    double totalActualDistance = 0.0;
    double totalPlannedDistance = 0.0;
    Duration totalTime = Duration();
    int totalTrips = trips.length;
    double totalSpeed = 0.0;
    double maxSpeed = 0.0;
    int longTripsCount = 0;
    int shortTripsCount = 0;
    double totalDuration = 0.0;
    double longestTripDuration = 0.0;
    double shortestTripDuration = double.infinity;

    // Track route efficiency
    int inefficientRoutesCount = 0;

    for (var entry in trips) {
      double startLat = entry['startLatitude']?.toDouble() ?? 0.0;
      double startLong = entry['startLongitude']?.toDouble() ?? 0.0;
      double endLat = entry['endLatitude']?.toDouble() ?? 0.0;
      double endLong = entry['endLongitude']?.toDouble() ?? 0.0;

      double tripDistance = Geolocator.distanceBetween(startLat, startLong, endLat, endLong) / 1000.0; // in kilometers
      totalActualDistance += tripDistance;

      DateTime startTime = (entry['startTime'] as Timestamp).toDate();
      DateTime endTime = (entry['endTime'] as Timestamp?)?.toDate() ?? now;

      Duration tripDuration = endTime.difference(startTime);
      totalTime += tripDuration;
      totalDuration += tripDuration.inMinutes.toDouble() / 60; // in hours

      double tripSpeed = tripDistance / (tripDuration.inMinutes.toDouble() / 60); // in km/h
      totalSpeed += tripSpeed;
      if (tripSpeed > maxSpeed) maxSpeed = tripSpeed;

      if (tripDistance > 50.0) longTripsCount++; // Example threshold for long trips
      if (tripDistance < 5.0) shortTripsCount++; // Example threshold for short trips

      if (tripDuration.inMinutes.toDouble() / 60 > longestTripDuration) longestTripDuration = tripDuration.inMinutes.toDouble() / 60;
      if (tripDuration.inMinutes.toDouble() / 60 < shortestTripDuration) shortestTripDuration = tripDuration.inMinutes.toDouble() / 60;
    }

    // Fetch route data and calculate planned distance
    var driverRoutesSnapshot = await firestore
        .collection('driverroutes')
        .where('email', isEqualTo: userEmail)
        .get();

    for (var routeEntry in driverRoutesSnapshot.docs) {
      var routeId = routeEntry['routeid'] as String;

      var routeSnapshot = await firestore
          .collection('routes')
          .doc(routeId)
          .get();

      if (routeSnapshot.exists) {
        var routeData = routeSnapshot.data()!;
        double startLat = routeData['startlatitude']?.toDouble() ?? 0.0;
        double startLong = routeData['startlongitude']?.toDouble() ?? 0.0;
        double endLat = routeData['endlatitude']?.toDouble() ?? 0.0;
        double endLong = routeData['endlongitude']?.toDouble() ?? 0.0;

        double plannedDistance = Geolocator.distanceBetween(startLat, startLong, endLat, endLong) / 1000.0; // in kilometers
        totalPlannedDistance += plannedDistance;
      }
    }

    double efficiencyRatio = totalActualDistance / (totalPlannedDistance > 0 ? totalPlannedDistance : 1); // Avoid division by zero
    bool inefficientRoutes = efficiencyRatio > routeEfficiencyThreshold; // Example threshold for route efficiency

    // Fetch fuel data for the vehicles
    double totalFuel = 0.0;
    for (var vehicleId in vehicleIds) {
      var fuelSnapshot = await firestore
          .collection('fuel')
          .where('vehicleid', isEqualTo: vehicleId)
          .get();

      for (var fuelEntry in fuelSnapshot.docs) {
        totalFuel += (fuelEntry['amount'] as num).toDouble();
      }
    }

    double totalDistance = totalActualDistance;
    double averageDistance = totalTrips > 0 ? totalDistance / totalTrips : 0.0;
    double averageSpeed = totalTrips > 0 ? totalSpeed / totalTrips : 0.0;
    double averageTripDuration = totalTrips > 0 ? totalDuration / totalTrips : 0.0;
    double fuelEfficiency = totalDistance / (totalFuel > 0 ? totalFuel : 1); // Avoid division by zero

    return {
      'totalDistance': totalDistance,
      'averageDistance': averageDistance,
      'totalTime': totalTime,
      'totalTrips': totalTrips,
      'totalFuel': totalFuel,
      'routeEfficiencyRatio': efficiencyRatio,
      'inefficientRoutes': inefficientRoutes,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'longTripsCount': longTripsCount,
      'shortTripsCount': shortTripsCount,
      'averageTripDuration': averageTripDuration,
      'longestTripDuration': longestTripDuration,
      'shortestTripDuration': shortestTripDuration,
    };
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: color,
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
    );
  }
}
