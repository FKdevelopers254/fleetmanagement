import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleetmanagement/admin/counters.dart';
import 'package:fleetmanagement/admin/view/fuel.dart';
import 'package:fleetmanagement/admin/view/routes.dart';
import 'package:fleetmanagement/admin/view/servicetype.dart';
import 'package:fleetmanagement/admin/view/trips.dart';
import 'package:fleetmanagement/admin/view/vehicles.dart';
import 'package:fleetmanagement/admin/view/vehicletype.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../driver/trips.dart';
import '../../user/routes.dart';
import 'driveranalytics.dart';



class FleetDriverDashboard extends StatefulWidget {
  @override
  _FleetDriverDashboardState createState() => _FleetDriverDashboardState();
}

class _FleetDriverDashboardState extends State<FleetDriverDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fleet Driver Dashboard',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              letterSpacing: 1.5,
            ),),),
        bottom: TabBar(
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          controller: _tabController,
          isScrollable: true,
          tabs: [

            Stack(
              children: [
                Positioned(top: 0,right: 0,child: DriverTripsCounter(email: user.email!)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tab(text: 'Trips', icon: Icon(Icons.directions_bus)),
                ),
              ],
            ),
            Tab(text: 'Analytics', icon: Icon(Icons.directions_bus)),

          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [

          DriverTrips(),
          DriverAnalytics()





        ],
      ),
    );
  }
}


