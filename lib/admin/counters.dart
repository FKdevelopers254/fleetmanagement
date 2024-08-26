import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehiclesCounter extends StatelessWidget {


  // const PrayerCellsCounter({super.key});
  VehiclesCounter();
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('availability', isEqualTo: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class VehiclesTripsCounter extends StatelessWidget {
final String vehicleId;


  // const PrayerCellsCounter({super.key});
  VehiclesTripsCounter({ required this.vehicleId});
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .where('vehicleid', isEqualTo: vehicleId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration:BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)
              ),child: Padding(
            padding: const EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text('0',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
          ));
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class RouteVehiclesCounter extends StatelessWidget {
final String routeId;


  // const PrayerCellsCounter({super.key});
RouteVehiclesCounter({ required this.routeId});
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('routeid', isEqualTo: routeId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration:BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)
              ),child: Padding(
            padding: const EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text('0',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
          ));
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class RoutesDriverCounter extends StatelessWidget {
final String routeId;


  // const PrayerCellsCounter({super.key});
RoutesDriverCounter({ required this.routeId});
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('driverroutes')
          .where('routeid', isEqualTo: routeId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration:BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)
              ),child: Padding(
            padding: const EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text('0',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
          ));
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class RouteTripsCounter extends StatelessWidget {
final String routeId;


  // const PrayerCellsCounter({super.key});
RouteTripsCounter({ required this.routeId});
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .where('routeid', isEqualTo: routeId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration:BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)
              ),child: Padding(
            padding: const EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text('0',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
          ));
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class DriverTripsCounter extends StatelessWidget {
final String email;


  // const PrayerCellsCounter({super.key});
DriverTripsCounter({ required this.email});
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration:BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)
              ),child: Padding(
            padding: const EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text('0',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
          ));
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}
class VehiclesFuelCounter extends StatelessWidget {
  final String vehicleId;

  VehiclesFuelCounter({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fuel')
          .where('vehicleid', isEqualTo: vehicleId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(90)),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Text(
                  '0',
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ));
        }
        double totalAmount = 0;
        for (var doc in snapshot.data!.docs) {
          totalAmount += doc['amount']; // Assuming 'amount' is the field name
        }
        return Container(
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)),
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(
                '$totalAmount',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ));
      },
    );
  }
}
class RoutesCounter extends StatelessWidget {


  // const PrayerCellsCounter({super.key});
  RoutesCounter();
  //CategoriesCounter({required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('routes')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }
        int count = snapshot.data!.docs.length;
        return Container(
            decoration:BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(90)
            ),child: Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
          child: Text('$count',style: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w700),),
        ));
      },
    );
  }
}