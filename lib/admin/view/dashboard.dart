import 'package:fleetmanagement/admin/counters.dart';
import 'package:fleetmanagement/admin/view/fuel.dart';
import 'package:fleetmanagement/admin/view/routes.dart';
import 'package:fleetmanagement/admin/view/servicetype.dart';
import 'package:fleetmanagement/admin/view/trips.dart';
import 'package:fleetmanagement/admin/view/vehicles.dart';
import 'package:fleetmanagement/admin/view/vehicletype.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../driver/dashboard.dart';
import '../../driver/trips.dart';
import '../../user/ml.dart';
import '../../user/routes.dart';
import '../add/addservicetype.dart';
import 'drivers.dart';
import 'maintainance.dart';
import 'maintenancedata.dart';


class FleetManagementDashboard extends StatefulWidget {
  @override
  _FleetManagementDashboardState createState() => _FleetManagementDashboardState();
}

class _FleetManagementDashboardState extends State<FleetManagementDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
      'Fleet Management Dashboard',
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
                Positioned(top: 0,right: 0,child: RoutesCounter()),
                Tab(text: 'Routes', icon: Icon(Icons.map)),
              ],
            ),

            Stack(
              children: [
                Positioned(top: 0,right: 0,child: VehiclesCounter()),
                Tab(text: 'Vehicles', icon: Icon(Icons.directions_bus)),
              ],
            ),
            Stack(
              children: [
                Positioned(top: 0,right: 0,child: VehiclesCounter()),
                Tab(text: 'Drivers', icon: Icon(Icons.person_add_alt_1_sharp)),
              ],
            ),


            Stack(
              children: [
                Positioned(top: 0,right: 0,child: VehiclesCounter()),
                Tab(text: 'Upcoming Maintenance', icon: Icon(Icons.build)),
              ],
            ),
            Stack(
              children: [
                Positioned(top: 0,right: 0,child: Text('')),
                Tab(text: 'Maintenance Data', icon: Icon(Icons.data_exploration)),
              ],
            ),
            Stack(
              children: [
                Positioned(top: 0,right: 0,child: Text('')),
                Tab(text: 'Service Type', icon: Icon(Icons.sensor_window_rounded)),
              ],
            ),
            Stack(
              children: [
                Positioned(top: 0,right: 0,child: Text('')),
                Tab(text: 'Vehicle Type', icon: Icon(Icons.calendar_month_rounded)),
              ],
            ),



          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Routes(),


          Vehicles(),
          Drivers(),

       //   AnalyticsScreen(),

          Maintenance(),
          MaintenanceData(),
       ServiceTypes(),
       VehicleTypes()
       // MyAppp()
        //  Fuels(),



        ],
      ),
    );
  }
}


