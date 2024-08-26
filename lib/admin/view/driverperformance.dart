import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DriverPerformancePage extends StatefulWidget {
  final String driverEmail;
  const DriverPerformancePage({super.key, required this.driverEmail});

  @override
  State<DriverPerformancePage> createState() => _DriverPerformancePageState();
}

Future<Map<String, dynamic>> fetchDriverPerformance(String driverEmail) async {
  // Fetch vehicleId associated with the driverEmail
  QuerySnapshot driverAllocSnapshot = await FirebaseFirestore.instance
      .collection('driverallocated')
      .where('email', isEqualTo: driverEmail)
      .get();

  if (driverAllocSnapshot.docs.isEmpty) {
    return {}; // Return empty if no vehicleId is found for the driverEmail
  }

  String vehicleId = driverAllocSnapshot.docs.first['vehicleid'];

  // Fetch all trips for the vehicleId
  QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
      .collection('trips')
      .where('vehicleid', isEqualTo: vehicleId)
      .get();

  // Fetch all fuel entries for the vehicleId
  QuerySnapshot fuelSnapshot = await FirebaseFirestore.instance
      .collection('fuel')
      .where('vehicleid', isEqualTo: vehicleId)
      .get();

  // Fetch driver data
  QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: driverEmail)
      .get();

  if (usersSnapshot.docs.isEmpty) {
    return {}; // Return empty if no user is found for the driverEmail
  }

  DocumentSnapshot userDoc = usersSnapshot.docs.first;
  String driverId = userDoc.id;
  String driverName = '${userDoc['firstname']} ${userDoc['lastname']}';
  String profilePictureUrl = userDoc['email']; // Assuming you have this field
  String phoneNumber = userDoc['phonenumber']; // Assuming you have this field
  String licenseNumber = userDoc['dl']; // Assuming you have this field

  // Initialize driver data
  Map<String, dynamic> driverData = {
    'name': driverName,
    'profilePictureUrl': profilePictureUrl,
    'phoneNumber': phoneNumber,
    'licenseNumber': licenseNumber,
    'totalDistance': 0.0,
    'totalFuel': 0.0,
    'completedTrips': 0,
    'tripDetails': [],
    'fuelHistory': []
  };

  // Calculate total distance and completed trips
  tripsSnapshot.docs.forEach((tripDoc) {
    double startLat = tripDoc['startLatitude'];
    double startLong = tripDoc['startLongitude'];
    double endLat = tripDoc['endLatitude'];
    double endLong = tripDoc['endLongitude'];

    double distance = Geolocator.distanceBetween(startLat, startLong, endLat, endLong) / 1000.0; // in kilometers

    driverData['totalDistance'] += distance;
    driverData['completedTrips'] += 1;

    driverData['tripDetails'].add({
      'startLatitude': startLat,
      'startLongitude': startLong,
      'endLatitude': endLat,
      'endLongitude': endLong,
      'distance': distance,
      'date': (tripDoc['startTime'] as Timestamp).toDate(), // Convert timestamp to DateTime
    });
  });

  // Calculate total fuel consumption
  fuelSnapshot.docs.forEach((fuelDoc) {
    double fuelAmount = double.parse(fuelDoc['litres']);

    driverData['totalFuel'] += fuelAmount;

    driverData['fuelHistory'].add({
      'date': (fuelDoc['ondate'] as Timestamp).toDate(), // Convert timestamp to DateTime
      'litres': fuelAmount,
    });
  });

  // Calculate performance metrics
  double totalDistance = driverData['totalDistance'];
  double totalFuel = driverData['totalFuel'];
  int completedTrips = driverData['completedTrips'];

  double fuelEfficiency = totalFuel > 0 ? totalDistance / totalFuel : 0.0;
  double averageTripDistance = completedTrips > 0 ? totalDistance / completedTrips : 0.0;

  Map<String, dynamic> performanceMetrics = {
    'driverName': driverName,
    'profilePictureUrl': profilePictureUrl,
    'phoneNumber': phoneNumber,
    'licenseNumber': licenseNumber,
    'fuelEfficiency': fuelEfficiency,
    'averageTripDistance': averageTripDistance,
    'completedTrips': completedTrips,
    'tripDetails': driverData['tripDetails'],
    'fuelHistory': driverData['fuelHistory']
  };

  return {driverId: performanceMetrics};
}

class _DriverPerformancePageState extends State<DriverPerformancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Performance'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDriverPerformance(widget.driverEmail), // Pass driverEmail here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          Map<String, dynamic> performanceMetrics = snapshot.data!;
          if (performanceMetrics.isEmpty) {
            return Center(child: Text('No data available for this driver.'));
          }

          Map<String, dynamic> metrics = performanceMetrics.values.first;

          return ListView(
            children: [
              // Driver Information
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(metrics['profilePictureUrl']),
                ),
                title: Text(metrics['driverName']),
                subtitle: Text('Phone: ${metrics['phoneNumber']}\nLicense: ${metrics['licenseNumber']}'),
              ),
              Divider(),
              // Performance Metrics
              ListTile(
                title: Text('Fuel Efficiency'),
                subtitle: Text('${metrics['fuelEfficiency'].toStringAsFixed(2)} km/l'),
              ),
              ListTile(
                title: Text('Average Trip Distance'),
                subtitle: Text('${metrics['averageTripDistance'].toStringAsFixed(2)} km'),
              ),
              ListTile(
                title: Text('Completed Trips'),
                subtitle: Text('${metrics['completedTrips']}'),
              ),
              Divider(),
              // Trip Details
              ExpansionTile(
                title: Text('Trip Details'),
                children: metrics['tripDetails'].map<Widget>((trip) {
                  return ListTile(
                    title: Text('Trip on ${DateFormat.yMMMd().format(trip['date'])}'), // Format date
                    subtitle: Text('Distance: ${trip['distance'].toStringAsFixed(2)} km'),
                  );
                }).toList(),
              ),
              // Fuel History
              ExpansionTile(
                title: Text('Fuel History'),
                children: metrics['fuelHistory'].map<Widget>((fuel) {
                  return ListTile(
                    title: Text('Fuel on ${DateFormat.yMMMd().format(fuel['date'])}'), // Format date
                    subtitle: Text('Litres: ${fuel['litres']}'),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFuelPieChart(metrics['fuelHistory']),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTripLineChart(metrics['tripDetails']),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFuelPieChart(List<dynamic> fuelEntries) {
    // Extract and calculate total fuel for each entry
    List<PieChartSectionData> pieChartData = fuelEntries.map((fuelEntry) {
      double litres = fuelEntry['litres'];
      return PieChartSectionData(
        color: Colors.blue, // Customize color as needed
        value: litres,
        title: '${litres.toStringAsFixed(1)}L',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: pieChartData,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildTripLineChart(List<dynamic> tripDetails) {
    List<FlSpot> spots = tripDetails.asMap().entries.map((entry) {
      int index = entry.key;
      double distance = entry.value['distance'];
      return FlSpot(index.toDouble(), distance);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 4,
            color: Colors.green,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.3),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
        minX: 0,
        maxX: tripDetails.length.toDouble() - 1,
        minY: 0,
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
      ),
    );
  }
}
