import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/team_by_team/answers_team_by_team.dart';
import 'package:guessthosebars/user_side/team_by_team/play_team_by_team.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ResultsTeamByTeam extends StatefulWidget {
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

  ResultsTeamByTeam(
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
  _ResultsTeamByTeamState createState() => _ResultsTeamByTeamState(
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
        quesList,
//      player1Score,
//      player2Score
      );
}

class _ResultsTeamByTeamState extends State<ResultsTeamByTeam> {
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

  _ResultsTeamByTeamState(
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

  String winner = '';
  List<FontWeight> fontWeights = [
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isVideoSaved = false;

//
//  int player1Corrects=0;
//  int player1Wrongs=0;
//  int player2Corrects=0;
//  int player2Wrongs=0;

  int player1Score;
  int player2Score;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    for (int i = 0; i < miniList0.length; i++) {
//      if (miniList0[i].whatAnswered == miniList0[i].correctAnswer) {
//        player1Corrects = player1Corrects + 1;
//      } else {
//        player1Wrongs = player1Wrongs + 1;
//      }
//    }
//    for (int i = 0; i < miniList1.length; i++) {
//      if (miniList1[i].whatAnswered == miniList1[i].correctAnswer) {
//        player2Corrects = player2Corrects + 1;
//      } else {
//        player2Wrongs = player2Wrongs + 1;
//      }
//    }

    player1Score = player1Corrects - player1Wrongs;
    player2Score = player2Corrects - player2Wrongs;

    winner = player1Score > player2Score
        ? "TEAM\nBLUE"
        : player1Score == player2Score ? "Tie" : "TEAM\nRED";
    dealSharedPreferences();
//    print('videoPath: ${videoPath}');
    if (videoPath != '') {
      initializeControllers();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (videoPath != '' && isVideoSaved != true) {
      File(videoPath).delete(recursive: false);
    }
//    }
    chewieController?.dispose();
    videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    double multiplyer = videoPath == '' ? 0.90 : 1.05;
    print('player1: ${player1Corrects} , ${player1Wrongs} and ${player1Score}');
    print('player2: ${player2Corrects}, ${player2Wrongs} and ${player2Score}');
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(Constant.purpleColor),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: _height / 50, horizontal: _width / 30),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: _height * multiplyer),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  topRow(),
                  chewieController != null
                      ? Container(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width / 1.25,
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height / 50),
                          child: Chewie(
                            controller: chewieController,
                          ),
                        )
                      : Container(),
                  chewieController != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(),
                            Container(),
//                        Container(),
//                        Container(),
                            videoRelatedbtn(),
//                        Container(),
//                                    videoRelatedbtn('BACK', false),
                          ],
                        )
                      : Container(),
                  firstminiCol(),
                  centralCol(),
                  Container(),
                  btnsRow()
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  dealSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("${quesList[0].category}", currentQueNumber);
  }

  initializeControllers() {
    videoPlayerController = VideoPlayerController.file(
      File(videoPath),
    )..initialize().then((_) {
//        setState(() {});
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,

          aspectRatio: 3 / 2,
//       aspectRatio: 2/1,
          autoPlay: false,
          looping: false,
        );
        setState(() {});
      });
  }

  Widget videoRelatedbtn() {
    return RaisedButton(
      onPressed: () async {
        try {
          if (isVideoSaved != true) {
            await ImageGallerySaver.saveFile(videoPath);
            isVideoSaved = true;
//            ReqWidget().showSnackBar(_scaffoldKey, 'Video saved in gallery');
            showSnackBar("Video is successfully saved in gallery");
          } else {
            showSnackBar("Video is already saved in gallery");
          }
        } catch (e) {
          print('in videoRelation: ${e.toString()}\n newline');
        }
        setState(() {});
      },
      color: Color(Constant.yellowColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 100),
        child: Text(
          "SAVE",
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  showSnackBar(String txt) {
    SnackBar snackBar = SnackBar(
      content: Text(txt),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  BoxDecoration whiteBoxDecoration(bool isBlue) {
    return BoxDecoration(
      color: isBlue
          ? Color(player1Score > player2Score
              ? Constant.blueColor2
              : Constant.redColor)
          : Colors.white,
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  BoxDecoration scoreBoxDecoration(bool player1) {
    return BoxDecoration(
      color: Color(Constant.lightConColor2),
      border: Border.all(
          color: Color(player1 ? Constant.blueColor2 : Constant.redColor),
          width: 4.0),
      borderRadius: BorderRadius.circular(17.5),
    );
  }

  BoxDecoration conBoxDecoration(bool withBorder) {
    return BoxDecoration(
        color: Color(Constant.lightConColor),
        border: Border.all(
            color:
                withBorder ? Color(Constant.feroziColor) : Colors.transparent,
            width: 2.0),
        borderRadius: BorderRadius.circular(30.0));
  }

  TextStyle textStyle(bool isWhite, int itemNum) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black,
        fontWeight: fontWeights[itemNum]);
  }

  Widget backBtn() {
    double fullWidth = MediaQuery.of(context).size.width;
//    double fullheight = MediaQuery.of(context).size.height;
    return Container(
      decoration: whiteBoxDecoration(false),
      padding: EdgeInsets.all(fullWidth / 100),
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

  Widget topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        backBtn(),
        Text(
          "RESULTS",
          textScaleFactor: 2.0,
          style: textStyle(true, 4),
        ),
        Container(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.transparent,
            ),
            color: Colors.transparent,
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget playerCon() {
    double fullheight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: whiteBoxDecoration(true),
      padding: EdgeInsets.symmetric(
          vertical: fullheight / 50, horizontal: fullWidth / 25),
      margin: EdgeInsets.symmetric(vertical: fullheight / 80),
      child: Center(
        child: Text(
          winner,
          style: textStyle(true, 2),
          textAlign: TextAlign.center,
          textScaleFactor: 1.125,
        ),
      ),
    );
  }

  Widget firstminiCol() {
    return winner != 'Tie'
        ? Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Container(), playerCon(), Container()],
              ),
              Text(
                "WON",
                textScaleFactor: 2.0,
                style: textStyle(true, 2),
              )
            ],
          )
        : Text(
            "DRAW",
            style: textStyle(true, 4),
            textScaleFactor: 2.0,
          );
  }

  Widget centralCon() {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: conBoxDecoration(false),
      padding: EdgeInsets.symmetric(
          vertical: fullHeight / 50, horizontal: fullWidth / 25),
      margin: EdgeInsets.symmetric(vertical: fullHeight / 40),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(),
            scoreCol(true),
            scoreCol(false),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget scoreCol(bool isPlayer1) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        scoreCon(isPlayer1),
        Text(
          isPlayer1 ? "TEAM\nBLUE" : "TEAM\nRED",
          style: textStyle(true, 1),
        ),
      ],
    );
  }

  Widget scoreCon(bool isPlayer1) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Container(
      decoration: scoreBoxDecoration(isPlayer1),
//      padding: EdgeInsets.all(_width / 25),
      margin: EdgeInsets.symmetric(vertical: _height / 50),
      height: 65.0,
      width: 65.0,
      child: Center(
        child: Text(
          "${isPlayer1 ? player1Score : player2Score}",
//          "10000",
          style: textStyle(true, 4),
          textScaleFactor: 1.125,
        ),
      ),
    );
  }

  Widget answers() {
    double fullHght = MediaQuery.of(context).size.height;
    double fullWdth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => AnswersTeamByTeam(
                    topRow(),
                    player1Corrects,
                    player1Wrongs,
                    player2Corrects,
                    player2Wrongs,
                    miniList0,
                    miniList1,
                    player1Score,
                    player2Score)));
        /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => OneByOneAnswers(
                    topRow(),
//                    btnsRow(),
                    player1Corrects,
                    player1Wrongs,
                    player2Corrects,
                    player2Wrongs,
                    miniList0,
                    miniList1))); */
      },
      child: Container(
        decoration: conBoxDecoration(true),
        padding: EdgeInsets.symmetric(vertical: fullHght / 75),
        margin: EdgeInsets.symmetric(horizontal: fullHght / 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "ANSWERS",
                style: textStyle(true, 1),
                textScaleFactor: 1.125,
              ),
              SizedBox(
                width: fullWdth / 40,
              ),
              Container(
//              color: Colors.white,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: EdgeInsets.all(fullWdth / 50),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(Constant.feroziColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget centralCol() {
    return Column(
      children: <Widget>[centralCon(), answers()],
    );
  }

  Widget reqbtn(bool isBack) {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return RaisedButton(
      onPressed: () {
        if (isBack) {
          Navigator.pop(context);
        } else {
//          dealReplay();

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (ctx) => PlayTeamByTeam(originalTimer, 0,
                      currentQueNumber, permissionToRecordVideo, quesList)));
        }
      },
      color: Color(isBack ? Constant.purpleColor : Constant.yellowColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
            color: isBack ? Color(Constant.yellowColor) : Colors.transparent,
            width: 2.0),
      ),
      child: Container(
        width: isBack ? fullWidth / 4 : fullWidth / 2.0,
        padding: EdgeInsets.symmetric(vertical: fullHeight / 50),
        child: Center(
          child: Text(
            isBack ? "BACK" : "REPLAY",
            style: textStyle(isBack, 3),
            textScaleFactor: 1.5,
          ),
        ),
      ),
    );
  }

  Widget btnsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[reqbtn(true), reqbtn(false)],
    );
  }
}
