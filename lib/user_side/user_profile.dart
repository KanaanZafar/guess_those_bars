import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/auth/login.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> urlLinks = ["", ""];
  DatabaseReference dbref = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(Constant.purpleColor),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 75,
              horizontal: MediaQuery.of(context).size.width / 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[firstCol(), lastCol(), Container()],
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(bool isBold) {
    return TextStyle(
        color: Colors.white,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.w600);
  }

  BoxDecoration boxDecoration(bool withBorder, bool isWhite) {
    return BoxDecoration(
        color: isWhite ? Colors.white : Color(Constant.conColor),
        borderRadius: BorderRadius.circular(17.5),
        border:
            Border.all(color: withBorder ? Colors.white : Colors.transparent));
  }

  Widget fistRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          backIcon(),
          Text(
            "PROFILE",
            style: textStyle(true),
            textScaleFactor: 1.25,
          ),
          Container()
        ],
      ),
    );
  }

  Widget backIcon() {
    return Container(
      decoration: boxDecoration(false, true),
      width: 50.0,
      height: 50.0,
      child: Center(
        child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(Constant.feroziColor),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  Widget firstCol() {
    return Column(
      children: <Widget>[
        fistRow(),
        outerCon("RATE OUR APP", false),
        SizedBox(
          height: MediaQuery.of(context).size.height / 75,
        ),
        GestureDetector(
          child: outerCon("TERMS & CONDITIONS", true),
          onTap: urlLinks[0] != ''
              ? () {
                  _launchURL(urlLinks[0]);
                }
              : null,
        ),
        GestureDetector(
          child: outerCon("PRIVACY POLICY", true),
          onTap: urlLinks[1] != ''
              ? () {
                  _launchURL(urlLinks[1]);
                }
              : null,
        ),
        outerCon("RESTORE PURCHASES", true)
      ],
    );
  }

  Widget lastCol() {
    return Column(
      children: <Widget>[
        outerCon("DELETE ACCOUNT", true),
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (ctx) => Login()),
                (predicate) => false);
          },
          child: outerCon("LOGOUT", true),
        )
      ],
    );
  }

  Widget outerCon(String conName, bool withBorder) {
    return Container(
      decoration: boxDecoration(withBorder, false),
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 90),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 62.5),
      child: Center(
        child: Text(
          conName,
          style: textStyle(!withBorder),
          textScaleFactor: 1.5,
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSnackBar("Error in launching url ${url}");
    }
  }

  showSnackBar(String chithi) {
    SnackBar snackBar = SnackBar(content: Text(chithi));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  readFirebase() async {
    await dbref.child(Constant.links).once().then((dataSnapshot) {
      urlLinks[0] = dataSnapshot.value[Constant.termsAndConditions];
      urlLinks[1] = dataSnapshot.value[Constant.privacyPolicy];
      setState(() {});
    });
  }
}
