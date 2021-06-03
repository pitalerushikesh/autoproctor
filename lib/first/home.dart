import 'package:autoproctor_oexam/admin/create_ques.dart';
import 'package:autoproctor_oexam/admin/mcq_check_results.dart';
import 'package:autoproctor_oexam/admin/resuts_stdlist.dart';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AuthService _authService = AuthService();

  // AnimationController _animationController;

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

  Future<bool> _onLongTap(DocumentSnapshot snapshot) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // alert on back button pressed
        title: Text(
          "Warning",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ?",
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "No",
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              "Yes",
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Questions")
                  .doc(snapshot.data()["qeusID"])
                  .collection("mcqs")
                  .get()
                  .then((value) {
                for (var data in value.docs) {
                  FirebaseFirestore.instance
                      .collection("Questions")
                      .doc(snapshot.data()["qeusID"])
                      .collection("mcqs")
                      .doc(data.id)
                      .delete()
                      .then((value) {
                    FirebaseFirestore.instance
                        .collection("Questions")
                        .doc(snapshot.data()["qeusID"])
                        .delete();
                  });
                }
              });
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  DataService _dataService = DataService();
  Stream quesStream;

  Widget quesListAdmin() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: StreamBuilder(
        stream: quesStream,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return !snapshot.hasData
                        ? Container(
                            child: Center(
                              child: Text(
                                "No Data",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 35.0,
                                ),
                              ),
                            ),
                          )
                        : FocusedMenuHolder(
                            onPressed: () {},
                            menuItems: <FocusedMenuItem>[
                              FocusedMenuItem(
                                trailingIcon: Icon(Icons.open_in_new_outlined,
                                    color: Colors.green),
                                title: Text("Open"),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => McqsResults(
                                                snapshot.data.docs[index]
                                                    .data()["qeusID"],
                                              )));
                                },
                              ),
                              FocusedMenuItem(
                                  trailingIcon:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text("Delete"),
                                  onPressed: () =>
                                      _onLongTap(snapshot.data.docs[index])),
                            ],
                            child: QuesTileAdmin(
                              quesID:
                                  snapshot.data.docs[index].data()["qeusID"],
                              imgUrl: snapshot.data.docs[index]
                                  .data()["quesImgUrl"],
                              title:
                                  snapshot.data.docs[index].data()["quesTitle"],
                              desc:
                                  snapshot.data.docs[index].data()["quesDesc"],
                            ),
                          );
                  });
        },
      ),
    );
  }

  @override
  void initState() {
    _dataService.getQuesData().then((val) {
      setState(() {
        quesStream = val;
      });
    });
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 260),
    // );

    // final curvedAnimation =
    //     CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    // _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black54,
        ),
      ),
      body: WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(child: quesListAdmin()),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        /// both default to 16
        marginEnd: 18,
        marginBottom: 20,
        icon: Icons.menu,
        activeIcon: Icons.close,
        buttonSize: 75.0,
        visible: true,
        closeManually: false,
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        // orientation: SpeedDialOrientation.Up,
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.add,
              color: Colors.blue,
            ),
            backgroundColor: Colors.white,
            label: 'Create',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateQues(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            backgroundColor: Colors.white,
            label: 'Results',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultList(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.power_settings_new,
              color: Colors.red,
            ),
            backgroundColor: Colors.white,
            label: 'Logout',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              _onBackPressed();
            },
          ),
        ],
      ),
    );
  }
}

class QuesTileAdmin extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String desc;
  final String quesID;

  QuesTileAdmin({
    @required this.imgUrl,
    @required this.title,
    @required this.desc,
    @required this.quesID,
  });
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 140,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imgUrl,
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
                  title,
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
                  desc,
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
    );
  }
}

// Future<bool> _onLongTap() {
//   return showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       // alert on back button pressed
//       title: Text(
//         "Warning",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: Text(
//         "Are you sure you want to delete ?",
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: Text(
//             "No",
//           ),
//           onPressed: () => Navigator.pop(context, false),
//         ),
//         TextButton(
//           child: Text(
//             "Yes",
//           ),
//           onPressed: () {
//             FirebaseFirestore.instance
//                 .collection("Questions")
//                 .doc(quesID)
//                 .collection("mcqs")
//                 .get()
//                 .then((value) {
//               for (var data in value.docs) {
//                 FirebaseFirestore.instance
//                     .collection("Questions")
//                     .doc(quesID)
//                     .collection("mcqs")
//                     .doc(data.id)
//                     .delete()
//                     .then((value) {
//                   FirebaseFirestore.instance
//                       .collection("Questions")
//                       .doc(quesID)
//                       .delete();
//                 });
//               }
//             });
//             Navigator.pop(context, false);
//           },
//         ),
//       ],
//     ),
//   );
// }
