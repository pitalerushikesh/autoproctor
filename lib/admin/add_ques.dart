import 'package:autoproctor_oexam/services/database.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:flutter/material.dart';

class AddQuesData extends StatefulWidget {
  final String quesID;
  AddQuesData(this.quesID);
  @override
  _AddQuesDataState createState() => _AddQuesDataState();
}

class _AddQuesDataState extends State<AddQuesData> {
  final _formKey = GlobalKey<FormState>();
  String question, option1, option2, option3, option4;
  bool isLoading = false;

  DataService _dataService = new DataService();

  bool uploadQuestionData() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      if (question != null) {
        Map<String, String> questionMap = {
          "question": question,
          "option1": option1,
          "option2": option2,
          "option3": option3,
          "option4": option4,
        };
        _dataService.addQuestionData(questionMap, widget.quesID).then((value) {
          setState(() {
            isLoading = false;
          });
        });
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
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
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(hintText: "Question"),
                      onChanged: (val) {
                        question = val;
                      },
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Option 1" : null,
                      decoration: InputDecoration(
                          hintText: "Option 1 (Correct Answer)"),
                      onChanged: (val) {
                        option1 = val;
                      },
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Option 2" : null,
                      decoration: InputDecoration(hintText: "Option 2"),
                      onChanged: (val) {
                        option2 = val;
                      },
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Option 3" : null,
                      decoration: InputDecoration(hintText: "Option 3"),
                      onChanged: (val) {
                        option3 = val;
                      },
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Option 4" : null,
                      decoration: InputDecoration(hintText: "Option 4"),
                      onChanged: (val) {
                        option4 = val;
                      },
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            var dataAdded = uploadQuestionData();

                            if (dataAdded) {
                              Navigator.pop(context);
                            }
                          },
                          child: blueButton(
                            context: context,
                            label: "Done",
                            buttonWidth: size.width / 2 * 0.8,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        GestureDetector(
                          onTap: () {
                            var dataAdded = uploadQuestionData();
                          },
                          child: blueButton(
                            context: context,
                            label: "Add",
                            buttonWidth: size.width / 2 * 0.8,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
