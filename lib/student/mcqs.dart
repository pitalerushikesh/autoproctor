import 'package:permission_handler/permission_handler.dart';
import 'package:autoproctor_oexam/admin/results.dart';
import 'package:autoproctor_oexam/main.dart';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/student/mcqslist.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

User user = FirebaseAuth.instance.currentUser;

class McQuestions extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String classn, name;

  McQuestions(
    this.classn,
    this.name,
    this.cameras,
  );
  @override
  _McQuestionsState createState() => _McQuestionsState();
}

class _McQuestionsState extends State<McQuestions> {
  // static String classname;
  Query quesStream = FirebaseFirestore.instance.collection("Questions");

  // DataService _dataService = DataService();
  AuthService _authService = AuthService();
  List examdata = [];
  ScrollController _controller = new ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  DateTime startDateTime;
  @override
  void initState() {
    super.initState();
    loaddata();
    _controller.addListener(() {
      double value = _controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = _controller.offset > 50;
      });
    });
  }

  loaddata() {
    FirebaseFirestore.instance
        .collection("Students_results")
        .where('uid', isEqualTo: user.uid)
        .get()
        .then(
      (value) {
        var data = value.docs.toList();
        for (var i in data) {
          setState(() {
            examdata.add(i.id);
            print(i.id);
          });
        }
        print("loaded");
      },
    );
  }

  Widget quesList() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: StreamBuilder(
        stream:
            quesStream.where("classn", isEqualTo: widget.classn).snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.builder(
                  controller: _controller,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    print(widget.classn);
                    if (examdata
                        .contains(user.email + snapshot.data.docs[index].id)) {
                      return Container();
                    } else {
                      return QuesTile(
                        quesID: snapshot.data.docs[index].data()["qeusID"],
                        imgUrl: snapshot.data.docs[index].data()["quesImgUrl"],
                        title: snapshot.data.docs[index].data()["quesTitle"],
                        desc: snapshot.data.docs[index].data()["quesDesc"],
                        name: widget.name,
                        classn: widget.classn,
                        time: int.parse(
                          snapshot.data.docs[index].data()["time"],
                        ),
                        startDateTime: snapshot.data.docs[index]
                            .data()["startDateTime"]
                            .toDate(),
                      );
                    }
                  });
        },
      ),
    );
  }

  // @override
  // void initState() {
  //   setState(() {
  //     classname = widget.classn;
  //   });
  //   super.initState();
  // }

  // @override
  // void initState() {
  //   _dataService.getQuesData().then((val) {
  //     setState(() {
  //       quesStream = val;
  //     });
  //   });
  //   super.initState();
  // }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: appBar(context),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height * 0.07,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                      ),
                      child: Text(
                        "Hello,",
                        style: GoogleFonts.montserrat(
                          fontSize: 25.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                      ),
                      child: Text(
                        widget.name,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            Container(
              child: Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Your tests for today.",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    quesList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuesTile extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String desc;
  final String quesID;
  final String name;
  final String classn;
  final int time;
  final DateTime startDateTime;
  QuesTile({
    @required this.imgUrl,
    @required this.title,
    @required this.desc,
    @required this.quesID,
    @required this.name,
    @required this.classn,
    @required this.time,
    @required this.startDateTime,
  });
  User user = FirebaseAuth.instance.currentUser;
  Future<bool> _cameraPerm(
    BuildContext context,
    int final_time,
  ) {
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
          "All The Best!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                "Are You Ready!",
              ),
              Text(
                "Rule 1 : Student must not leave the exam application while the exam is being conducted",
              ),
              Text(
                "Rule 2 : Student must not leave the exam application while the exam is being conducted",
              ),
              Text(
                "Rule 3 : Student must not leave the exam application while the exam is being conducted",
              ),
              Text(
                "Rule 4 : Student must not leave the exam application while the exam is being conducted",
              ),
              Text(
                "Rule 5 : Student must not leave the exam application while the exam is being conducted",
              ),
            ],
          ),
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
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("Students_results")
                  .doc(user.email + quesID)
                  .get()
                  .then((doc) {
                if (doc.exists)
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: Results(
                        total: doc.data()['total'],
                        notAttempted: doc.data()['notAttempted'],
                      ),
                    ),
                  );
                else
                  Navigator.pushReplacement(
                    context,
                    FadeRoute(
                      page: McQsList(
                        quesID,
                        name,
                        title,
                        classn,
                        final_time,
                        cameras,
                      ),
                    ),
                  );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _showModalBottomSheet(context, String text) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 4,
            child: Center(
              child: Text(text),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await Permission.camera.request().isGranted) {
          if (DateTime.now().difference(startDateTime).inMinutes >= 0 &&
              DateTime.now().difference(startDateTime).inMinutes <=
                  (time / 2)) {
            int final_time =
                time - DateTime.now().difference(startDateTime).inMinutes;
            print(DateTime.now().difference(startDateTime).inMinutes);
            _cameraPerm(
              context,
              final_time,
            );
          } else if (DateTime.now().difference(startDateTime).inMinutes >=
              (time / 2)) {
            print(startDateTime);
            print(DateTime.now().difference(startDateTime).inMinutes);
            _showModalBottomSheet(context, "Chal Be Exam Khatam Ho gaya");
          } else {
            _showModalBottomSheet(context, "Rukja Bhai Sabar Kar");
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
        ),
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
      ),
    );
  }
}
