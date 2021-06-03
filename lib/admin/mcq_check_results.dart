import 'package:autoproctor_oexam/admin/results.dart';
import 'package:autoproctor_oexam/models/ques_model.dart';
import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class McqsResults extends StatefulWidget {
  final String quesID;
  McqsResults(this.quesID);
  @override
  _McqsResultsState createState() => _McqsResultsState();
}

int total = 0;
int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
// bool status = false;

Stream infoStream;

class _McqsResultsState extends State<McqsResults> {
  DataService _dataService = new DataService();
  QuerySnapshot _questionsSnapshot;

  bool _isLoading = true;

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
    super.dispose();
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
        iconTheme: IconThemeData(
          color: Colors.black54,
        ),
      ),
      body: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: <Widget>[
                Container(
                  child: InfoHeaderAdmin(
                    length: _questionsSnapshot.docs.length,
                  ),
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
                                return QuesPlayTileAdmin(
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
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Results(
                total: total,
                notAttempted: _notAttempted,
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoHeaderAdmin extends StatefulWidget {
  final int length;

  InfoHeaderAdmin({@required this.length});

  @override
  _InfoHeaderAdminState createState() => _InfoHeaderAdminState();
}

class _InfoHeaderAdminState extends State<InfoHeaderAdmin> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: infoStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  height: 63,
                  margin: EdgeInsets.only(left: 14),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: <Widget>[
                      NoOfQuestionTileAdmin(
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
                        height: 5,
                      ),
                      NoOfQuestionTileAdmin(
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

class QuesPlayTileAdmin extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  QuesPlayTileAdmin({
    this.questionModel,
    this.index,
  });
  @override
  _QuesPlayTileAdminState createState() => _QuesPlayTileAdminState();
}

class _QuesPlayTileAdminState extends State<QuesPlayTileAdmin> {
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
            child: McqsTileAdmin(
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
            child: McqsTileAdmin(
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
            child: McqsTileAdmin(
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
            child: McqsTileAdmin(
              option: "D",
              description: widget.questionModel.option4,
              correctAnswer: widget.questionModel.correctoption,
              optionSelected: optionSelected,
            ),
          ),
          ElevatedButton(
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
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class McqsTileAdmin extends StatefulWidget {
  final String option, description, correctAnswer, optionSelected;
  McqsTileAdmin(
      {this.option, this.description, this.correctAnswer, this.optionSelected});
  @override
  _McqsTileAdminState createState() => _McqsTileAdminState();
}

class _McqsTileAdminState extends State<McqsTileAdmin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        // horizontal: 20,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                style: BorderStyle.solid,
                color: widget.description == widget.optionSelected
                    ? Colors.green
                    // widget.optionSelected == widget.correctAnswer
                    //     ? Colors.green.withOpacity(0.7)
                    //     : Colors.red.withOpacity(0.7)
                    : Colors.grey,
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              "${widget.option}",
              style: GoogleFonts.roboto(
                fontSize: 20.0,
                fontWeight: widget.optionSelected == widget.description
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: widget.optionSelected == widget.description
                    ? Colors.green
                    // widget.optionSelected == widget.correctAnswer
                    //     ? Colors.green.withOpacity(0.7)
                    //     : Colors.red.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            widget.description,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: widget.optionSelected == widget.description
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: widget.optionSelected == widget.description
                  ? Colors.green
                  // widget.optionSelected == widget.correctAnswer
                  //     ? Colors.green.withOpacity(0.7)
                  //     : Colors.red.withOpacity(0.7)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NoOfQuestionTileAdmin extends StatefulWidget {
  final String text;
  final int number;

  NoOfQuestionTileAdmin({this.text, this.number});

  @override
  _NoOfQuestionTileAdminState createState() => _NoOfQuestionTileAdminState();
}

class _NoOfQuestionTileAdminState extends State<NoOfQuestionTileAdmin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14)),
                color: Colors.blue),
            child: Text(
              "${widget.number}",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                color: Colors.black54),
            child: Text(
              widget.text,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
