import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';

//import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/res/static_info.dart';
import 'package:guessthosebars/user_side/play_one_by_one/one_by_one_answers.dart';
import 'package:guessthosebars/user_side/play_one_by_one/one_by_one_results.dart';
import 'package:guessthosebars/user_side/play_one_by_one/playonebyone.dart';
import 'package:guessthosebars/user_side/team_by_team/results_team_by_team.dart';

class DrawTeamByTeam extends StatefulWidget {
  int originalTimer;
  int currentQueNumber;
  bool permissionToRecordVideo;
  int player1Corrects;
  int player1Wrongs;
  int player2Corrects;
  int player2Wrongs;
  String videoPath;
  List<Question> miniList0;
  List<Question> miniList1;
  List<Question> quesList;

  DrawTeamByTeam(
      this.originalTimer,
      this.currentQueNumber,
      this.permissionToRecordVideo,
      this.player1Corrects,
      this.player1Wrongs,
      this.player2Corrects,
      this.player2Wrongs,
      this.videoPath,
      this.miniList0,
      this.miniList1,
      this.quesList);

  @override
  _DrawTeamByTeamState createState() => _DrawTeamByTeamState(
      originalTimer,
      currentQueNumber,
      permissionToRecordVideo,
      player1Corrects,
      player1Wrongs,
      player2Corrects,
      player2Wrongs,
      videoPath,
      miniList0,
      miniList1,
      quesList);
}

class _DrawTeamByTeamState extends State<DrawTeamByTeam> {
  int originalTimer;
  int currentQueNumber;
  bool permissionToRecordVideo;
  int player1Corrects;
  int player1Wrongs;
  int player2Corrects;
  int player2Wrongs;
  String videoPath;
  List<Question> miniList0;
  List<Question> miniList1;
  List<Question> quesList;

  _DrawTeamByTeamState(
      this.originalTimer,
      this.currentQueNumber,
      this.permissionToRecordVideo,
      this.player1Corrects,
      this.player1Wrongs,
      this.player2Corrects,
      this.player2Wrongs,
      this.videoPath,
      this.miniList0,
      this.miniList1,
      this.quesList);

  List<FontWeight> fontWeights = [
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];
  int currentGameNum;
  StreamController _dividerController = StreamController<int>();

  StreamController _wheelNotifier = StreamController<double>();
  bool spinnedyet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dividerController.stream.listen(
      (data) {
        currentGameNum = data - 1;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(Constant.purpleColor),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "DRAW MATCH",
                textScaleFactor: 1.75,
                style: textStyle(true, 2),
              ),
              Text(
                "Spin the wheel for a quick\n30 seconds round",
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
                style: textStyle(true, 1),
              ),
              Column(
                children: <Widget>[
                  Image.asset(
                    Constant.arrowAsset,
                    height: 35.0,
                    width: 35.0,
                  ),
                  spinner(),
                ],
              ),
              btnsRow()
            ],
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(bool isWhite, int fNum) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black,
        fontWeight: fontWeights[fNum]);
  }

  Widget btnsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          reqBtn(true),
          reqBtn(false),
        ],
      ),
    );
  }

  Widget reqBtn(bool isDraw) {
    return RaisedButton(
      onPressed: () async {
        if (isDraw == true) {
          closeStreams();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (ctx) => ResultsTeamByTeam(
                      originalTimer,
                      currentQueNumber,
                      permissionToRecordVideo,
                      player1Corrects,
                      player1Wrongs,
                      player2Corrects,
                      player2Wrongs,
                      videoPath,
                      miniList0,
                      miniList1,
                      quesList)));
        } else {
//          if (spinnedyet == false) {
          spinnedyet = true;
          _wheelNotifier.sink.add(_generateRandomVelocity());
          await Future.delayed(Duration(seconds: 4));
          originalTimer = 30;
          if (quesList[0].category > 1) {
            currentGameNum = currentGameNum + 2;
          }
          closeStreams();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => PlayOneByOne(
                  originalTimer,
                  0,
                  permissionToRecordVideo,
                  0,
                  StaticInfo.listOfLists[currentGameNum]),
            ),
          );
          //          }
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
            color: isDraw ? Color(Constant.yellowColor) : Colors.transparent,
            width: 2.0),
      ),
      color: Color(isDraw ? Constant.purpleColor : Constant.yellowColor),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: isDraw
              ? MediaQuery.of(context).size.width / 12.5
              : MediaQuery.of(context).size.width / 4.5),
      child: Text(
        isDraw ? 'DRAW' : "SPIN",
        style: textStyle(isDraw, 3),
        textScaleFactor: 1.5,
      ),
    );
  }

  Widget spinner() {
    return SpinningWheel(
      Image.asset(quesList[0].category > 1
          ? Constant.premiumAsset
          : Constant.freeAsset),
      width: MediaQuery.of(context).size.height / 2.25,
      height: MediaQuery.of(context).size.height / 2.25,
      onUpdate: _dividerController.add,
      onEnd: _dividerController.add,
      shouldStartOrStop: _wheelNotifier.stream,
      dividers: quesList[0].category > 1 ? 8 : 2,
      initialSpinAngle: _generateRandomAngle(),
      canInteractWhileSpinning: false,
    );
  }

  closeStreams() {
    _dividerController.close();
    _wheelNotifier.close();
  }

  double _generateRandomVelocity() {
//    double d = Random().nextDouble();
    double doub = (1.5 * 6000) + 2000;
//    print('double: ${d}');
    return doub;
  }

//
  double _generateRandomAngle() {
    double ang = Random().nextDouble() * pi * 2;
    return ang;
  }
}
