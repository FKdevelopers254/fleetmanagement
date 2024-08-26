import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchMaintenanceData() async {
    var result = await _firestore.collection('maintenance').get();
    return result.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchFuelData() async {
    var result = await _firestore.collection('fuel').get();
    return result.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTripData() async {
    var result = await _firestore.collection('trips').get();
    return result.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRouteData() async {
    var result = await _firestore.collection('routes').get();
    return result.docs.map((doc) => doc.data()).toList();
  }
}

class MaintenanceModel {
  late DataFrame _dataFrame;
  late LinearRegressor _model;

  Future<void> trainModel(List<Map<String, dynamic>> data) async {
    _dataFrame = DataFrame(data as Iterable<Iterable>);

    final targetName = 'maintenance_cost';
    _model = LinearRegressor(_dataFrame, targetName);
  }

  double predict(List<double> input) {
    final inputDataFrame = DataFrame([
      ['amount', 'fueltype', 'cost', 'routeid'],
      input,
    ]);
    final prediction = _model.predict(inputDataFrame);
    return prediction.rows.first.first;
  }
}

class MyAppp extends StatefulWidget {
  @override
  _MyApppState createState() => _MyApppState();
}

class _MyApppState extends State<MyAppp> {
  final FirebaseService _firebaseService = FirebaseService();
  final MaintenanceModel _maintenanceModel = MaintenanceModel();

  @override
  void initState() {
    super.initState();
    _fetchAndTrainModel();
  }

  Future<void> _fetchAndTrainModel() async {
    var maintenanceData = await _firebaseService.fetchMaintenanceData();
    var fuelData = await _firebaseService.fetchFuelData();
    var tripData = await _firebaseService.fetchTripData();
    var routeData = await _firebaseService.fetchRouteData();

    // Combine and preprocess data here
    var combinedData = maintenanceData.map((maintenance) {
      var fuel = fuelData.firstWhere((f) => f['vehicleid'] == maintenance['vehicleid']);
      var trip = tripData.firstWhere((t) => t['vehicleid'] == maintenance['vehicleid']);
      var route = routeData.firstWhere((r) => r['vehicleid'] == maintenance['vehicleid']);

      return {
        'vehicleid': maintenance['vehicleid'],
        'amount': fuel['amount'],
        'fueltype': fuel['fueltype'],
        'cost': maintenance['cost'],
        'routeid': trip['routeid'],
        'maintenance_cost': maintenance['cost'],
        'routeid': route['id'],
      };
    }).toList();

    await _maintenanceModel.trainModel(combinedData);
  }

  Future<void> _predictMaintenance() async {
    var input = ['amount', 'fueltype', 'cost', 'routeid'];
    var prediction = _maintenanceModel.predict(input.cast<double>());
    print('Prediction: $prediction');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Predictive Analytics'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _predictMaintenance,
            child: Text('Predictive Analytics'),
          ),
        ),
      ),
    );
  }
}
