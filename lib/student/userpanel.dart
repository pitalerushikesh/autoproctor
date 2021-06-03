import 'package:autoproctor_oexam/services/auth.dart';
import 'package:autoproctor_oexam/student/mcqs.dart';
import 'package:autoproctor_oexam/student/profile.dart';
import 'package:autoproctor_oexam/student/submit.dart';
import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:camera/camera.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class UserPanel extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String classn, name, email;

  UserPanel(
    this.classn,
    this.name,
    this.email,
    this.cameras,
  );
  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  AuthService _authService = AuthService();

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
              print("Ho gaya");
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> _widgetOptions = [
    //   McQuestions(
    //     widget.classn,
    //     widget.name,
    //     widget.cameras,
    //   ),
    //   Submitted(),
    //   Profile(
    //     widget.name,
    //     widget.classn,
    //     widget.email,
    //   ),
    // ];
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   title: appBar(context),
      //   elevation: 0.0,
      //   backgroundColor: Colors.transparent,
      //   brightness: Brightness.light,
      // ),

      // _widgetOptions.elementAt(_selectedIndex)
      body: WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: PageView(
          controller: _pageController,
          children: <Widget>[
            McQuestions(
              widget.classn,
              widget.name,
              widget.cameras,
            ),
            Submitted(
              widget.classn,
              widget.name,
            ),
            Profile(
              widget.name,
              widget.classn,
              widget.email,
            ),
          ],
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: CurvedNavigationBar(
          color: Colors.green,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.green,
          height: 50,
          items: [
            Icon(
              Icons.home_outlined,
              size: 20,
              color: Colors.white,
            ),
            Icon(
              Icons.done_all_outlined,
              size: 20,
              color: Colors.white,
            ),
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 20,
              color: Colors.white,
            ),
          ],
          animationDuration: Duration(
            milliseconds: 200,
          ),
          animationCurve: Curves.elasticInOut,
          onTap: _onItemTap,
        ),
      ),
    );
  }
}

// selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.grey,
//         selectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.home_outlined,
//             ),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.done_all_outlined,
//             ),
//             label: "Submitted",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.person_add_alt_1_outlined,
//             ),
//             label: "Profile",
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTap,
//       ),
