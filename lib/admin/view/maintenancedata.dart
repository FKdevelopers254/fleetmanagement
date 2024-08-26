import 'package:fleetmanagement/admin/add/addmaintenance.dart';
import 'package:fleetmanagement/admin/add/allocatedriver.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dtp;

import 'package:intl/intl.dart';

import '../add/addmodelmt.dart';
import '../widget.dart';

class MaintenanceData extends StatefulWidget {
  const MaintenanceData({Key? key}) : super(key: key);

  @override
  State<MaintenanceData> createState() => _MaintenanceDataState();
}

class _MaintenanceDataState extends State<MaintenanceData> {
  String searchQuery = '';
  bool isSortingAscending = true;
  TextEditingController _textEditingController = TextEditingController();

  late List<DocumentSnapshot> filteredProducts = [];

  DateTime? _startDate;
  DateTime? _endDate;

  void toggleSortOrder() {
    setState(() {
      isSortingAscending = !isSortingAscending;
    });
  }

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


  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarr(foodtitle: 'Maintenance Data'),
        leading: SizedBox(),
        actions: [
          ActionsWidget(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddModelMaintenance(),
              ),
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
            color: Colors.orange,
            textColor: Colors.white,
            onPressed: _pickDateRange,
            child: Text("Select Date Range"),
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 28.0, right: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    color: Colors.deepPurple,
                    textColor: Colors.white,
                    onPressed: _pickDateRange,
                    child: Text(
                      '${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('newmaintenance')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
                      .where((product) => product['vehiclename']
                      .toLowerCase()
                      .contains(searchQuery))
                      .toList();
                  if (_startDate != null && _endDate != null) {
                    filteredProducts = filteredProducts.where((product) {
                      Timestamp timestamp = product['ondate'];
                      DateTime productDate = timestamp.toDate();
                      return productDate.isAfter(_startDate!) &&
                          productDate.isBefore(_endDate!);
                    }).toList();
                  }

                  filteredProducts.sort((a, b) {
                    Timestamp dateA = a['ondate'];
                    Timestamp dateB = b['ondate'];
                    return isSortingAscending
                        ? dateA.compareTo(dateB)
                        : dateB.compareTo(dateA);
                  });



                  return Column(
                    children: [

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = constraints.maxWidth > 800
                                ? 5
                                : 2;
                            return GridView.builder(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 2.0,
                                crossAxisSpacing: 2.0,
                                childAspectRatio: 1.7 / 2,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot product =
                                filteredProducts[index];
                                return AdminproductItem(product: product);
                              },
                            );
                          },
                        ),
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




class AdminproductItem extends StatelessWidget {
  final DocumentSnapshot product;

  const AdminproductItem({required this.product});

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
                Navigator.of(context).pop(false);
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
                Navigator.of(context).pop(true);
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
      await FirebaseFirestore.instance
          .collection('maintenance')
          .doc(product.id)
          .delete();
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
    String day = formattedDate.split(' ')[0];
    String month = formattedDate.split(' ')[1];

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

  @override
  Widget build(BuildContext context) {

    Timestamp timestamp = product['ondate'];
    DateTime onDate = timestamp.toDate();

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle: ${product['vehiclename']}',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Type: ${product['servicetype']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
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
            const SizedBox(height: 4.0),
            Text(
              'Engine Rpm: ${product['enginerpm']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Lubricant Oil pressure: ${product['luboilpressure']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Fuel Pressure: ${product['fuelpressure']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Coolant Pressure: ${product['coolantpressure']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Lubricant Oil Temperature: ${product['luboiltemp']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Coolant Temperature: ${product['coolanttemp']}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),

            const SizedBox(height: 4.0),
            Text(
              'On Date: ${_formatDate(onDate)}',
              style: GoogleFonts.dmSerifDisplay(fontSize: 14),
            ),
            const SizedBox(height: 4.0),


            const SizedBox(height: 8.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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




