import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widget.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;

class Results extends StatefulWidget {
  final int notAttempted, total;
  Results({
    @required this.total,
    @required this.notAttempted,
  });
  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  // var data;
  // bool isloaded = false;
  // @override
  // void initState() {
  //   super.initState();
  //   loadData();
  // }

  // loadData() {
  //   FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(_auth.currentUser.email)
  //       .get()
  //       .then((doc) {
  //     var userdata = doc.data();
  //     setState(() {
  //       data = userdata;
  //       isloaded = true;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "You have Attempted",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 14,
              ),
              Text(
                "${widget.total - widget.notAttempted}/${widget.total}",
                style: GoogleFonts.montserrat(
                  fontSize: 25,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Submitted Successfully",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 14,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: blueButton(
                  context: context,
                  label: "Done",
                  buttonWidth: MediaQuery.of(context).size.width / 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
