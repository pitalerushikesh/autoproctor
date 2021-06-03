import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  User user = FirebaseAuth.instance.currentUser;
  Future<void> addQuesData(Map quesData, String quesID) async {
    await FirebaseFirestore.instance
        .collection("Questions")
        .doc(quesID)
        .set(quesData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<Void> addQuestionData(Map questionData, String quesID) async {
    await FirebaseFirestore.instance
        .collection("Questions")
        .doc(quesID)
        .collection("mcqs")
        .add(questionData)
        .catchError((e) {
      print(e);
    });
  }

  getQuesData() async {
    return await FirebaseFirestore.instance.collection("Questions").snapshots();
  }

  getQuestionsData(String quesID) async {
    return await FirebaseFirestore.instance
        .collection("Questions")
        .doc(quesID)
        .collection("mcqs")
        .get();
  }

  Future<Void> addResultsData({
    int incorrect,
    int correct,
    int total,
    int notAttempted,
    String quesID,
    String name,
    String title,
    String classn,
    int switchAppWarning,
    String uid,
    List<String> img_urls,
  }) async {
    await FirebaseFirestore.instance
        .collection("Students_results")
        .doc(user.email + quesID)
        .set({
      "name": name,
      "correct": correct,
      "incorrect": incorrect,
      "notAttempted": notAttempted,
      "total": total,
      "classn": classn,
      "title": title,
      "uid": uid,
      "userdocID": user.email + quesID,
      "switchAppWarning": switchAppWarning,
      "img_urls": img_urls,
    }).catchError((e) {
      print(e.toString());
    });
  }
}
