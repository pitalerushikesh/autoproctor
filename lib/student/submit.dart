import 'package:autoproctor_oexam/admin/results.dart';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/student/mcqslist.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:camera/camera.dart';
import 'package:autoproctor_oexam/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

User user = FirebaseAuth.instance.currentUser;

class Submitted extends StatefulWidget {
  final String classn, name;

  const Submitted(
    this.classn,
    this.name,
  );

  @override
  _SubmittedState createState() => _SubmittedState();
}

class _SubmittedState extends State<Submitted> {
  Query quesStream = FirebaseFirestore.instance.collection("Questions");

  // DataService _dataService = DataService();
  AuthService _authService = AuthService();
  List examdata = [];
  ScrollController _controller = new ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
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
                      );
                    } else {
                      return Container();
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
              height: size.height * 0.05,
            ),
            Text(
              "You have submitted this Exams",
              style: GoogleFonts.nunitoSans(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            Container(
              child: Expanded(
                child: quesList(),
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
  QuesTile({
    @required this.imgUrl,
    @required this.title,
    @required this.desc,
    @required this.quesID,
    @required this.name,
    @required this.classn,
    @required this.time,
  });
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
                  time,
                  cameras,
                ),
              ),
            );
        });
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
