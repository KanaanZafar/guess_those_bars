import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/res/constants.dart';

class LeaderBoard extends StatefulWidget {
  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  List<FontWeight> fontWeights = [
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];
  DatabaseReference dbref = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(Constant.purpleColor),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 50),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: backIcon(),
            ),
//            SizedBox(
//              height: MediaQuery.of(context).size.height / 50,
//            ),
            heading(),
//            SizedBox(
//              height: MediaQuery.of(context).size.height / 50,
//            ),
            Expanded(
                child: FirebaseAnimatedList(
                    query: dbref.child(Constant.leaderBoard),
                    sort: ((a, b) => b.value[Constant.score]
                        .compareTo(a.value[Constant.score])),
                    itemBuilder: (ctx, dataSnapshot, anime, index) {
                      print('key: ${dataSnapshot.key}');
                      print('val ${dataSnapshot.value}');
                      return nameCon(
                          index + 1, dataSnapshot.value[Constant.name]);
                    }))
          ],
        ),
      ),
    ));
  }

  TextStyle textStyle(bool isWhite, int fontNum) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black,
        fontWeight: fontWeights[fontNum]);
  }

  Widget backIcon() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(Constant.feroziColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  Widget heading() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50),
      width: MediaQuery.of(context).size.width,
      color: Color(Constant.conColor),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75),
      child: Center(
        child: Text(
          "LEADERBOARD",
          textScaleFactor: 1.75,
          style: textStyle(true, 3),
        ),
      ),
    );
  }

  Widget nameCon(int indexNum, String name) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(Constant.lightConColor2),
      padding: EdgeInsets.symmetric(
          horizontal: 20.0, vertical: MediaQuery.of(context).size.height / 75),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            '${indexNum}',
            style: textStyle(true, 1),
            textScaleFactor: 1.25,
          ),
          Text(
            name,
            style: textStyle(true, 1),
            textScaleFactor: 1.25,
          ),
          Container(),
          Container(),
          Container(),
        ],
      ),
    );
  }
}
