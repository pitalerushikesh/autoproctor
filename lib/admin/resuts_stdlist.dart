import 'package:autoproctor_oexam/admin/gallery.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultList extends StatefulWidget {
  @override
  _ResultListState createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  Stream fetchResult =
      FirebaseFirestore.instance.collection("Students_results").snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: fetchResult,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return _students(
                      context,
                      snapshot.data.docs[index].data()['name'],
                      snapshot.data.docs[index].data()['correct'],
                      snapshot.data.docs[index].data()['incorrect'],
                      snapshot.data.docs[index].data()['notAttempted'],
                      snapshot.data.docs[index].data()['total'],
                      snapshot.data.docs[index].data()['classn'],
                      snapshot.data.docs[index].data()['title'],
                      snapshot.data.docs[index].data()['userdocID'],
                      snapshot.data.docs[index].data()['switchAppWarning'],
                      snapshot.data.docs[index].data()['img_urls'],
                    );
                  });
        },
      ),
    );
  }
}

// Widget studentDetails(
//     String name, int correct, int incorrect, int notAttempted, int total) {
//   return Card(
//     child: Container(
//       child: DataTable(
//         columns: [
//           DataColumn(
//               label: Text(
//             "Fields",
//           )),
//           DataColumn(
//               label: Text(
//             "Values",
//           ))
//         ],
//         rows: [
//           DataRow(cells: [
//             DataCell(
//               Text(
//                 "NAME",
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             DataCell(
//               Text(
//                 name,
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//             )
//           ]),
//           DataRow(cells: [
//             DataCell(
//               Text(
//                 "Class",
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             DataCell(
//               Text(
//                 name,
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//             )
//           ]),
//           DataRow(cells: [
//             DataCell(
//               Text(
//                 "Subject",
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             DataCell(
//               Text(
//                 name,
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//             )
//           ]),
//           DataRow(cells: [
//             DataCell(
//               Text(
//                 "Correct",
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             DataCell(
//               Text(
//                 correct.toString(),
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//             )
//           ]),
//           DataRow(
//             cells: [
//               DataCell(
//                 Text(
//                   "Incorrect",
//                   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               DataCell(
//                 Text(
//                   incorrect.toString(),
//                   style:
//                       TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//           DataRow(
//             cells: [
//               DataCell(
//                 Text(
//                   "Not Attempted",
//                   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               DataCell(
//                 Text(
//                   notAttempted.toString(),
//                   style:
//                       TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//           DataRow(
//             cells: [
//               DataCell(
//                 Text(
//                   "Total",
//                   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               DataCell(
//                 Text(
//                   correct.toString() + '/' + total.toString(),
//                   style:
//                       TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _students(
  BuildContext context,
  String name,
  int correct,
  int incorrect,
  int notAttempted,
  int total,
  String classn,
  String title,
  String userdocID,
  int switchAppWarning,
  List<dynamic> img_urls,
) {
  List<Widget> stdDetails = [
    _stdProfile('Correct', correct),
    _stdProfile('Incorrect', incorrect),
    _stdProfile('Not Attempted', notAttempted),
    _stdProfile('Total', total),
    _stdProfile('Switch App Count/s', switchAppWarning),
    ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          BouncyPageRoute(
            widget: MalGallery(img_urls),
          ),
        );
      },
      child: Text("Click"),
    )
  ];

  Future<bool> _onDoubleTap() {
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
                  .collection("Students_results")
                  .doc(userdocID)
                  .delete();
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  return GestureDetector(
    onLongPress: () => _onDoubleTap(),
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
          subtitle: Text(
            classn + ' - ' + title,
            style: GoogleFonts.raleway(
              fontSize: 15.0,
              color: Colors.black,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    name,
                    style: GoogleFonts.raleway(
                      fontSize: 28.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
          trailing: Text(
            correct.toString() + '/' + total.toString(),
          ),
          children: stdDetails),
    ),
  );
}

Widget _stdProfile(
  String word,
  int number,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
        elevation: 2.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(word + ' - ' + number.toString(),
                  style: GoogleFonts.raleway(
                    fontSize: 25.0,
                  )),
            ),
          ],
        )),
  );
}
