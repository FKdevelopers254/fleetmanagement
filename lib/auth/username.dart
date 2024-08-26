import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserName extends StatefulWidget {
  const UserName({Key? key}) : super(key: key);

  @override
  State<UserName> createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text('Data not found');
        }

        String image = snapshot.data!.docs[0].get('firstname');

      //  String number = snapshot.data!.docs[0].get('age').toString();
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$image',style: GoogleFonts.aBeeZee(color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),),
            Text('Edit Profile',style: GoogleFonts.aBeeZee(color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),),

          ],
        );
      },
    );
  }
}
