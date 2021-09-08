import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/play_one_by_one/one_by_one_draw.dart';

import 'package:guessthosebars/user_side/play_one_by_one/one_by_one_results.dart';
import 'package:path_provider/path_provider.dart';

class PlayOneByOne extends StatefulWidget {
  int originalTimer;
  int turnNum;
  int currentQueNum;
  bool permissionToRecordVideo;
  List<Question> quesList;

  PlayOneByOne(this.originalTimer, this.turnNum, this.permissionToRecordVideo,
      this.currentQueNum, this.quesList);

  @override
  _PlayOneByOneState createState() => _PlayOneByOneState(
      originalTimer, turnNum, currentQueNum, permissionToRecordVideo, quesList);
}

class _PlayOneByOneState extends State<PlayOneByOne> {
  int originalTimer;
  int turnNum;
  int currentQueNum;
  bool permissionToRecordVideo;
  List<Question> quesList;

  _PlayOneByOneState(this.originalTimer, this.turnNum, this.currentQueNum,
      this.permissionToRecordVideo, this.quesList);

  List<FontWeight> fontWeights = [
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];
  int timer;
  bool showAlertDialog = false;
  int optionTapped = -1;
  List<String> optionsList;
  bool roundCompleted;
  int firstQueNumber;
  int correctOnes = 0;
  int wrongOnes = 0;
  bool isReadyScreen = true;

  int player1Score = 0;
  int player2Score = 0;
  int player1corrects = 0;
  int player1wrongs = 0;
  int player2corrects = 0;
  int player2wrongs = 0;

  CameraController cameraController;
  List<CameraDescription> cameras;
  String videoPath = '';
  bool cameraInitialized;

//  int firstQueNumberOfPlayer2;
  List<Question> miniList0 = List<Question>();
  List<Question> miniList1 = List<Question>();

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final audios = [
    Audio("assets/audios/right.mp3"),
    Audio("assets/audios/wrong.mp3")
  ];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    closeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstQueNumber = currentQueNum;

    timer = originalTimer;
    optionsList = [
      quesList[currentQueNum].optA,
      quesList[currentQueNum].optB,
      quesList[currentQueNum].optC,
      quesList[currentQueNum].optD
    ];
    assetsAudioPlayer.loop = false;
    assetsAudioPlayer.setVolume(1.0);
    if (permissionToRecordVideo == true) {
      intializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (timer > 0) {
          dealMovingBack();
        }
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
                    horizontal: MediaQuery.of(context).size.width / 30,
                    vertical: MediaQuery.of(context).size.height / 100),
                child: isReadyScreen != true
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            topRow(),
                            queStateMent(),
                            showAlertDialog ? Container() : optsCol(),
                            btnsRow(!showAlertDialog)
                          ],
                        ),
                      )
                    : readyScr(),
              ),
            ],
          ),
        ),
      ),
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

  BoxDecoration whiteBox(bool isBlue) {
    return BoxDecoration(
        color: isBlue
            ? Color(turnNum == 0 ? Constant.blueColor2 : Constant.redColor)
            : Colors.white,
        borderRadius: BorderRadius.circular(15.0));
  }

  BoxDecoration purpleBox(bool isYellow) {
    return BoxDecoration(
      color: Color(isYellow ? Constant.yellowColor : Constant.conColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  TextStyle textStyle(bool isBlack, int fontWeightNum) {
    return TextStyle(
        color: isBlack ? Colors.black : Colors.white,
        fontWeight: fontWeights[fontWeightNum]);
  }

  Widget topRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[backIcon(), timerCon(), playerNumBox()],
      ),
    );
  }

  Widget timerCon() {
    return Container(
      decoration: whiteBox(false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: MediaQuery.of(context).size.width / 15),
      child: Center(
        child: Text(
          timer > 9 ? "${timer}" : timer > 0 ? "0${timer}" : "0",
          textScaleFactor: 1.25,
          style: textStyle(true, 2),
        ),
      ),
    );
  }

  Widget playerNumBox() {
    return Container(
      decoration: whiteBox(true),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Center(
        child: Text(
          "Player ${turnNum + 1}",
          textScaleFactor: 1.25,
          style: textStyle(false, 0),
        ),
      ),
    );
  }

  Widget backIcon() {
    return Container(
//      height: 50.0,
//      width: 50.0,
      decoration: whiteBox(false),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width / 100),
      child: Center(
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(Constant.feroziColor),
          ),
//          icon: Icon(
//            CupertinoIcons.back,
//            color: Color(Constant.feroziColor),
//          ),
          onPressed: timer > 0
              ? () {
                  dealMovingBack();
                }
              : null,
        ),
      ),
    );
  }

  dealMovingBack() async {
    if (isReadyScreen != true) {
      showAlertDialog = !showAlertDialog;
      setState(() {});
    } else {
      if (turnNum == 0) {
        await closeCamera();
        assetsAudioPlayer.dispose();
        Navigator.pop(context);
      }
//      else {
//        timer = 0;
//      }
    }
  }

  /*
  dealMovingBack() {
    if (currentQueNum == firstQueNumber) {
      closeCamera();
      Navigator.pop(context);
    } else {
      setState(() {
        showAlertDialog = !showAlertDialog;
      });
    }
  } */

  Widget queStateMent() {
    return Container(
      decoration: purpleBox(false),
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.75,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 30,
          vertical: MediaQuery.of(context).size.height / 75),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            showAlertDialog != true
                ? quesList[currentQueNum].queStatement
                : "ARE YOU SURE\nYOU WANT TO LEAVE\nTHE GAME?",
            textAlign: TextAlign.center,
            textScaleFactor: 2.0,
            style: textStyle(false, 3),
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
      decoration: purpleBox(optionTapped == optNum ? true : false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Center(
        child: Text(
          opt,
          textScaleFactor: 1.75,
          style: textStyle(optNum == optionTapped ? true : false, 0),
        ),
      ),
    );
  }

  Widget optStateMent(int optNum) {
    int len = optionsList[optNum].length;
    return Container(
      width: MediaQuery.of(context).size.width / 1.35,
      decoration: purpleBox(optionTapped == optNum ? true : false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100,
          horizontal: MediaQuery.of(context).size.width / 20),
      child: Text(
        optionsList[optNum],
        softWrap: true,
        textScaleFactor:
            len < 21 ? 1.65 : len < 41 ? 1.40 : len < 21 ? 1.15 : 1.0,
        style: textStyle(optionTapped == optNum ? true : false, 0),
      ),
    );
  }

  Widget optRow(int optNum) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
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
        onPressed: () async {
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
              if (timer < originalTimer && timer > 0) {
                if (turnNum == 0) {
                  timer = 0;
                  closings();
                } else {
                  timer = 0;
                }
              } else {
                closings();
              }
              //              await closeCamera();
//              Navigator.pop(context);

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
            style: textStyle(btnNum == 0 ? false : true, 3),
          ),
        ));
  }

  Widget btnsRow(bool isRegardingQue) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: timer > 0
          ? Row(
              mainAxisAlignment: isRegardingQue
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: <Widget>[
                reqBtn(0, isRegardingQue),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 20,
                ),
                isRegardingQue == true
                    ? optionTapped == -1
                        ? Container()
                        : reqBtn(1, isRegardingQue)
                    : reqBtn(1, isRegardingQue),
              ],
            )
          : Center(
              child: Text(
                "Time's Up",
                textScaleFactor: 1.75,
                style: textStyle(false, fontWeights.length - 1),
              ),
            ),
    );
  }

  bringNextQue() {
    if (currentQueNum + 1 < quesList.length - 1) {
      currentQueNum = currentQueNum + 1;
    } else {
      roundCompleted = true;
      currentQueNum = 0;
    }
    optionsList = [
      quesList[currentQueNum].optA,
      quesList[currentQueNum].optB,
      quesList[currentQueNum].optC,
      quesList[currentQueNum].optD
    ];
    setState(() {});
  }

  dealNext() {
    quesList[currentQueNum].whatAnswered = optionsList[optionTapped];
    if (quesList[currentQueNum].whatAnswered ==
        quesList[currentQueNum].correctAnswer) {
      assetsAudioPlayer.open(audios[0]);
    } else {
      assetsAudioPlayer.open(audios[1]);
    }

    littleBakchodi();
  }

  littleBakchodi() {
    optionTapped = -1;
    bringNextQue();
  }

  runTimer() {
    Timer.periodic(Duration(seconds: 1), (_timer) {
      if (mounted) {
        if (timer < 0) {
          _timer.cancel();
//          moveToResults();
          calculations();
        } else {
          setState(() {
            timer = timer - 1;
          });
        }
      } else {
        _timer.cancel();
      }
    });
  }

//  calculations() {}

  calculations() async {
//    await closeCamera();
//    List<Question> miniList = List<Question>();
    await initializeMiniListList(turnNum == 0 ? miniList0 : miniList1);
    if (turnNum == 0) {
      await computations();
      setState(() {
        isReadyScreen = true;
      });
    } else {
//      player1result = correctOnes - wrongOnes;
      player2Score = correctOnes - wrongOnes;
      player2corrects = correctOnes;
      player2wrongs = wrongOnes;

      closings();
    }
  }

  computations() async {
    turnNum++;
    timer = originalTimer;
    firstQueNumber = currentQueNum;
    roundCompleted = false;
    player1Score = correctOnes - wrongOnes;
    player1corrects = correctOnes;
    player1wrongs = wrongOnes;
    correctOnes = 0;
    wrongOnes = 0;
    optionTapped = -1;
    await littleBakchodi();
  }

  closings() async {
    assetsAudioPlayer.dispose();
    await closeCamera();
//    if (player1Score != player2Score) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => player1Score != player2Score
                ? OneByOneResults(
                    originalTimer,
                    currentQueNum,
                    permissionToRecordVideo,
                    player1corrects,
                    player1wrongs,
                    player2corrects,
                    player2wrongs,
                    videoPath,
                    miniList0,
                    miniList1,
                    quesList)
                : OneByOneDraw(
                    originalTimer,
                    currentQueNum,
                    permissionToRecordVideo,
                    player1corrects,
                    player1wrongs,
                    player2corrects,
                    player2wrongs,
                    videoPath,
                    miniList0,
                    miniList1,
                    quesList)));
//    }
  }

  initializeMiniListList(List<Question> miniList) {
    if (roundCompleted != true) {
      for (int i = firstQueNumber; i < currentQueNum; i++) {
        if (quesList[i].whatAnswered != null) {
          miniList.add(quesList[i]);

          if (quesList[i].correctAnswer == quesList[i].whatAnswered) {
            correctOnes++;
          } else {
            wrongOnes++;
          }
        }
      }
    } else {
      for (int i = firstQueNumber; i < quesList.length - 1; i++) {
        miniList.add(quesList[i]);
        if (quesList[i].correctAnswer == quesList[i].whatAnswered) {
          correctOnes++;
        } else {
          wrongOnes++;
        }
      }
      if (currentQueNum > 0) {
        for (int i = 0; i < currentQueNum; i++) {
          miniList.add(quesList[i]);
          if (quesList[i].correctAnswer == quesList[i].whatAnswered) {
            correctOnes++;
          } else {
            wrongOnes++;
          }
        }
      }
    }
  }

  Widget readyScr() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              turnNum == 0 ? backIcon() : Container(),
              Container()
            ],
          ),
          Container(
            decoration: whiteBox(true),
            height: MediaQuery.of(context).size.width / 3,
            width: MediaQuery.of(context).size.width / 3,
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 50,
                horizontal: MediaQuery.of(context).size.width / 40),
            child: Center(
              child: Text(
                "PLAYER\n${turnNum + 1}",
                textAlign: TextAlign.center,
                style: textStyle(false, 1),
                textScaleFactor: 1.75,
              ),
            ),
          ),
          Text(
            "READY",
            style: textStyle(false, 2),
            textScaleFactor: 3.5,
          ),
          Container(),
          Container(),
          RaisedButton(
            onPressed: () {
              setState(() {
                isReadyScreen = false;
              });
              runTimer();
            },
            color: Color(Constant.yellowColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 50),
              child: Center(
                child: Text(
                  "START",
                  style: textStyle(true, 2),
                  textScaleFactor: 1.5,
                ),
              ),
            ),
          ),
          Container(),
        ],
      ),
    );
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
        '${(await getApplicationDocumentsDirectory()).path}/${quesList[currentQueNum].category}');
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
}
