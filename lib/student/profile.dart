import 'dart:io';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  final String name, classn, email;

  const Profile(
    this.name,
    this.classn,
    this.email,
  );
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _status = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  AuthService _authService = new AuthService();

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        // alert on back button pressed
        title: Text(
          "Warning",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "You will be logged out of Session!",
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Cancel",
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              "OK",
            ),
            onPressed: () {
              _authService.signOut().then(
                    (value) => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  );
            },
          ),
        ],
      ),
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.Logout) {
      _onBackPressed();
      print("Logged Out");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: appBar(context),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black54,
        ),
        actions: [
          PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.power_settings_new_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        Text("Logout"),
                      ],
                    ),
                  );
                }).toList();
              }),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              "Profile",
              style: GoogleFonts.baloo(
                fontSize: 28.0,
                color: Colors.green,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: profileField(
                name: "Name",
                data: widget.name,
                status: !_status,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: profileField(
                name: "Email",
                data: widget.email,
                status: !_status,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: profileField(
                name: "Class",
                data: widget.classn,
                status: !_status,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}

Widget profileField({
  @required String data,
  @required String name,
  @required bool status,
}) {
  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
      20.0,
    )),
    elevation: 5.0,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        20.0,
        15.0,
        20.0,
        20.0,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(
            name,
            style: GoogleFonts.ubuntu(
              color: Colors.grey,
            ),
          ),
          TextFormField(
            initialValue: data,
            enabled: status,
            decoration: InputDecoration(
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 2.0,
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    ),
  );
}

class Constants {
  static const String Logout = "Logout";

  static const Set<String> choices = <String>{
    Logout,
  };
}
