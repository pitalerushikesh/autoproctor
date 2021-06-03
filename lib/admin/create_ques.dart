import 'package:autoproctor_oexam/admin/add_ques.dart';
import 'package:autoproctor_oexam/admin/importcsv.dart';
import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/cupertino.dart';

class CreateQues extends StatefulWidget {
  @override
  _CreateQuesState createState() => _CreateQuesState();
}

class _CreateQuesState extends State<CreateQues> {
  final _formKey = GlobalKey<FormState>();
  String quesImgUrl = "", quesTitle = " ", quesDesc = " ", quesID = " ";

  DataService _dataService = new DataService();
  String time = "1";
  TextEditingController _quesImgUrl;
  bool isLoading = false;
  String _dropdownValue = 'FY B.Sc CS';

  createQuesData(bool i) async {
    _formKey.currentState.save();
    if (quesImgUrl.isEmpty) {
      quesImgUrl =
          "https://firebasestorage.googleapis.com/v0/b/autoproctor-rp07.appspot.com/o/Quepal.jpg?alt=media&token=e5c4221f-4346-4989-b944-70dcd8696442";
    }
    if (quesImgUrl.length == 0) {
      quesImgUrl =
          "https://firebasestorage.googleapis.com/v0/b/autoproctor-rp07.appspot.com/o/Quepal.jpg?alt=media&token=e5c4221f-4346-4989-b944-70dcd8696442";
    }
    if (_formKey.currentState.validate()) {
      quesID = randomAlphaNumeric(16);

      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> quesMap = {
        "qeusID": quesID,
        "quesImgUrl": quesImgUrl,
        "quesTitle": quesTitle,
        "quesDesc": quesDesc,
        "classn": _dropdownValue,
        "time": time,
        "startDateTime": selectedDate,
      };
      await _dataService.addQuesData(quesMap, quesID).then(
        (value) {
          isLoading = false;
          i
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddQuesData(quesID),
                  ),
                )
              : Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImportCSV(quesID),
                  ),
                );
        },
      );
    }
  }

  // Widget _showModalBottomSheet(context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Container(
  //           height: MediaQuery.of(context).copyWith().size.height / 2,
  //           child: Column(
  //             children: <Widget>[
  //               Text(
  //                 selectedDate.toLocal().toString(),
  //               ),
  //               _showCupertinoDatePicker(),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text("Done"),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  // Widget _showCupertinoDatePicker() {
  //   return Expanded(
  //     child: CupertinoDatePicker(
  //       minimumDate: DateTime.now(),
  //       use24hFormat: false,
  //       initialDateTime: DateTime.now(),
  //       onDateTimeChanged: (DateTime newDate) {
  //         setState(() {
  //           selectedDate = newDate;
  //         });
  //         print('2. onDateTimeChanged : $selectedDate');
  //       },
  //       minimumYear: 2010,
  //       maximumYear: 2050,
  //       mode: CupertinoDatePickerMode.dateAndTime,
  //     ),
  //   );
  // }

  DateTime selectedDate = DateTime.now();
  // TimeOfDay selectedEndTime = TimeOfDay.now();
  // DateTime selectedEndDate = DateTime.now();

  // Future<Null> _selectTime(BuildContext context) async {
  //   final DateTime picked_start_date = await showDatePicker(
  //       context: context,
  //       firstDate: DateTime.now(),
  //       lastDate: DateTime(2030),
  //       initialDate: selectedDate,
  //       builder: (BuildContext context, Widget child) {
  //         return MediaQuery(
  //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //           child: child,
  //         );
  //       });
  //   final TimeOfDay picked_time = await showTimePicker(
  //       context: context,
  //       initialTime: selectedTime,
  //       builder: (BuildContext context, Widget child) {
  //         return MediaQuery(
  //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //           child: child,
  //         );
  //       });

  //   if (picked_time != null && picked_time != selectedTime)
  //     setState(() {
  //       selectedTime = picked_time;
  //     });

  //   if (picked_start_date != null && picked_start_date != selectedDate)
  //     setState(() {
  //       selectedDate = picked_start_date;
  //     });

  //   // picked_start_date.print(picked_start_date);
  //   // print(picked_time);
  // }

  // Future<Null> _selectTimeEnd(BuildContext context) async {
  //   final DateTime picked_end_date = await showDatePicker(
  //       context: context,
  //       firstDate: DateTime.now(),
  //       lastDate: DateTime(2030),
  //       initialDate: selectedEndDate,
  //       builder: (BuildContext context, Widget child) {
  //         return MediaQuery(
  //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //           child: child,
  //         );
  //       });
  //   final TimeOfDay picked_end_time = await showTimePicker(
  //       context: context,
  //       initialTime: selectedEndTime,
  //       builder: (BuildContext context, Widget child) {
  //         return MediaQuery(
  //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //           child: child,
  //         );
  //       });

  //   if (picked_end_time != null && picked_end_time != selectedTime)
  //     setState(() {
  //       selectedTime = picked_end_time;
  //     });

  //   if (picked_end_date != null && picked_end_date != selectedDate)
  //     setState(() {
  //       selectedDate = picked_end_date;
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
        ),
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: "",
                        decoration: InputDecoration(
                            hintText: "Quiz Image Url (Optional)"),
                        controller: _quesImgUrl,
                        onChanged: (value) {
                          setState(() {
                            quesImgUrl = value;
                          });
                        },
                        onSaved: (newValue) => quesImgUrl = newValue,
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      TextFormField(
                        validator: (val) =>
                            val.isEmpty ? "Enter Quiz Title" : null,
                        decoration: InputDecoration(hintText: "Quiz Title"),
                        onChanged: (val) {
                          setState(() {
                            quesTitle = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      TextFormField(
                        validator: (val) =>
                            val.isEmpty ? "Enter Quiz Description" : null,
                        decoration:
                            InputDecoration(hintText: "Quiz Description"),
                        onChanged: (val) {
                          setState(() {
                            quesDesc = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Select Class",
                            style: GoogleFonts.roboto(
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          ),
                          DropdownButton<String>(
                            value: _dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.green),
                            underline: Container(
                              height: 2,
                              color: Colors.green,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                _dropdownValue = newValue;
                              });
                            },
                            items: <String>[
                              'FY B.Sc CS',
                              'SY B.Sc CS',
                              'TY B.Sc CS',
                              'M.Sc CS',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                  value: time,
                                  items: [
                                    DropdownMenuItem(
                                      child: Text("1 minute"),
                                      value: "1",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("30 minutes"),
                                      value: "30",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("45 minutes"),
                                      value: "45",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("60 minutes"),
                                      value: "60",
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      time = value;
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Text(
                        selectedDate.day.toString() +
                            "-" +
                            selectedDate.month.toString() +
                            "-" +
                            selectedDate.year.toString() +
                            "\n" +
                            selectedDate.hour.toString() +
                            ":" +
                            selectedDate.minute.toString() +
                            ":" +
                            selectedDate.second.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28.0,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            onChanged: (date) {
                              print('change $date in time zone ' +
                                  date.timeZoneOffset.inHours.toString());
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            onConfirm: (date) {
                              print('confirm $date');
                              setState(() {
                                selectedDate = date;
                              });
                              print(selectedDate);
                            },
                            minTime: DateTime.now(),
                            currentTime: DateTime.now(),
                            locale: LocaleType.en,
                          );
                        },
                        child: Text("Start Time"),
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        height: 140,
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                quesImgUrl == ""
                                    ? "https://firebasestorage.googleapis.com/v0/b/autoproctor-rp07.appspot.com/o/Quepal.jpg?alt=media&token=e5c4221f-4346-4989-b944-70dcd8696442"
                                    : quesImgUrl,
                                width: MediaQuery.of(context).size.width - 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black26,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    quesTitle,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 6,
                                  // ),
                                  Divider(
                                    color: Colors.white,
                                    indent: 60,
                                    endIndent: 60,
                                  ),
                                  Text(
                                    quesDesc,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              createQuesData(true);
                            },
                            child: blueButton(
                              context: context,
                              label: "Add Manually",
                              buttonWidth: size.width / 2 * 0.8,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          GestureDetector(
                            onTap: () {
                              createQuesData(false);
                            },
                            child: blueButton(
                              context: context,
                              label: "Import CSV",
                              buttonWidth: size.width / 2 * 0.8,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
