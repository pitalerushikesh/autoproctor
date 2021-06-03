import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget appBar(BuildContext context) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 22,
      ),
      children: <TextSpan>[
        TextSpan(
          text: 'Auto',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w500,
            fontSize: 28.0,
            color: Colors.black54,
          ),
        ),
        TextSpan(
          text: 'Proctor',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
            color: Colors.green,
          ),
        ),
      ],
    ),
  );
}

Widget blueButton({BuildContext context, String label, buttonWidth}) {
  return Container(
    alignment: Alignment.center,
    width: buttonWidth != null
        ? buttonWidth
        : MediaQuery.of(context).size.width - 48,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white),
    ),
  );
}
