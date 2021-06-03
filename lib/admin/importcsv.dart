import 'dart:convert';
import 'dart:io';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImportCSV extends StatefulWidget {
  final String quesID;
  ImportCSV(
    this.quesID,
  );
  @override
  _ImportCSVState createState() => _ImportCSVState();
}

class _ImportCSVState extends State<ImportCSV> {
  DataService _dataService = new DataService();
  bool dataAdded = false;
  String filename;
  List list;
  AuthService _authService = AuthService();
  loadfile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;

      final input = new File(file.path).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(new CsvToListConverter())
          .toList();
      fields.removeAt(0);
      setState(() {
        list = fields;
      });
      print(fields);
    }
  }

  addtoFirebase(BuildContext context) {
    int count = 0;
    for (var item in list) {
      count += 1;
      Map<String, String> questionMap = {
        "question": item[0],
        "option1": item[1],
        "option2": item[2],
        "option3": item[3],
        "option4": item[4],
      };
      _dataService.addQuestionData(questionMap, widget.quesID);
    }
    setState(() {
      dataAdded = true;
    });
  }

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
          "Alert",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "You have To Add Questions!",
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "OK",
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Format For CSV File",
                    style: GoogleFonts.ubuntu(
                      color: Colors.green[900],
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 4.0,
                            color: Colors.black,
                          ),
                          top: BorderSide(
                            width: 4.0,
                            color: Colors.black,
                          ),
                          left: BorderSide(
                            width: 4.0,
                            color: Colors.black,
                          ),
                          right: BorderSide(
                            width: 4.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      child: Image.asset("assets/images/csvExample.png")),
                ],
              ),
              list == null
                  ? SizedBox(
                      height: size.height * 0.04,
                      width: size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: loadfile,
                        child: Text('Load CSV'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: size.height * 0.04,
                      width: size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          addtoFirebase(context);
                          Future.delayed(Duration(milliseconds: 500))
                              .then((value) => Navigator.pop(context));
                        },
                        child: Text("Add to Database"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600],
                        ),
                      ),
                    ),
              list == null
                  ? Text(
                      "No File Selected",
                      style: GoogleFonts.ubuntu(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    )
                  : Text(
                      "Total Records : ${list.length}",
                      style: GoogleFonts.ubuntu(
                        fontSize: 20.0,
                        color: Colors.green,
                      ),
                    ),
              dataAdded
                  ? Text(
                      "Records Added to Database",
                      style: GoogleFonts.ubuntu(
                        fontSize: 20.0,
                        color: Colors.green,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
