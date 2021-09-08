import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/results.dart';
import 'package:path_provider/path_provider.dart';

class PlayGame extends StatefulWidget {
//  int modeNum;
  int timer;
  int currentQueNum;
  bool permissionToRecordVideo;

  List<Question> questionsList;

  PlayGame(this.timer, this.currentQueNum, this.permissionToRecordVideo,
      this.questionsList);

  @override
  _PlayGameState createState() => _PlayGameState(
      timer, currentQueNum, permissionToRecordVideo, questionsList);
}

class _PlayGameState extends State<PlayGame> {
//  int modeNum;
  List<Question> questionsList;
  int originalTimer;
  int currentQueNum;
  bool permissionToRecordVideo;
  int optionTapped = -1;
  int firstQueNumber;
  int correctOnes = 0;
  int wrongOnes = 0;

  _PlayGameState(this.originalTimer, this.currentQueNum,
      this.permissionToRecordVideo, this.questionsList);

  List optionsList;
  bool showAlertDialog = false;
  CameraController cameraController;
  List<CameraDescription> cameras;
  String videoPath = '';
  bool cameraInitialized;
  bool roundCompleted;
  int timer;
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final audios = [
    Audio("assets/audios/right.mp3"),
    Audio("assets/audios/wrong.mp3")
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstQueNumber = currentQueNum;
    timer = originalTimer;
    optionsList = [
      questionsList[currentQueNum].optA,
      questionsList[currentQueNum].optB,
      questionsList[currentQueNum].optC,
      questionsList[currentQueNum].optD
    ];
    assetsAudioPlayer.loop = false;
    assetsAudioPlayer.setVolume(1.0);
    if (permissionToRecordVideo == true) {
      intializeController();
    }
    runTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        dealMovingBack();
      },
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Color(Constant.purpleColor),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: permissionToRecordVideo == true
//                  ? cameraController.value.isInitialized == true
                  ? cameraInitialized == true
                      ? cameraController.value.isInitialized == true
                          ? AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
                              child: CameraPreview(cameraController))
                          : Container()
                      : Container()
                  : Container(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 100,
                  horizontal: MediaQuery.of(context).size.width / 30),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    topRow(),
                    queStateMent(),
                    showAlertDialog != true ? optsCol() : Container(),
                    timer > 0
                        ? btnsRow(!showAlertDialog)
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height / 75),
                            child: Center(
                              child: Text(
                                "TIME'S UP",
                                textScaleFactor: 1.75,
                                style: textStyle(true, FontWeight.w900),
                              ),
                            ),
                          ),
//              Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  closeCamera() {
    if (permissionToRecordVideo == true) {
      if (cameraController.value.isRecordingVideo) {
        cameraController.stopVideoRecording();
      }
      cameraController.dispose();
    }
  }

  dealMovingBack() {
    if (currentQueNum == firstQueNumber) {
      closeCamera();
      assetsAudioPlayer.dispose();
      Navigator.pop(context);
    } else {
      setState(() {
        showAlertDialog = !showAlertDialog;
      });
    }
  }

  Widget backBtn(bool isUseless) {
    return Container(
      decoration: isUseless == false
          ? smallBoxDecoration(false)
          : BoxDecoration(color: Colors.transparent),
      padding: EdgeInsets.all(5.0),
      child: IconButton(
//        icon: Icon(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isUseless == false
                ? Color(Constant.feroziColor)
                : Colors.transparent,
          ),
          onPressed: isUseless == false
              ? () {
                  dealMovingBack();
                }
              : null),
    );
  }

  BoxDecoration smallBoxDecoration(bool isGrey) {
    return BoxDecoration(
      color: isGrey ? Color(Constant.greyWhiteColor) : Colors.white,
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  TextStyle textStyle(bool isWhite, FontWeight fontWeight) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black, fontWeight: fontWeight);
  }

  Widget timerWidget() {
    return Container(
      width: 100.0,
      height: 65.0,
      decoration: smallBoxDecoration(true),
      child: Center(
        child: Text(
          timer > 9 ? "${timer}" : timer > 0 ? "0${timer}" : "0",
          textScaleFactor: 2.0,
          style: textStyle(false, FontWeight.w500),
        ),
      ),
    );
  }

  BoxDecoration boxDecoration(bool isYellow) {
    return BoxDecoration(
      color: Color(isYellow ? Constant.yellowColor : Constant.conColor),
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  Widget topRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          backBtn(false),
          showAlertDialog != true ? timerWidget() : Container(),
          backBtn(true),
        ],
      ),
    );
  }

  Widget queStateMent() {
    return Container(
      decoration: boxDecoration(false),
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 100,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.75,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 30,
          vertical: MediaQuery.of(context).size.height / 75),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            showAlertDialog != true
                ? questionsList[currentQueNum].queStatement
                : "ARE YOU SURE\nYOU WANT TO LEAVE\nTHE GAME?",
            textAlign: TextAlign.center,
            textScaleFactor: 2.0,
            style: textStyle(true, FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget whichOpt(int optNum) {
    String opt = '';
    if (optNum == 0) {
      opt = 'A';
    } else if (optNum == 1) {
      opt = 'B';
    } else if (optNum == 2) {
      opt = 'C';
    } else {
      opt = "D";
    }
    return Container(
      width: MediaQuery.of(context).size.width / 8,
      decoration: boxDecoration(optionTapped == optNum ? true : false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75),
      child: Center(
        child: Text(
          opt,
          textScaleFactor: 1.65,
          style:
              textStyle(optNum == optionTapped ? false : true, FontWeight.w600),
        ),
      ),
    );
  }

  Widget optStateMent(int optNum) {
    int len = optionsList[optNum].length;
    return Container(
      width: MediaQuery.of(context).size.width / 1.35,
      decoration: boxDecoration(optionTapped == optNum ? true : false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75,
          horizontal: MediaQuery.of(context).size.width / 20),
      child: Text(
        optionsList[optNum],
//        textScaleFactor: 1.75,
        textScaleFactor:
            len < 21 ? 1.65 : len < 41 ? 1.40 : len < 21 ? 1.15 : 1.0,
        style:
            textStyle(optionTapped == optNum ? false : true, FontWeight.w500),
      ),
    );
  }

  Widget optRow(int optNum) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 100,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            optionTapped = optNum;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            whichOpt(optNum),
            optStateMent(optNum),
          ],
        ),
      ),
    );
  }

  Widget optsCol() {
    List<Widget> tmp = List<Widget>();
    for (int i = 0; i < optionsList.length; i++) {
      tmp.add(optRow(i));
    }
    return Column(children: tmp);
  }

  Widget reqBtn(int btnNum, bool isRegardingQue) {
    return FlatButton(
        onPressed: () {
          if (isRegardingQue == true) {
            if (btnNum == 0) {
              bringNextQue();
            } else {
              dealNext();
            }
          } else {
            if (btnNum == 0) {
              setState(() {
                showAlertDialog = false;
              });
            } else {
              closeCamera();
//              Navigator.pop(context);
              timer = 0;
            }
          }
        },
        color: Color(btnNum == 0 ? Constant.purpleColor : Constant.yellowColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
              color: btnNum == 0
                  ? Color(Constant.yellowColor)
                  : Colors.transparent,
              width: 2.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 40,
              horizontal: btnNum == 0
                  ? MediaQuery.of(context).size.width / 20
                  : MediaQuery.of(context).size.width / 5.75),
          child: Text(
            isRegardingQue == true
                ? btnNum == 0 ? "SKIP" : "NEXT"
                : btnNum == 0 ? "No" : "YES",
            textScaleFactor: 1.75,
            style: textStyle(btnNum == 0 ? true : false, FontWeight.w900),
          ),
        ));
  }

  Widget btnsRow(bool isRegardingQue) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Row(
        mainAxisAlignment: isRegardingQue
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        children: <Widget>[
          reqBtn(0, isRegardingQue),
          SizedBox(
            width: MediaQuery.of(context).size.width / 20,
          ),
          isRegardingQue == true
              ? optionTapped == -1 ? Container() : reqBtn(1, isRegardingQue)
              : reqBtn(1, isRegardingQue),
        ],
      ),
    );
  }

  bringNextQue() {
    if (currentQueNum + 1 < questionsList.length - 1) {
      currentQueNum = currentQueNum + 1;
    } else {
      roundCompleted = true;
      currentQueNum = 0;
    }
    optionsList = [
      questionsList[currentQueNum].optA,
      questionsList[currentQueNum].optB,
      questionsList[currentQueNum].optC,
      questionsList[currentQueNum].optD
    ];
    setState(() {});
  }

  dealNext() {
    questionsList[currentQueNum].whatAnswered = optionsList[optionTapped];
    if (questionsList[currentQueNum].whatAnswered ==
        questionsList[currentQueNum].correctAnswer) {
      assetsAudioPlayer.open(audios[0]);
    } else {
      assetsAudioPlayer.open(audios[1]);
    }
    optionTapped = -1;
    bringNextQue();
  }

  runTimer() {
    Timer.periodic(Duration(seconds: 1), (_timer) {
      if (mounted) {
        if (timer < 0) {
          _timer.cancel();
          moveToResults();
        }
        setState(() {
          timer = timer - 1;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  intializeController() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[1],
      ResolutionPreset.veryHigh,
      enableAudio: true,
    );
    setState(() {
      cameraInitialized = true;
    });
    Directory dir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/${questionsList[currentQueNum].category}');
    dir = await dir.create();
    videoPath = '${dir.path}/${DateTime.now()}.mp4';

    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startVideoRecording(videoPath);

      setState(() {});
    });
  }

  moveToResults() async {
    await closeCamera();
    List<Question> miniList = List<Question>();

    if (roundCompleted != true) {
      for (int i = firstQueNumber; i < currentQueNum; i++) {
        miniList.add(questionsList[i]);
        if (questionsList[i].correctAnswer == questionsList[i].whatAnswered) {
          correctOnes++;
        } else {
          wrongOnes++;
        }
      }
    } else {
      for (int i = firstQueNumber; i < questionsList.length - 1; i++) {
        miniList.add(questionsList[i]);
        if (questionsList[i].correctAnswer == questionsList[i].whatAnswered) {
          correctOnes++;
        } else {
          wrongOnes++;
        }
      }
      if (currentQueNum > 0) {
        for (int i = 0; i < currentQueNum; i++) {
          miniList.add(questionsList[i]);
          if (questionsList[i].correctAnswer == questionsList[i].whatAnswered) {
            correctOnes++;
          } else {
            wrongOnes++;
          }
        }
      }
    }
    assetsAudioPlayer.dispose();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => Results(
//                timer,
                originalTimer,
                permissionToRecordVideo,
                correctOnes,
                wrongOnes,
                currentQueNum,
                videoPath,
                miniList,
                questionsList)));
  }
}
