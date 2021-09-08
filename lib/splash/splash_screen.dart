import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/admin_side/admin_side.dart';
import 'package:guessthosebars/auth/login.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/res/static_info.dart';
import 'package:guessthosebars/user_side/select_mode.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

TextStyle textStyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.w700);

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    Future.delayed(Duration(seconds: 3), () {
//      Navigator.pushAndRemoveUntil(context,
//          MaterialPageRoute(builder: (ctx) => Login()), (predicate) => false);
//    });
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  Constant.wallpaperAsset,
                ),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Image.asset(
              Constant.mainLogoAsset,
              height: MediaQuery.of(context).size.width / 1.5,
              width: MediaQuery.of(context).size.width / 1.5,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  checkUser() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser == null) {
     Future.delayed(Duration(seconds: 3), () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (ctx) => Login()), (predicate) => false);
      });
    } else {
     int isAdmin;
      StaticInfo.currentUser = firebaseUser;
      DatabaseReference dbref = FirebaseDatabase.instance.reference();
      await dbref
          .child(Constant.users)
          .child(StaticInfo.currentUser.uid)
          .once()
          .then((dataSnapsot) {
        isAdmin = dataSnapsot.value[Constant.isAdmin];
        StaticInfo.userName = dataSnapsot.value[Constant.name];
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (ctx) => isAdmin == 0 ? SelectCategory() : Login()),
          (predicate) => false);
    }
  }

}
