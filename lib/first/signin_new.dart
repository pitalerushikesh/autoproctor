import 'package:alert/alert.dart';
import 'package:autoproctor_oexam/first/home.dart';
import 'package:autoproctor_oexam/main.dart';
import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/student/userpanel.dart';
import 'package:autoproctor_oexam/widgets/transition.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInNew extends StatefulWidget {
  final List<CameraDescription> cameras;

  SignInNew(
    this.cameras,
  );
  @override
  _SignInNewState createState() => _SignInNewState();
}

class _SignInNewState extends State<SignInNew>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String email, password;
  TextEditingController _emailController;
  TextEditingController _passwordController;

  AuthService _authService = new AuthService();

  bool _isLoading = false;
  bool _isHidden = true;

  signIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _authService.signInEmailAndPass(email, password).then((val) {
        // HelpFunctions.save_UserLoggedInDetails(isLoggedIn: true);
        // User user = FirebaseAuth.instance.currentUser;
        if (val == email) {
          FirebaseFirestore.instance
              .collection('Users_Student')
              .doc(_auth.currentUser.email)
              .get()
              .then((doc) {
            if (doc.exists) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).push(
                FadeRoute(
                  page: UserPanel(
                    doc['classn'],
                    doc['name'],
                    email,
                    cameras,
                  ),
                ),
              );
            } else {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).push(
                FadeRoute(
                  page: HomePage(),
                ),
              );
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Alert(message: val, shortDuration: false).show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: appBar(context),
          elevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          brightness: Brightness.light,
        ),
        body: _isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        "Welcome!",
                        style: GoogleFonts.montserrat(
                          fontSize: 35.0,
                          color: Color(0xff3A415E),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        "sign in to continue",
                        style: GoogleFonts.montserrat(
                          fontSize: 35.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.18,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40.0, right: 40.0),
                      child: Container(
                        child: TextFormField(
                          controller: _emailController,
                          validator: (val) {
                            return val.isEmpty ? "Enter the Email ID" : null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xfffDDE3DD),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2.0,
                              ),
                            ),
                            hintText: "Email",
                            hintStyle: GoogleFonts.ubuntu(),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            email = val;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: Container(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _isHidden,
                          validator: (val) {
                            return val.isEmpty ? "Enter the Password" : null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isHidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                              color: Colors.green,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xfffDDE3DD),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2.0,
                              ),
                            ),
                            hintText: "Password",
                            hintStyle: GoogleFonts.ubuntu(),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: GestureDetector(
                        onTap: () {
                          print(email);
                          print(password);
                          signIn();
                        },
                        child: Text(
                          "Signin",
                          style: GoogleFonts.ubuntu(
                            fontSize: 35.0,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.08,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
