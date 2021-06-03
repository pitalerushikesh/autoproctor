import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class McqsTile extends StatefulWidget {
  final String option, description, correctAnswer, optionSelected;
  McqsTile(
      {this.option, this.description, this.correctAnswer, this.optionSelected});
  @override
  _McqsTileState createState() => _McqsTileState();
}

class _McqsTileState extends State<McqsTile> {
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
          Expanded(
            child: Container(
              child: Text(
                widget.description,
                style: GoogleFonts.ubuntu(
                  fontSize: 18,
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
          ),
        ],
      ),
    );
  }
}

class NoOfQuestionTile extends StatefulWidget {
  final String text;
  final int number;

  NoOfQuestionTile({this.text, this.number});

  @override
  _NoOfQuestionTileState createState() => _NoOfQuestionTileState();
}

class _NoOfQuestionTileState extends State<NoOfQuestionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14)),
              color: Colors.blue,
            ),
            child: Text(
              "${widget.number}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              color: Colors.black54,
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
