import 'package:fleetmanagement/admin/add/addfuel.dart';
import 'package:fleetmanagement/admin/add/addmaintenance.dart';
import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:fleetmanagement/admin/edit/editfuel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dtp;

import '../widget.dart';

class SingleMaintenance extends StatefulWidget {
  final String vehicleId;

  const SingleMaintenance({Key? key, required this.vehicleId}) : super(key: key);

  @override
  State<SingleMaintenance> createState() => _SingleMaintenanceState();
}

class _SingleMaintenanceState extends State<SingleMaintenance> {
  String searchQuery = '';
  bool isSortingAscending = true;
  TextEditingController _textEditingController = TextEditingController();

  late List<DocumentSnapshot> filteredProducts = []; // Initialize with an empty list

  DateTime? _startDate;
  DateTime? _endDate;

  // Function to toggle sorting order
  void toggleSortOrder() {
    setState(() {
      isSortingAscending = !isSortingAscending;
    });
  }

  // Function to pick a date range
  Future<void> _pickDateRange() async {
    DateTime? startDate = await dtp.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {},
      onConfirm: (date) {},
      currentTime: DateTime.now(),
      locale: dtp.LocaleType.en,
    );

    if (startDate != null) {
      DateTime? endDate = await dtp.DatePicker.showDatePicker(
        context,
        showTitleActions: true,
        onChanged: (date) {},
        onConfirm: (date) {},
        currentTime: startDate,
        locale: dtp.LocaleType.en,
      );

      if (endDate != null) {
        setState(() {
          _startDate = startDate;
          _endDate = endDate;
        });
      }
    }
  }

  // Function to calculate total fuel
  double _calculateCost(List<DocumentSnapshot> products) {
    double totalFuel = 0.0;
    for (var product in products) {
      // Ensure 'litres' is treated as a double
      var litres = product['cost'];
      if (litres is int) {
        totalFuel += litres.toDouble(); // Convert int to double
      } else if (litres is double) {
        totalFuel += litres; // Directly add if it's already double
      } else if (litres is String) {
        totalFuel += double.tryParse(litres) ?? 0.0; // Attempt to parse string to double
      }
    }
    return totalFuel;
  }
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarr(foodtitle: 'Maintenance'),
        leading: LeadingAppBar(),
        actions: [
          IconButton(
            icon: Icon(isSortingAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: toggleSortOrder,
          ),
          ActionsWidget(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMaintenance()),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        controller: _textEditingController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Search...',
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                            });
                            _textEditingController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          MaterialButton(
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: _pickDateRange,
            child: Text("Select Date Range"),
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 28.0,right: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  MaterialButton(
                    color: Colors.deepPurple,
                    textColor: Colors.white,
                    onPressed: _pickDateRange,
                    child:  Text(
                      '${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                      style: GoogleFonts.dmSerifDisplay(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),

                ],
              ),
            ),


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('maintenance')
                  .where('vehicleid', isEqualTo: widget.vehicleId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                      .where((product) =>
                      product['vehiclename'].toLowerCase().contains(searchQuery))
                      .toList();

                  // Filter products by selected date range
                  if (_startDate != null && _endDate != null) {
                    filteredProducts = filteredProducts.where((product) {
                      Timestamp timestamp = product['ondate'];
                      DateTime productDate = timestamp.toDate();
                      return productDate.isAfter(_startDate!) && productDate.isBefore(_endDate!);
                    }).toList();
                  }

                  // Sort the filtered products based on the date
                  filteredProducts.sort((a, b) {
                    Timestamp dateA = a['ondate'];
                    Timestamp dateB = b['ondate'];
                    return isSortingAscending
                        ? dateA.compareTo(dateB)
                        : dateB.compareTo(dateA);
                  });

                  // Calculate total fuel
                  double totalFuel = _calculateCost(filteredProducts);

                  return Column(
                    children: [
                      Text(
                        'Total Cost: ${totalFuel.toStringAsFixed(2)} Ksh',
                        style: GoogleFonts.dmSerifDisplay(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: kIsWeb
                            ? _buildWebGridView(filteredProducts)
                            : _buildMobileGridView(filteredProducts),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildWebGridView(List<DocumentSnapshot> filteredProducts) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 3 / 2,
    ),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      DocumentSnapshot product = filteredProducts[index];
      return AdminproductItem(product: product);
    },
  );
}

Widget _buildMobileGridView(List<DocumentSnapshot> filteredProducts) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 1.7 / 2,
    ),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      DocumentSnapshot product = filteredProducts[index];
      return AdminproductItem(product: product);
    },
  );
}



class DriversNamesss extends StatelessWidget {
  final String avatar;
  const DriversNamesss({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverallocated')
          .where('email', isEqualTo: avatar)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('No office yet');
        }

        String name = snapshot.data!.docs[0].get('vehicleid');

        return Column(
          children: [
            VehicleName(email: name),
          ],
        );
      },
    );
  }
}

class VehicleName extends StatelessWidget {
  final String email;

  const VehicleName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('id', isEqualTo: email)
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

        return Text(
          '$name',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }
}

class DriversRoutess extends StatelessWidget {
  final String email;
  const DriversRoutess({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverroutes')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('No office yet');
        }

        String name = snapshot.data!.docs[0].get('routeid');

        return Column(
          children: [
            RouteName(email: name),
          ],
        );
      },
    );
  }
}

class RouteName extends StatelessWidget {
  final String email;

  const RouteName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('routes')
          .where('id', isEqualTo: email)
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

        return Text(
          '$name',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }
}

class DriverName extends StatelessWidget {
  final String email;

  const DriverName({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No user data found');
        }

        var userData = snapshot.data!.docs[0];
        String name = userData.get('firstname');
        String lastname = userData.get('lastname');

        return Text(
          '$name $lastname',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }
}
bool isMaintenanceCostTooHigh(double cost) {
  const double costThreshold = 300.0; // Define your cost threshold
  return cost > costThreshold;
}
DateTime? calculateNextMaintenance(DateTime lastMaintenanceDate) {
  // Calculate next maintenance date (e.g., every 3 months)
  return lastMaintenanceDate.add(Duration(days: 90)); // Adjust duration as per your requirement
}

class AdminproductItem extends StatelessWidget {
  final DocumentSnapshot product;

  const AdminproductItem({required this.product,});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Delete",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this maintenance?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on confirmation
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Perform the delete operation
      await FirebaseFirestore.instance.collection('maintenance').doc(product.id).delete();
      // Show a notification that the season has been deleted
      ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${product['name']} deleted successfully'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    String formattedDate = DateFormat('d MMM').format(date);
    String day = formattedDate.split(' ')[0]; // Extract the day part
    String month = formattedDate.split(' ')[1]; // Extract the month part

    // Add suffix for day
    if (day.endsWith('1') && !day.endsWith('11')) {
      day += 'st';
    } else if (day.endsWith('2') && !day.endsWith('12')) {
      day += 'nd';
    } else if (day.endsWith('3') && !day.endsWith('13')) {
      day += 'rd';
    } else {
      day += 'th';
    }

    return '$day $month';
  }

  String _formatDateRange(DateTime start) {
    String formattedStart = _formatDate(start);
    return '$formattedStart';
  }

  DateTime _getLastMaintenanceDate() {
    Timestamp startDateTimestamp = product['ondate'];
    return startDateTimestamp.toDate();
  }
  @override
  Widget build(BuildContext context) {
    Timestamp startDateTimestamp = product['ondate'];
    DateTime startDate = startDateTimestamp.toDate();
    DateTime lastMaintenanceDate = _getLastMaintenanceDate();
    DateTime? nextMaintenanceDate = calculateNextMaintenance(lastMaintenanceDate);
    bool isCostTooHigh = isMaintenanceCostTooHigh(double.parse(product['cost'].toString()));

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      //   onDoubleTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditFarm(farmId: product['id'], ),),);},

      //   onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => FarmDetailScreen(product),),);},


      child:  Container(
        // padding: const EdgeInsets.only(right: 3.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1,color: Colors.orange.shade300)
        ),


        child: Column(

          children: [

            Row(

              children: [
                Icon(Icons.car_repair,color: Colors.orange,),
                Text(
                  'Vehicle Name: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  //     width: 115,
                  child: DriversNamesss(avatar: product['adminemail'],),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.person,color: Colors.orange,),
                Text(
                  'Driver Name: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 90,
                  child: DriverName(email: product['adminemail'],),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.local_laundry_service,color: Colors.orange,),
                Text(
                  'Service Type:',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 115,
                  child: Text(
                    product['servicetype'],
                    style: GoogleFonts.dmSerifDisplay(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,  ),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.monetization_on,color: Colors.orange,),
                Text(
                  'Cost:',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 115,
                  child: Text(
                    'Ksh. ${product['cost'].toString()}',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,  ),
                ),
              ],
            ),
            Row(

              children: [
                Icon(Icons.date_range,color: Colors.orange,),
                Text(
                  'Date: ',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Container(
                  width: 120,
                  child: Text(
                    _formatDateRange(startDate),
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 14, color: Colors.black),
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            if (isCostTooHigh)
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  Text(
                    'High Maintenance Cost ',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                  ),

                ],
              ),
            if (nextMaintenanceDate != null)
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.orange),
                  Text(
                    'Upcoming: ',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Container(
                    width: 120,
                    child: Text(
                      _formatDateRange(nextMaintenanceDate),
                      style: GoogleFonts.dmSerifDisplay(fontSize: 14, color: Colors.black),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),




          ],
        ),
      ),
    );
  }
}

