import 'dart:async';
import 'package:autoproctor_oexam/first/signin_new.dart';
import 'package:autoproctor_oexam/main.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<CameraDescription> cameras;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    loadData();
  }

  Future<Timer> loadData() async {
    return new Timer(
        Duration(
          seconds: 3,
        ),
        onDoneLoading);
  }

  onDoneLoading() async {
    Navigator.of(context).pushReplacement(
      FadeRoute(
        page: SignInNew(cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // CircleAvatar(
                      //   backgroundColor: Colors.white,
                      //   radius: 70.0,
                      //   child: Image.asset(
                      //     "assets/images/collegenew.png",
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.04,
                      // ),
                      Text(
                        "AutoProctor",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       CircularProgressIndicator(
              //         backgroundColor: Colors.white,
              //       ),
              //       SizedBox(
              //         height: MediaQuery.of(context).size.height * 0.04,
              //       ),
              //       // Center(
              //       //   child: Text(
              //       //     "Before Feeling the form read the Guidelines carefully",
              //       //     style: TextStyle(
              //       //       color: Colors.white,
              //       //       fontSize: 16.0,
              //       //       fontStyle: FontStyle.normal,
              //       //       fontWeight: FontWeight.bold,
              //       //       fontFamily: 'Roboto',
              //       //     ),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
