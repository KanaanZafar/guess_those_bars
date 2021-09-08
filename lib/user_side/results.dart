import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/res/static_info.dart';
import 'package:guessthosebars/user_side/play_game.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class Results extends StatefulWidget {
  int timer;
  bool permissionToRecordVideo;
  int correctOnes;
  int wrongOnes;
  int currentQueNum;
  String videoPath;
  List<Question> miniList;
  List<Question> questionsList;

  Results(
      this.timer,
      this.permissionToRecordVideo,
      this.correctOnes,
      this.wrongOnes,
      this.currentQueNum,
      this.videoPath,
      this.miniList,
      this.questionsList);

  @override
  _ResultsState createState() => _ResultsState(
      timer,
      permissionToRecordVideo,
      correctOnes,
      wrongOnes,
      currentQueNum,
      videoPath,
      miniList,
      questionsList);
}

class _ResultsState extends State<Results> {
  int timer;
  bool permissionToRecordVideo;
  int correctOnes;
  int wrongOnes;
  int currentQueNum;
  String videoPath;
  List<Question> miniList;
  List<Question> questionsList;

  _ResultsState(
      this.timer,
      this.permissionToRecordVideo,
      this.correctOnes,
      this.wrongOnes,
      this.currentQueNum,
      this.videoPath,
      this.miniList,
      this.questionsList);

  TextStyle lightTextStyle;
  TextStyle mediumTextStyle;
  TextStyle boldTextStyle;
  bool isVideoSaved;
  BorderRadius _borderRadius = BorderRadius.circular(15.0);
  SharedPreferences sharedPreferences;
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  double prevRecord = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lightTextStyle = textStyle(true, FontWeight.w600);
    mediumTextStyle = textStyle(true, FontWeight.w800);
    boldTextStyle = textStyle(true, FontWeight.w900);
    dealSharedPreferences();
    if (videoPath != '') {
      initializeControllers();
    }
    if (miniList.length > 0) {
      readFirebase();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    if (thumbnailPath != '') {
    if (videoPath != '' && isVideoSaved != true) {
      File(videoPath).delete(recursive: false);
    }
//    }
    chewieController?.dispose();
    videoPlayerController?.dispose();
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
            horizontal: MediaQuery.of(context).size.width / 30),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              topRow(),
              chewieController != null
                  ? Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width / 1.25,
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height / 50),
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
                        videoRelatedbtn('SAVE'),
//                        Container(),
//                                    videoRelatedbtn('BACK', false),
                      ],
                    )
                  : Container(),
              secRow(),
              miniList.length > 0
                  ? quesList()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: videoPath != ''
                              ? MediaQuery.of(context).size.height / 20
                              : MediaQuery.of(context).size.height / 4.25),
                      child: Center(
                        child: Text(
                          "You did not attempt any question",
                          textScaleFactor: 2.0,
                          style: boldTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              btnsRow()
            ],
          ),
        ),
      ),
    ));
  }

//  Widget videoRelatedbtn(){}
  Widget backBtn(bool isUseLess) {
    return Container(
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
          color: isUseLess ? Colors.transparent : Colors.white,
          borderRadius: _borderRadius),
      child: IconButton(
          icon: Center(
            child: Icon(
              Icons.arrow_back_ios,
              color:
                  isUseLess ? Colors.transparent : Color(Constant.feroziColor),
            ),
          ),
          onPressed: isUseLess
              ? null
              : () {
                  Navigator.pop(context);
                }),
    );
  }

  Widget topRow() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 75),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          backBtn(false),
          Text(
            "RESULTS",
            style: mediumTextStyle,
            textScaleFactor: 1.5,
          ),
          backBtn(true),
        ],
      ),
    );
  }

  TextStyle textStyle(bool isWhite, FontWeight _fontWeight) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black, fontWeight: _fontWeight);
  }

  BoxDecoration boxDecoration(bool forMini, bool isGreen) {
    return BoxDecoration(
        color: Color(forMini ? Constant.lightConColor : Constant.conColor),
        border: Border.all(
            color: isGreen == false
                ? Color(Constant.redColor)
                : Color(forMini
                    ? Constant.greenColor
                    : Constant.stylishBorderColor),
            width: 3.0),
        borderRadius: _borderRadius);
  }

  Widget secRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(),
          secRowWidget(true),
          secRowWidget(false),
          Container()
        ],
      ),
    );
  }

  Widget secRowWidget(bool isRight) {
    return Column(
      children: <Widget>[
        Text(
          isRight ? "RIGHT" : "WRONG",
          style: mediumTextStyle,
          textScaleFactor: 1.25,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 100,
        ),
        Container(
          height: MediaQuery.of(context).size.height / 11.5, //70.0,
          width: MediaQuery.of(context).size.width / 6,
          decoration: boxDecoration(true, isRight),
          child: Center(
            child: Text(
              "${isRight ? correctOnes : wrongOnes}",
              textScaleFactor: 1.25,
              style: mediumTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget quesList() {
    List<Widget> tmp = List<Widget>();
    for (int i = 0; i < miniList.length; i++) {
      tmp.add(queContainer(miniList[i]));
    }
    return Column(children: tmp);
  }

  Widget queContainer(Question question) {
    double _height = MediaQuery.of(context).size.height / 2.5;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration(false,
          question.whatAnswered == question.correctAnswer ? true : false),
//      height: _height,
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: MediaQuery.of(context).size.width / 35),
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Container(
              height: _height * 0.75,
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    question.queStatement,
                    textAlign: TextAlign.center,
                    style: boldTextStyle,
                    textScaleFactor: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(Constant.textFieldColor),
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 40),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 40,
                vertical: MediaQuery.of(context).size.height / 75),
            child: Text(
              question.whatAnswered,
              textAlign: TextAlign.start,
              style: lightTextStyle,
              textScaleFactor: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget btnsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[reqBtn(true), reqBtn(false)],
      ),
    );
  }

  Widget reqBtn(bool isBack) {
    double divider = isBack ? 10 : 3.5;
    return RaisedButton(
      onPressed: () {
        isBack
            ? Navigator.pop(context)
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (ctx) => PlayGame(timer, currentQueNum,
                        permissionToRecordVideo, questionsList)));
      },
      color: Color(isBack ? Constant.lightConColor : Constant.yellowColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
            color: isBack ? Color(Constant.yellowColor) : Colors.transparent,
            width: 3.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.height / divider,
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 40),
        child: Center(
          child: Text(
            isBack ? "BACK" : "REPLAY",
            style: isBack ? mediumTextStyle : textStyle(false, FontWeight.w800),
            textScaleFactor: 1.5,
          ),
        ),
      ),
    );
  }

  dealSharedPreferences() async {
    if (miniList.length > 0) {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setInt("${miniList[0].category}", currentQueNum);
    }
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

  Widget videoRelatedbtn(String btnName) {
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
          btnName,
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  showSnackBar(String chithi) {
    SnackBar snackBar = SnackBar(content: Text(chithi));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  readFirebase() async {
    await dbref
        .child(Constant.users)
        .child(StaticInfo.currentUser.uid)
        .child(Constant.score)
        .once()
        .then((datasnapShot) {
//      print('key: ${datasnapShot.key}');
//      print('val: ${datasnapShot.value}');
      if (datasnapShot.value != null) {
        var a = datasnapShot.value[Constant.prevRecord];
        prevRecord = a / 1;
      }
    });
    writeInFirebase();
  }

  writeInFirebase() async {
    double miniAvg = (correctOnes / miniList.length) * 100;
    double avg = (miniAvg + prevRecord) / 2;

    await dbref
        .child(Constant.users)
        .child(StaticInfo.currentUser.uid)
        .child(Constant.score)
        .update({
      Constant.prevRecord: avg,
    });
    await dbref
        .child(Constant.leaderBoard)
        .child(StaticInfo.currentUser.uid)
        .update({Constant.name: StaticInfo.userName, Constant.score: avg});
  }
}
