import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:autoproctor_oexam/admin/results.dart';
import 'package:autoproctor_oexam/models/ques_model.dart';
import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/mcqslist_widget.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

User user = FirebaseAuth.instance.currentUser;

class McQsList extends StatefulWidget {
  final List<CameraDescription> cameras;

  final String quesID, name, title, classn;
  final int time;
  McQsList(
    this.quesID,
    this.name,
    this.title,
    this.classn,
    this.time,
    this.cameras,
  );
  @override
  _McQsListState createState() => _McQsListState();
}

List<String> img_urls = [];
int total = 0;
int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
int switchAppWarning = 0;
Stream infoStream;

class _McQsListState extends State<McQsList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.paused) {
      if (switchAppWarning <= 1) {
        _onSwitchApp();
        switchAppWarning = switchAppWarning + 1;
      } else {
        _onCopied();
        switchAppWarning = 0;
        Navigator.pop(context, false);
      }
    }
  }

  Future<bool> _onBackSubmit() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // alert on back button pressed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        title: Text(
          "Warning",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Cannot Leave Exam Session without submitting !",
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                "OK",
              ),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ],
      ),
    );
  }

  _onCopied() {
    _dataService.addResultsData(
      correct: _correct,
      incorrect: _incorrect,
      notAttempted: _notAttempted,
      total: total,
      quesID: widget.quesID,
      name: widget.name,
      title: widget.title,
      classn: widget.classn,
      switchAppWarning: switchAppWarning,
      uid: user.uid,
      img_urls: img_urls,
    );
    dispose();
    img_urls = [];
    Navigator.pushReplacement(
      context,
      FadeRoute(
        page: Results(total: total, notAttempted: _notAttempted),
      ),
    );
  }

  Future<bool> _onSwitchApp() {
    print(switchAppWarning);
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
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                "You are trying to switch Apps / Copy ",
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(
                "$switchAppWarning time/s",
                style: GoogleFonts.ubuntu(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                "OK",
              ),
              onPressed: () {
                Navigator.pop(context, false);
              }),
        ],
      ),
    );
  }

  DataService _dataService = new DataService();
  QuerySnapshot _questionsSnapshot;

  bool _isLoading = true;

  bool _isButtonDisabled = false;

  // QuerySnapshot get questionsSnapshot => _questionsSnapshot;

  // set questionsSnapshot(QuerySnapshot questionsSnapshot) {
  //   _questionsSnapshot = questionsSnapshot;
  // }

  QuestionModel _getQuestionModelFromDataSnapshot(
      DocumentSnapshot _questionSnapshot) {
    QuestionModel _questionModel = new QuestionModel();
    _questionModel.question = _questionSnapshot.data()["question"];

    /// shuffling the options
    List<String> options = [
      _questionSnapshot.data()["option1"],
      _questionSnapshot.data()["option2"],
      _questionSnapshot.data()["option3"],
      _questionSnapshot.data()["option4"],
    ];
    options.shuffle();
    _questionModel.option1 = options[0];
    _questionModel.option2 = options[1];
    _questionModel.option3 = options[2];
    _questionModel.option4 = options[3];
    _questionModel.correctoption = _questionSnapshot.data()["option1"];
    _questionModel.answered = false;

    return _questionModel;
  }

  @override
  void dispose() {
    infoStream = null;
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();

    super.dispose();
  }

  CameraController controller;

  loadCamera() async {
    File image;
    var file;

    final directory =
        (await getExternalStorageDirectory()).path; //from path_provide package
    String fileName = "Students_Face.jpg";
    String path = '$directory' + "/";
    print(path);
    controller.setFlashMode(FlashMode.off);
    controller.takePicture().then(
      (value) {
        value.saveTo(path + fileName);
        file = value;
      },
    );
    image = File(path + fileName);
    final mlimage = FirebaseVisionImage.fromFilePath("$path" + "$fileName");
    final facedetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await facedetector.processImage(mlimage);
    print(faces);
    print("*" * 100);
    if (faces.length != 1) {
      var url = Uri.parse(
          "https://api.imgbb.com/1/upload?key=bcbb3671f0c1cebbffc6c601e624319d");
      var req = http.MultipartRequest("POST", url);

      if (image != null) {
        req.files.add(http.MultipartFile(
            'image', image.readAsBytes().asStream(), image.lengthSync(),
            filename: fileName));
      }

      try {
        var res = await req.send();
        res.stream.transform(utf8.decoder).listen((value) {
          print(value);
          var output = json.decode(value);
          print("#" * 100);

          print(output["data"]["url"]);
          print(output["data"]["display_url"]);
          img_urls.add(output["data"]["display_url"]);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  // bool _isDetecting = false;

  // loadCamera() {
  //   controller.startImageStream((image) async {
  //     if (_isDetecting) return;
  //     _isDetecting = true;
  //     try {
  //       final mlimage = FirebaseVisionImage.;
  //       final facedetector = FirebaseVision.instance.faceDetector();
  //       List<Face> faces = await facedetector.processImage(image);
  //     } catch (e) {
  //       // await handleExepction(e)
  //     } finally {
  //       _isDetecting = false;
  //     }
  //   });
  // }

  secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
  }

  @override
  void initState() {
    print("${widget.quesID}");
    _dataService.getQuestionsData(widget.quesID).then((value) {
      _questionsSnapshot = value;
      _notAttempted = _questionsSnapshot.docs.length;
      _correct = 0;
      _incorrect = 0;
      _isLoading = false;
      total = _questionsSnapshot.docs.length;
      print("$total this is total");
      setState(() {});
    });
    if (infoStream == null) {
      infoStream = Stream<List<int>>.periodic(Duration(milliseconds: 100), (x) {
        print("this is x $x");
        return [_correct, _incorrect];
      });
    }

    super.initState();
    secureScreen();
    controller = new CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.setExposureMode(ExposureMode.auto);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: WillPopScope(
        onWillPop: () => _onBackSubmit(),
        child: _isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: size.width * 0.4,
                        child: SlideCountdownClock(
                          duration: Duration(minutes: widget.time),
                          slideDirection: SlideDirection.Up,
                          separator: ":",
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          onDone: () {
                            print("Not Working Nitish's code");
                            if (ModalRoute.of(context).isActive) {
                              _onCopied();
                              print("Yes");
                            }
                          },
                          onTwenty: () {
                            if (ModalRoute.of(context).isActive) {
                              loadCamera();
                              print("Ho raha he");
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 100.0,
                          width: 100,
                          child: (!controller.value.isInitialized)
                              ? Container(
                                  child: Center(child: Text("Nhi Chala")),
                                )
                              : Container(
                                  child: CameraPreview(controller),
                                ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InfoHeader(
                    length: _questionsSnapshot.docs.length,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _questionsSnapshot == null
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: _questionsSnapshot.docs.length,
                                itemBuilder: (context, index) {
                                  return QuesPlayTile(
                                    questionModel:
                                        _getQuestionModelFromDataSnapshot(
                                      _questionsSnapshot.docs[index],
                                    ),
                                    index: index,
                                  );
                                }),
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          _isButtonDisabled ? Icons.not_interested : Icons.check,
        ),
        backgroundColor: _isButtonDisabled ? Colors.red : Colors.blue,
        onPressed: () => _isButtonDisabled
            ? null
            : showModalBottomSheet(
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(
                      20.0,
                    ),
                  ),
                  side: BorderSide(),
                ),
                isDismissible: false,
                context: context,
                builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        "Do you want to really Submit!!!",
                        style: GoogleFonts.roboto(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        widget.classn,
                        style: GoogleFonts.ubuntu(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        widget.title,
                        style: GoogleFonts.ubuntu(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Attempted",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          Text(
                            "${total - _notAttempted}",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Total",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          Text(
                            total.toString(),
                            style: GoogleFonts.ubuntu(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            child: Text(
                              "No",
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Yes",
                            ),
                            onPressed: () => _onCopied(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class InfoHeader extends StatefulWidget {
  final int length;

  InfoHeader({@required this.length});

  @override
  _InfoHeaderState createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: infoStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  height: 80,
                  margin: EdgeInsets.only(left: 14),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: <Widget>[
                      NoOfQuestionTile(
                        text: "Total",
                        number: widget.length,
                      ),
                      // NoOfQuestionTile(
                      //   text: "Correct",
                      //   number: _correct,
                      // ),
                      // NoOfQuestionTile(
                      //   text: "Incorrect",
                      //   number: _incorrect,
                      // ),
                      SizedBox(
                        height: 10.0,
                      ),
                      NoOfQuestionTile(
                        text: "Not Attempted",
                        number: _notAttempted,
                      ),
                    ],
                  ),
                )
              : Container();
        });
  }
}

class QuesPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  QuesPlayTile({
    this.questionModel,
    this.index,
  });
  @override
  _QuesPlayTileState createState() => _QuesPlayTileState();
}

class _QuesPlayTileState extends State<QuesPlayTile> {
  String optionSelected = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Q${widget.index + 1} ${widget.questionModel.question}",
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          // McqsTile(option, description, correctAnswer, optionSelected)
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //correct
                if (widget.questionModel.option1 ==
                    widget.questionModel.correctoption) {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                }
              }
            },
            child: McqsTile(
              option: "A",
              description: widget.questionModel.option1,
              correctAnswer: widget.questionModel.correctoption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //correct
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctoption) {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  print("${widget.questionModel.correctoption}");

                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                }
              }
            },
            child: McqsTile(
              option: "B",
              description: widget.questionModel.option2,
              correctAnswer: widget.questionModel.correctoption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //correct
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctoption) {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                }
              }
            },
            child: McqsTile(
              option: "C",
              description: widget.questionModel.option3,
              correctAnswer: widget.questionModel.correctoption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //correct
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctoption) {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                }
              }
            },
            child: McqsTile(
              option: "D",
              description: widget.questionModel.option4,
              correctAnswer: widget.questionModel.correctoption,
              optionSelected: optionSelected,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 45.0,
              width: 100.0,
              child: ElevatedButton(
                onPressed: () {
                  if (optionSelected.isNotEmpty) {
                    if (optionSelected == widget.questionModel.correctoption) {
                      _correct = _correct - 1;
                    } else {
                      _incorrect = _incorrect - 1;
                    }
                    widget.questionModel.answered = false;
                    _notAttempted = _notAttempted + 1;
                    optionSelected = "";
                  }

                  setState(() {});
                },
                child: Text("Clear"),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// Future<bool> _onsubmitResult() {
//   return showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       // alert on back button pressed
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(
//           20.0,
//         ),
//       ),
//       title: Text(
//         "Warning",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             Text(
//               "Do you want to really Submit!!!",
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.02,
//             ),
//             Text(
//               widget.classn,
//               style: GoogleFonts.ubuntu(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.02,
//             ),
//             Text(
//               widget.title,
//               style: GoogleFonts.ubuntu(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: Text(
//             "No",
//           ),
//           onPressed: () {
//             Navigator.pop(context, false);
//           },
//         ),
//         TextButton(
//           child: Text(
//             "Yes",
//           ),
//           onPressed: () {
//             _dataService.addResultsData(
//               correct: _correct,
//               incorrect: _incorrect,
//               notAttempted: _notAttempted,
//               total: total,
//               quesID: widget.quesID,
//               name: widget.name,
//               title: widget.title,
//               classn: widget.classn,
//               switchAppWarning: switchAppWarning,
//             );
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     Results(total: total, notAttempted: _notAttempted),
//               ),
//             );
//           },
//         ),
//       ],
//     ),
//   );
// }

// _onsubmitResultSheet() {
//   return showBottomSheet(
//     context: context,
//     builder: (context) => SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Text(
//             "Do you want to really Submit!!!",
//           ),
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.02,
//           ),
//           Text(
//             widget.classn,
//             style: GoogleFonts.ubuntu(
//               fontSize: 15.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.02,
//           ),
//           Text(
//             widget.title,
//             style: GoogleFonts.ubuntu(
//               fontSize: 15.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Row(
//             children: <Widget>[
//               TextButton(
//                 child: Text(
//                   "No",
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context, false);
//                 },
//               ),
//               TextButton(
//                 child: Text(
//                   "Yes",
//                 ),
//                 onPressed: () {
//                   _dataService.addResultsData(
//                     correct: _correct,
//                     incorrect: _incorrect,
//                     notAttempted: _notAttempted,
//                     total: total,
//                     quesID: widget.quesID,
//                     name: widget.name,
//                     title: widget.title,
//                     classn: widget.classn,
//                     switchAppWarning: switchAppWarning,
//                   );
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           Results(total: total, notAttempted: _notAttempted),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           )
//         ],
//       ),
//     ),
//   );
// }

// Future<void> pickFace() async {
//   bool _has;
//   File _image;
//   String displayMsg = 'loading';
//   final picker = ImagePicker();
//   final pickedFile = await picker.getImage(
//     source: ImageSource.gallery,
//     // maxWidth: 1024,
//     // maxHeight: 1024,
//     // imageQuality: 50,
//   );

//   _image = File(pickedFile.path);
//   // Platform messages may fail, so we use a try/catch PlatformException.
//   try {
//     print('start check');
//     _has = await ImageFace.hasFace();
//     print('end check');
//     displayMsg = _has ? 'has face' : 'no face';
//   } on PlatformException {
//     displayMsg = 'Failed to get faces';
//   }

//   // If the widget was removed from the tree while the asynchronous platform
//   // message was in flight, we want to discard the reply rather than calling
//   // setState to update our non-existent appearance.
//   if (!mounted) return;
// }
