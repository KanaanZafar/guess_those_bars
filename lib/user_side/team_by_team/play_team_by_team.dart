import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/team_by_team/draw_team_by_team.dart';
import 'package:guessthosebars/user_side/team_by_team/results_team_by_team.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors/sensors.dart';

class PlayTeamByTeam extends StatefulWidget {
  int originalTimer;
  int turnNum;
  int currentQueNum;
  bool permissionToRecordVideo;
  List<Question> questionsList;

  PlayTeamByTeam(this.originalTimer, this.turnNum, this.currentQueNum,
      this.permissionToRecordVideo, this.questionsList);

  @override
  _PlayTeamByTeamState createState() => _PlayTeamByTeamState(originalTimer,
      turnNum, currentQueNum, permissionToRecordVideo, questionsList);
}

class _PlayTeamByTeamState extends State<PlayTeamByTeam> {
  int originalTimer;
  int turnNum;
  int currentQueNum;
  bool permissionToRecordVideo;
  List<Question> questionsList;

  _PlayTeamByTeamState(this.originalTimer, this.turnNum, this.currentQueNum,
      this.permissionToRecordVideo, this.questionsList);

  List<FontWeight> fontWeights = [
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];
  List<String> ansList;
  int timer;
  String otherAns = '';
  bool answeredYet;
  bool isAnswereCorrect;
  StreamSubscription<GyroscopeEvent> gyroscopeSb;
  bool isReadyScreen = true;

//  int correctOnes = 0;
//  int wrongOnes = 0;
  bool roundCompleted = false;
  List<Question> miniList0 = List<Question>();
  List<Question> miniList1 = List<Question>();
  int firstQueNumber;

  int player1corrects = 0;
  int player1wrongs = 0;
  int player2corrects = 0;
  int player2wrongs = 0;

  int player1Score;
  int player2Score;

  CameraController cameraController;
  List<CameraDescription> cameras;
  String videoPath = '';
  bool cameraInitialized;
  bool showAlertDialog = false;
  bool pleaseWait = false;

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final audios = [
    Audio("assets/audios/right.mp3"),
    Audio("assets/audios/wrong.mp3")
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = originalTimer;
    firstQueNumber = currentQueNum;
    assetsAudioPlayer.loop = false;
    assetsAudioPlayer.setVolume(1.0);
    bakchodi();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setOrientationHorizontal(true);

//      getSPData();
//      intializeWords();
//      vishudChutiyapa();
    });
    if (permissionToRecordVideo == true) {
      intializeController();
    }
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    gyroscopeSb?.cancel();
    setOrientationHorizontal(false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: timer > 0
            ? () {
                if (turnNum == 0 && isReadyScreen) {
                  dealMovingBack();
                } else {
                  setState(() {
                    showAlertDialog = !showAlertDialog;
                  });
                }
              }
            : () {},
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
                    vertical: MediaQuery.of(context).size.height / 50,
                    horizontal: MediaQuery.of(context).size.width / 75),
                child: pleaseWait == true
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Please Wait",
                              style: textStyle(true, 3),
                              textScaleFactor: 1.75,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 20,
                            ),
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              backIcon(),
                              timer > 0
                                  ? Center(
                                      child: ansWid(questionsList[currentQueNum]
                                          .correctAnswer),
                                    )
                                  : Container(),
//                Container(),
                              Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.all(2.0),
                                child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.transparent,
                                    ),
                                    color: Colors.transparent,
                                    onPressed: null),
                              )
                            ],
                          ),
                          centralRow(),
                          showAlertDialog != true
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(),
                                    timer > 0
                                        ? ansWid(otherAns)
                                        : Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                8,
                                          ),
                                    Container()
                                  ],
                                )
                              : btnsRow()
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  setOrientationHorizontal(bool isHorizontal) async {
    await SystemChrome.setPreferredOrientations(isHorizontal == true
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  dealStreamSubscription() {
//   double limit = permissionToRecordVideo == true ? 4.0 : 1.5;
    double limit = 2.0;
    gyroscopeSb = gyroscopeEvents.listen((GyroscopeEvent event) {
//      print('answerTrueYetNow : ${event.y}');

      if (event.y > -limit && event.y < limit) {
        setState(() {
          answeredYet = false;
        });
      }

      if (answeredYet == false) {
        if (event.y > limit) {
          gyroscopeSb.cancel();
          setState(() {
            answeredYet = true;
//            blinkingClr = Color(StaticInfo.yellowColor2);
          });
//          rightAudioPlayer.play();
//          assetsAudioPlayer.playlistPlayAtIndex(0);
//assetsAudioPlayer.open(playable)
//          assetsAudioPlayer.open(audios[0]);
          isAnswereCorrect = true;
          if (timer > 0) {
            dealTheAnswer();
          }
        } else if (event.y < -limit) {
          gyroscopeSb.cancel();

          setState(() {
            answeredYet = true;
//            blinkingClr = Colors.red;
          });
//          wrongAudioPlayer.play();
//          assetsAudioPlayer.open(audios[1]);
          isAnswereCorrect = false;
          if (timer > 0) {
            dealTheAnswer();
          }
        }
      }
    });
  }

  bringNextQue() {
    if (currentQueNum + 1 < questionsList.length - 1) {
      currentQueNum = currentQueNum + 1;
    } else {
      roundCompleted = true;
      currentQueNum = 0;
    }
    bakchodi();
//    optionsList = [
//      quesList[currentQueNum].optA,
//      quesList[currentQueNum].optB,
//      quesList[currentQueNum].optC,
//      quesList[currentQueNum].optD
//    ];
    setState(() {});
  }

  dealTheAnswer() async {
//    print('deal the answer');
    if (isAnswereCorrect == true) {
//      correctOnes++;
//      if (turnNum == 0) {
//        player1corrects++;
//      } else {
//        player2corrects++;
//      }
      questionsList[currentQueNum].whatAnswered =
          questionsList[currentQueNum].correctAnswer;
      assetsAudioPlayer.open(audios[0]);
    } else {
      questionsList[currentQueNum].whatAnswered = otherAns;
      assetsAudioPlayer.open(audios[1]);
      //      wrongOnes++;
//      if (turnNum == 0) {
//        player1wrongs++;
//      } else {
//        player2wrongs++;
//      }
    }
    if (turnNum == 0) {
      miniList0.add(questionsList[currentQueNum]);
    } else {
      miniList1.add(questionsList[currentQueNum]);
    }
    await bringNextQue();
//    if () {}
    dealStreamSubscription();
  }

  dealMovingBack() async {
    await setOrientationHorizontal(false);
    await closeCamera();
    assetsAudioPlayer.dispose();
    Navigator.pop(context);
  }

  bakchodi() {
    ansList = [
      questionsList[currentQueNum].optA,
      questionsList[currentQueNum].optB,
      questionsList[currentQueNum].optC,
      questionsList[currentQueNum].optD
    ];
    int indexOfCrcAns =
        ansList.indexOf(questionsList[currentQueNum].correctAnswer);
    Random rand = Random();
    int rand1 = rand.nextInt(3);
    if (indexOfCrcAns == rand1) {
      if (indexOfCrcAns == ansList.length - 1) {
        rand1 = 0;
      } else {
        rand1 = rand1 + 1;
      }
    }
    otherAns = ansList[rand1];
    setState(() {});
  }

  Widget backIcon() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: smallboxDecoration(true),
//        padding: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
        padding: EdgeInsets.all(2.0),
        child: Center(
          child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Color(Constant.feroziColor),
              ),
              onPressed: timer > 0
                  ? () {
                      if (isReadyScreen == true && turnNum == 0) {
                        dealMovingBack();
                      } else {
                        setState(() {
                          showAlertDialog = !showAlertDialog;
                        });
                      }
                    }
                  : () {}),
        ),
      ),
    );
  }

  BoxDecoration bigBoxDecoration() {
    return BoxDecoration(
        color: Color(Constant.lightConColor2),
        borderRadius: BorderRadius.circular(20.0));
  }

  BoxDecoration smallboxDecoration(bool isWhite) {
    return BoxDecoration(
      color: isWhite
          ? Colors.white
          : Color(turnNum == 0 ? Constant.blueColor2 : Constant.redColor),
      borderRadius: BorderRadius.circular(17.5),
    );
  }

  BoxDecoration ansBoxDecoration(bool isGreen) {
    return BoxDecoration(
      color: Color(Constant.lightConColor),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
          color: Color(
            isGreen ? Constant.greenColor : Constant.redColor,
          ),
          width: 2.5),
    );
  }

  TextStyle textStyle(bool isWhite, fontNum) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black,
        fontWeight: fontWeights[fontNum]);
  }

  Widget queStmnt() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 35,
          horizontal: MediaQuery.of(context).size.width / 80),
      decoration: bigBoxDecoration(),
      width: (MediaQuery.of(context).size.width / 1.15) - 80.0,
//      height: MediaQuery.of(context).size.height/1.5,
      child: Center(
        child: showAlertDialog == true
            ? Text(
                'ARE YOU SURE YOU WANT\nTO LEAVE THIS GAME?',
                style: textStyle(true, 3),
                textScaleFactor: 1.75,
                textAlign: TextAlign.center,
              )
            : isReadyScreen == false
                ? SingleChildScrollView(
                    child: Text(
                    timer > 0
                        ? questionsList[currentQueNum].queStatement
                        : "TIME'S UP",
                    style: textStyle(true, 3),
                    textScaleFactor: timer > 0 ? 1.75 : 2.5,
                    textAlign: TextAlign.center,
                  ))
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        isReadyScreen = !isReadyScreen;
                      });
                      runTimer();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height - 1.0,
                      width: MediaQuery.of(context).size.width - 1.0,
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          'READY',
                          textScaleFactor: 5.0,
                          style: textStyle(true, 3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget timerWid() {
    return Container(
      decoration: smallboxDecoration(true),
//      padding: EdgeInsets.symmetric(
//          vertical: MediaQuery.of(context).size.height / 25,
//          horizontal: MediaQuery.of(context).size.width / 50),
//     width: MediaQuery.of(context).size.width/25,
//      height: Media,
      width: 80.0, height: 80.0,
      child: Center(
        child: Text(
          ":${timer > 9 ? timer : timer > 0 ? "0${timer}" : '0'}",
          textScaleFactor: 1.5,
          style: textStyle(false, 1),
        ),
      ),
    );
  }

  Widget teamBox() {
    return Container(
      decoration: smallboxDecoration(false),
//      padding: EdgeInsets.symmetric(
//          vertical: MediaQuery.of(context).size.height / 25,
//          horizontal: MediaQuery.of(context).size.width / 50),
      height: 80.0, width: 80.0,
      child: Center(
        child: Text(
          turnNum == 0 ? "TEAM\nBLUE" : "TEAM\nRED",
          textAlign: TextAlign.center,
          style: textStyle(true, 1),
          textScaleFactor: 1.25,
        ),
      ),
    );
  }

  Widget miniCol() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[Container(), timerWid(), teamBox(), Container()],
    );
  }

  Widget centralRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Container(), queStmnt(), miniCol()],
      ),
    );
  }

  Widget ansWid(String ans) {
    return Container(
      height: MediaQuery.of(context).size.height / 8,
      width: MediaQuery.of(context).size.width / 1.825,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 50,
        horizontal: MediaQuery.of(context).size.width / 35,
      ),
      decoration: isReadyScreen == false
          ? ansBoxDecoration(
              ans == questionsList[currentQueNum].correctAnswer ? true : false)
          : BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.transparent)),
      child: isReadyScreen == false
          ? Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  ans, maxLines: 1,
//           'fkg\ndkfghkdfhgkdhfgkdhfjkdhfgkjdhfgkdhfkdhgf\ndfjsdf',
                  style: textStyle(true, 0),
                  textScaleFactor: 1.125,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Container(),
    );
  }

  runTimer() {
    dealStreamSubscription();
    Timer.periodic(Duration(seconds: 1), (_timer) async {
      if (mounted) {
        if (timer < 0) {
          _timer.cancel();
          gyroscopeSb.cancel();
//          moveToResults();
          await calculations();
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

  calculations() async {
//    await closeCamera();
//    List<Question> miniList = List<Question>();
//    await initializeMiniListList(turnNum == 0 ? miniList0 : miniList1);
//    print('miniList0: ${miniList0.length}\n');
//
//    print('miniList1: ${miniList1.length}');
    if (turnNum == 0) {
      await computing();
      setState(() {
        isReadyScreen = true;
      });
    } else {
//     await closeCamera();

//      player2corrects = correctOnes;
//      player2wrongs = wrongOnes;
//      player2Score = correctOnes - wrongOnes;

      closing();
    }
  }

  computing() async {
    turnNum++;
    timer = originalTimer;
    firstQueNumber = currentQueNum;
    roundCompleted = false;
//    player1Score = correctOnes - wrongOnes;
//    player1corrects = correctOnes;
//    player1wrongs = wrongOnes;
//    correctOnes = 0;
//    wrongOnes = 0;
//      await littleBakchodi();
    await bringNextQue();
  }

  closing() async {
    assetsAudioPlayer.dispose();
    await closeCamera();
    await setOrientationHorizontal(false);
    for (int i = 0; i < miniList0.length; i++) {
      for (int i = 0; i < miniList0.length; i++) {
        if (miniList0[i].whatAnswered == miniList0[i].correctAnswer) {
          player1corrects = player1corrects + 1;
        } else {
          player1wrongs = player1wrongs + 1;
        }
      }
      for (int i = 0; i < miniList1.length; i++) {
        if (miniList1[i].whatAnswered == miniList1[i].correctAnswer) {
          player2corrects = player2corrects + 1;
        } else {
          player2wrongs = player2wrongs + 1;
        }
      }

      player1Score = player1corrects - player1wrongs;
      player2Score = player2corrects - player2wrongs;
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => player1Score == player2Score
                ? DrawTeamByTeam(
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
                    questionsList)
                : ResultsTeamByTeam(
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
                    questionsList)));
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

  closeCamera() {
    if (permissionToRecordVideo == true) {
      if (cameraController.value.isRecordingVideo) {
        cameraController.stopVideoRecording();
      }
      cameraController.dispose();
    }
  }

  Widget btnsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[reqBtn(true), reqBtn(false)],
    );
  }

  Widget reqBtn(bool isNo) {
    return RaisedButton(
      onPressed: () async {
        if (isNo == true) {
          setState(() {
            showAlertDialog = false;
          });
        } else {
          setState(() {
            pleaseWait = true;
          });
          if (timer < originalTimer && timer > 0) {
            if (turnNum == 0) {
//            calculations();

              timer = 0;
              gyroscopeSb?.cancel();
              closing();

              //            isReadyScreen = false;
//            runTimer();
//            timer = 0;
            } else {
              timer = 0;
            }
          } else if (timer == originalTimer) {
            closing();
          }
          //          turnNum = 1;
//          timer = 0;
        }
      },
      color: Color(isNo ? Constant.lightConColor2 : Constant.yellowColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.5),
        side: BorderSide(
            color: isNo ? Color(Constant.yellowColor) : Colors.transparent),
      ),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 50,
        horizontal: MediaQuery.of(context).size.width / 25,
      ),
      child: Center(
        child: Text(
          isNo ? 'No' : 'Yes',
          textScaleFactor: 1.25,
          style: textStyle(isNo, 3),
        ),
      ),
    );
  }
}
