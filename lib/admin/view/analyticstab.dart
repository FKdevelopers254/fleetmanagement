import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widget.dart';

class VehicleAnalyticsPage extends StatefulWidget {
  final String vehicleId;

  const VehicleAnalyticsPage({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _VehicleAnalyticsPageState createState() => _VehicleAnalyticsPageState();
}

class _VehicleAnalyticsPageState extends State<VehicleAnalyticsPage> {
  List<DocumentSnapshot> fuelEntries = [];
  List<DocumentSnapshot> tripEntries = [];
  List<DocumentSnapshot> maintenanceEntries = [];
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchFuelData(widget.vehicleId, selectedDate);
    fetchTripData(widget.vehicleId, selectedDate);
    fetchMaintenanceData(widget.vehicleId);
  }

  Future<void> fetchMaintenanceData(String vehicleId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('maintenance')
        .where('vehicleid', isEqualTo: vehicleId)
        .get();

    setState(() {
      maintenanceEntries = snapshot.docs;
    });
  }

  Future<DocumentSnapshot> fetchVehicleDetails(String vehicleId) async {
    try {
      DocumentSnapshot vehicleSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();
      return vehicleSnapshot;
    } catch (e) {
      print('Error fetching vehicle details: $e');
      throw e;
    }
  }

  Future<void> fetchFuelData(String vehicleId, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('fuel')
        .where('ondate', isGreaterThanOrEqualTo: startOfDay)
        .where('ondate', isLessThanOrEqualTo: endOfDay)
        .where('vehicleid', isEqualTo: vehicleId)
        .get();

    setState(() {
      fuelEntries = snapshot.docs;
    });
  }

  double calculateAverageFuelEfficiency() {
    if (fuelEntries.isEmpty || tripEntries.isEmpty) return 0.0;

    double totalFuelLitres = fuelEntries.fold(0.0, (sum, entry) {
      double litres = double.parse(entry['litres'].toString());
      return sum + litres;
    });

    double totalTripDistance = 0.0;

    tripEntries.forEach((entry) {
      double startLat = entry['startLatitude'] ?? 0.0;
      double startLong = entry['startLongitude'] ?? 0.0;
      double endLat = entry['endLatitude'] ?? 0.0;
      double endLong = entry['endLongitude'] ?? 0.0;

      totalTripDistance += Geolocator.distanceBetween(startLat, startLong, endLat, endLong) / 1000.0; // in kilometers
    });

    if (totalTripDistance > 0) {
      return totalFuelLitres / totalTripDistance; // liters per kilometer
    } else {
      return 0.0;
    }
  }

  Future<void> fetchTripData(String vehicleId, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThanOrEqualTo: endOfDay)
        .where('vehicleid', isEqualTo: vehicleId)
        .get();

    setState(() {
      tripEntries = snapshot.docs;
    });
  }

  Future<double> calculateTripDistance(double startLat, double startLong, double endLat, double endLong) async {
    double distanceInMeters = await Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
    return distanceInMeters / 1000.0; // Convert meters to kilometers
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchFuelData(widget.vehicleId, selectedDate);
      fetchTripData(widget.vehicleId, selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarr(foodtitle: 'Predictive Analytics',),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
        leading: SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Fuel Entries for ${DateFormat('dd/MM/yyyy').format(selectedDate)}:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Average Fuel Efficiency:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '${calculateAverageFuelEfficiency().toStringAsFixed(2)} liters/km',
                        style: TextStyle(fontSize: 16),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            fuelEntries.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: fuelEntries.length,
                        itemBuilder: (context, index) {
                          var fuelEntry = fuelEntries[index];
                          return ListTile(
                            title: Text('Fuel Entry ${index + 1}'),
                            subtitle: Text('Litres: ${fuelEntry['litres']}\nLocation: ${fuelEntry['location']}\nAmount: Ksh.${fuelEntry['amount']}'),
                          );
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 150,

                            child: _buildCircleChart(fuelEntries, 'litres'),
                          ),
                          SizedBox(height: 150, child: _buildFuelEfficiencyChart())
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Trip Entries for ${DateFormat('dd/MM/yyyy').format(selectedDate)}:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            tripEntries.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: tripEntries.length,
                  itemBuilder: (context, index) {
                    var tripEntry = tripEntries[index];
                    var startTime = (tripEntry['startTime'] as Timestamp).toDate();
                    String formattedStartTime = DateFormat('d MMM yyyy h:mm a').format(startTime);
                    var endTime = tripEntry['endTime'] != null ? (tripEntry['endTime'] as Timestamp).toDate() : null;

                    String endTimeDisplay = endTime != null
                        ? DateFormat('d MMM yyyy h:mm a').format(endTime)
                        : 'Travelling for ${(DateTime.now().difference(startTime).inMinutes / 60).toStringAsFixed(1)} hours';

                    var startLat = tripEntry['startLatitude'] ?? 0.0;
                    var startLong = tripEntry['startLongitude'] ?? 0.0;
                    var endLat = tripEntry['endLatitude'] ?? 0.0;
                    var endLong = tripEntry['endLongitude'] ?? 0.0;

                    return FutureBuilder<double>(
                      future: calculateTripDistance(startLat, startLong, endLat, endLong),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Trip Entry ${index + 1}'),
                            subtitle: Text('Calculating distance...'),
                          );
                        } else if (snapshot.hasError) {
                          return ListTile(
                            title: Text('Trip Entry ${index + 1}'),
                            subtitle: Text('Error calculating distance: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          double tripDistance = snapshot.data!;
                          bool showRecommendation = tripDistance < 10.0;
                          bool showRecommendationn = tripDistance > 100.0;

                          return ListTile(
                            title: Text('Trip Entry ${index + 1}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Time: $formattedStartTime'),
                                Text('End Time: $endTimeDisplay'),
                                Text('Trip Distance: ${tripDistance.toStringAsFixed(2)} km'),
                                if (showRecommendation)
                                  Text(
                                    'Recommendation: Short trip distance (${tripDistance.toStringAsFixed(2)} km). Check vehicle efficiency.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                if (showRecommendationn)
                                  Text(
                                    'Recommendation:\nVery Long trip distance (${tripDistance.toStringAsFixed(2)} km). \nCheck vehicle efficiency.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 150,
                  child: _buildCircleChart(tripEntries, 'distance', isTrip: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Maintenance Costs:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 150, child: _buildMaintenanceCircleChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCircleChart() {
    Map<String, double> totalCostsMap = {};
    maintenanceEntries.forEach((maintenance) {
      String vehicleId = maintenance['vehicleid'];
      double cost = double.parse(maintenance['cost'].toString());
      totalCostsMap[vehicleId] = (totalCostsMap[vehicleId] ?? 0.0) + cost;
    });

    final List<Future<CircleChartItemData>> futureCircleChartData = totalCostsMap.keys.map((vehicleId) {
      double totalCost = totalCostsMap[vehicleId] ?? 0.0;
      return fetchVehicleDetails(vehicleId).then((vehicle) {
        return CircleChartItemData(
          name: vehicle['name'],
          value: totalCost,
          color: Colors.blue,
          description: 'Total Cost: ${totalCost.toStringAsFixed(2)} Ksh',
        );
      }).catchError((error) {
        print('Error fetching vehicle details for vehicleId: $vehicleId, error: $error');
        return CircleChartItemData(
          name: 'Vehicle Not Found',
          value: totalCost,
          color: Colors.grey,
          description: 'Total Cost: ${totalCost.toStringAsFixed(2)} Ksh',
        );
      });
    }).toList();

    return FutureBuilder<List<CircleChartItemData>>(
      future: Future.wait(futureCircleChartData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircleChart(
            chartType: CircleChartType.solid,
            items: snapshot.data!,
          );
        }
      },
    );
  }

  Widget _buildCircleChart(List<DocumentSnapshot> entries, String dataKey, {bool isTrip = false}) {
    List<CircleChartItemData> circleChartData = entries.map((entry) {
      double value = isTrip
          ? Geolocator.distanceBetween(entry['startLatitude'] ?? 0.0, entry['startLongitude'] ?? 0.0,
          entry['endLatitude'] ?? 0.0, entry['endLongitude'] ?? 0.0) /
          1000.0
          : double.parse(entry[dataKey].toString());
      return CircleChartItemData(
        name: 'Entry ${entries.indexOf(entry) + 1}',
        value: value,
        color: Colors.orange,
        description: '${dataKey.capitalize()}: ${value.toStringAsFixed(2)}',
      );
    }).toList();

    double totalValue = circleChartData.fold(0.0, (sum, item) => sum + item.value);

    circleChartData.add(
      CircleChartItemData(
        name: 'Total',
        value: totalValue,
        color: Colors.yellow,
        description: 'Total ${dataKey.capitalize()}: ${totalValue.toStringAsFixed(2)}',
      ),
    );

    return CircleChart(
      chartType: CircleChartType.solid,
      items: circleChartData,
    );
  }

  Widget _buildFuelEfficiencyChart() {
    double fuelEfficiency = calculateAverageFuelEfficiency();
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.orange,
            value: fuelEfficiency,
            title: '${fuelEfficiency.toStringAsFixed(2)} liters/km',
            radius: 50,
            titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class CircleChartItemData {
  final String name;
  final double value;
  final Color color;
  final String description;

  CircleChartItemData({
    required this.name,
    required this.value,
    required this.color,
    required this.description,
  });
}

class CircleChart extends StatelessWidget {
  final CircleChartType chartType;
  final List<CircleChartItemData> items;

  CircleChart({required this.chartType, required this.items});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: items.map((item) {
          return PieChartSectionData(
            color: item.color,
            value: item.value,
            title: '${item.value.toStringAsFixed(1)}',
            radius: 50,
            titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          );
        }).toList(),
      ),
    );
  }
}

enum CircleChartType { solid, outline }

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
