import 'package:autoproctor_oexam/first/signin_new.dart';
import 'package:autoproctor_oexam/first/splashscreen.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   cameras = await availableCameras();
  // } on CameraException catch (e) {
  //   print('Error: $e.code\nError Message: $e.message');
  // }
  cameras = await availableCameras();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoProctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
