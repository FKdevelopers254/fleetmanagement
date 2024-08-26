import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleetmanagement/admin/view/analyticstab.dart';
import 'package:fleetmanagement/admin/view/singlefuel.dart';
import 'package:fleetmanagement/admin/view/singlemaintenance.dart';
import 'package:fleetmanagement/admin/view/singletrips.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:flutter/foundation.dart' show kIsWeb;

import '../../auth/glassbox.dart';
import '../widget.dart';

class VehicleDetailScreen extends StatelessWidget  {
  final DocumentSnapshot documentt;

  bool isLoading = false;


  VehicleDetailScreen(this.documentt);





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  DefaultTabController(
        length: 4,
        child: CustomScrollView(

          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            SliverAppBar(

              leading: LeadingAppBar(),
              pinned: true,
              stretch: false,
              onStretchTrigger: () {
                // Function callback for stretch
                return Future<void>.value();
              },
              //expandedHeight: 40.0,
              shadowColor: Colors.orange,

            ),

            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  labelColor: Colors.orange,

                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.orange,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Analytics',),
                    Tab(text: 'Trips',),

                    Tab(text: 'Fuel'),
                    Tab(text: 'Maintenance'),




                  ],
                ),

              ),
              pinned: true,
            ),

            SliverFillRemaining(
              child:  TabBarView(
                children: [

                  VehicleAnalyticsPage(vehicleId: documentt['id']),
                //  VehicleDetails(vehicleId: documentt['id']),
                  SingleTrip(vehicleId: documentt['id']),
                  SingleFuel(vehicleId: documentt['id']),
                  SingleMaintenance(vehicleId: documentt['id']),







                  // ListTiles++
                ],
              ),
            )

          ],
        ),
      ),

    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent, // Customize the background color of the tab bar
      child: GlassBox(child: _tabBar),
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class VehicleDetails extends StatefulWidget {
  final String vehicleId;
  const VehicleDetails({super.key, required this.vehicleId});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicles')
              .where('id', isEqualTo: widget.vehicleId)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No user data found');
            }

            var userData = snapshot.data!.docs[0];
            String name = userData.get('name');
            String location = userData.get('location');
            String regno = userData.get('regno');
            String fueltype = userData.get('fueltype');
            String routename = userData.get('routename');
            String odometer = userData.get('odometer');

            return Padding(
              padding: const EdgeInsets.all(13.0),
              child: Container(
                child: Column(
                  children: [
                    Row(

                      children: [
                        Icon(Icons.person,color: Colors.green,),
                        Text(
                          'Vehicle Name: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          //     width: 115,
                          child: Text(
                            '$name' ,
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,   ),
                        ),
                      ],
                    ),
                    Row(

                      children: [
                        Icon(Icons.confirmation_number_outlined,color: Colors.green,),
                        Text(
                          'Reg No: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          width: 90,
                          child: Text(
                            '$regno',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,  ),
                        ),
                      ],
                    ),
                    Row(

                      children: [
                        Icon(Icons.filter_alt_outlined,color: Colors.green,),
                        Text(
                          'Fuel Type: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          width: 110,
                          child: Text(
                            '$fueltype',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,  ),
                        ),
                      ],
                    ),
                    Row(

                      children: [
                        Icon(Icons.car_repair,color: Colors.green,),
                        Text(
                          'Odometer: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          width: 110,
                          child: Text(
                            '$odometer',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,  ),
                        ),
                      ],
                    ),
                    Row(

                      children: [
                        Icon(Icons.route,color: Colors.green,),
                        Text(
                          'Route Name: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          width: 105,
                          child: Text(
                            '$routename',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,  ),
                        ),
                      ],
                    ),
                    Row(

                      children: [
                        Icon(Icons.location_pin,color: Colors.green,),
                        Text(
                          'Location: ',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Container(
                          width: 105,
                          child: Text(
                            '$location',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
