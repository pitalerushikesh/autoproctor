import 'package:autoproctor_oexam/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  APUser _userFromFirebaseUser(User user) {
    return user != null ? APUser(fuid: user.uid) : null;
  }

  Future signInEmailAndPass(String email, String password) async {
    try {
      print(email);
      print(password);
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // User firebaseUser = _authResult.user;
      return _authResult.user.email;
    } catch (e) {
      return e.message;
      // print(e.toString());
    }
  }

  Future signUpWithEmailAndPasswordStudent(
    String email,
    String password,
    int role,
    String classn,
  ) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = authResult.user;
      FirebaseFirestore.instance.collection("Users_Student").doc(email).set({
        "uid": _auth.currentUser.uid,
        "role": role,
        "classn": classn,
      }).then((value) => {});
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPasswordTeacher(
    String email,
    String password,
    int role,
  ) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = authResult.user;
      FirebaseFirestore.instance.collection("Users_Teacher").doc(email).set({
        "uid": _auth.currentUser.uid,
        "role": role,
      }).then((value) => {});
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
