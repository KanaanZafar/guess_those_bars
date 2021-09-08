import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/play_game.dart';
import 'package:guessthosebars/user_side/play_one_by_one/playonebyone.dart';
import 'package:guessthosebars/user_side/team_by_team/play_team_by_team.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOptions extends StatefulWidget {
  int modeNum;
  List<Question> questionsList;
  Widget catWidget;

  GameOptions(this.modeNum, this.questionsList, this.catWidget);

  @override
  _GameOptionsState createState() =>
      _GameOptionsState(modeNum, questionsList, catWidget);
}

class _GameOptionsState extends State<GameOptions> {
  int modeNum;
  List<Question> questionsList;
  Widget catWidget;

  _GameOptionsState(this.modeNum, this.questionsList, this.catWidget);

  int gameDuration = 0;
  bool permissionToRecordVideo = false;
  double boxConsMultiplier = 0.9;
  int btnNumTapped = -1;
  bool customOpened = false;
  SharedPreferences sharedPreferences;
  int currentQueNum;

//  int customBtnDuration = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (modeNum > 0) {
      boxConsMultiplier = 0.95;
    }

    dealSharedPreferences();

    setState(() {});
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    dealSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
//   boxConsMultiplier =modeNum ==0  0.9;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(Constant.purpleColor),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 20,
              vertical: MediaQuery.of(context).size.height / 75),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height * boxConsMultiplier),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(),
                  topRow(), Container(),
                  selectTime(), // Container(),
                  customOpened ? customBtnList() : Container(),
                  recordVideo(), Container(),
                  modeNum > 0 ? secLastBox() : Container(),
                  Container(),
                  currentQueNum != null ? playBtn() : Container(),
                  Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration boxDecoration(bool isWhite) {
    return BoxDecoration(
      color: isWhite ? Colors.white : Color(Constant.conColor),
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  TextStyle textStyle(bool isBold, isWhite) {
    return TextStyle(
      color: isWhite ? Colors.white : Colors.black,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
    );
  }

  Widget customBtnList() {
    List<Widget> tmp = List<Widget>();
    int initialNum = 15;
    for (int i = 1; i < 6; i++) {
      initialNum = (initialNum * 1) + 15;
      tmp.add(
        Row(
          children: <Widget>[
            customBtnOpts(initialNum),
            i < 5 ? spacerInCus() : Container()
          ],
        ),
      );
    }
    return Container(
      decoration: boxDecoration(true),
//      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: MediaQuery.of(context).size.width / 50),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tmp,
//        children: <Widget>[
//          customBtnOpts(30),
//          spacerInCus(),
//          customBtnOpts(45),
//          spacerInCus(),
//          customBtnOpts(60),
//          spacerInCus(),
//          customBtnOpts(75),
//          spacerInCus(),
//          customBtnOpts(90),
////          spacerInCus()
//        ],
        ),
      ),
    );
  }

  Widget spacerInCus() {
    return Container(
      width: 1,
      height: MediaQuery.of(context).size.height / 20,
      color: Colors.black,
    );
  }

  Widget customBtnOpts(int dur) {
    return GestureDetector(
      onTap: () {
//        print('dur: ${dur}');

        setState(() {
          gameDuration = dur;
          customOpened = false;
          boxConsMultiplier = 0.95;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20),
        child: Text(
          '${dur}',
//      style: textStyle(false, false),
          textScaleFactor: 1.5,
        ),
      ),
    );
  }

  Widget backIcon() {
    return Container(
      decoration: boxDecoration(true),
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
          },
        ),
      ),
    );
  }

  Widget topRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        backIcon(),
        Container(
//            height: MediaQuery.of(context).size.height / 3.75,
            width: MediaQuery.of(context).size.width / 2.50,
            child: catWidget),
        Container(
          height: 50.0,
          width: 50.0,
          color: Colors.transparent,
        )
      ],
    );
  }

  Widget recordVideo() {
    Widget widget0 = containerTxt("RECORD VIDEO");

    Widget widget1 = Switch(
      value: permissionToRecordVideo,
      onChanged: (val) async {
        if (permissionToRecordVideo == false) {
          await requestPermission();
        } else {
          permissionToRecordVideo = false;
          setState(() {});
        }
      },
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.white,
      inactiveThumbColor: Colors.red,
      activeColor: Colors.green,
    );

    return Container(
      decoration: boxDecoration(false),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75,
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Center(
        child: modeNum == 0
            ? Column(
                children: <Widget>[widget0, widget1],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[widget0, widget1],
              ),
      ),
    );
  }

  Widget containerTxt(String txt) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 30,
          vertical: MediaQuery.of(context).size.height / 75),
      child: Text(
        txt,
        style: textStyle(false, true),
        textAlign: TextAlign.center,
        textScaleFactor: 1.75,
      ),
    );
  }

  Widget selectTime() {
    return Container(
      decoration: boxDecoration(false),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25,
          vertical: MediaQuery.of(context).size.height / 75),
      child: Center(
        child: Column(
          children: <Widget>[
            containerTxt("SELECT TIME"),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  timerBtn(0),
                  timerBtn(1),
                  timerBtn(2),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget timerBtn(int btnNum) {
    return FlatButton(
      onPressed: () {
        if (btnNum == 0) {
          gameDuration = 15;
          setState(() {
            btnNumTapped = btnNum;
            customOpened = false;
            boxConsMultiplier = 0.95;
          });
        } else if (btnNum == 1) {
          gameDuration = 25;
          setState(() {
            customOpened = false;
            btnNumTapped = btnNum;
            boxConsMultiplier = 0.95;
          });
        } else {
          setState(() {
            btnNumTapped = -1;

            customOpened = !customOpened;
            if (customOpened == true) {
              boxConsMultiplier = 1.1;
            } else {
              boxConsMultiplier = 0.95;
            }
          });
        }
      },
      color: btnNum < 2
          ? btnNumTapped == btnNum ? Color(Constant.feroziColor) : Colors.white
          : gameDuration > 25 ? Color(Constant.feroziColor) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        height: 75.0,
        width: 60.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              btnNum < 2
                  ? Text(
                      btnNum == 0 ? "15" : "25",
                      style: textStyle(
                          false, btnNumTapped == btnNum ? true : false),
                      textScaleFactor: 1.5,
                    )
                  : gameDuration > 25
                      ? Text(
                          "${gameDuration}",
                          textScaleFactor: 1.5,
                          style: textStyle(false, true),
                        )
                      : Icon(
                          Icons.expand_more,
                          color: btnNumTapped == btnNum
                              ? Colors.white
                              : Colors.black,
                        ),
              Text(
                btnNum < 2 ? "SECONDS" : "CUSTOM",
                textScaleFactor: 0.8,
                style: textStyle(
                    false,
                    btnNum < 2
                        ? btnNumTapped == btnNum ? true : false
                        : gameDuration > 25 ? true : false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dealPlay() {
    List pages = [
      PlayGame(
          gameDuration, currentQueNum, permissionToRecordVideo, questionsList),
      PlayOneByOne(gameDuration, 0, permissionToRecordVideo, currentQueNum,
          questionsList),
      PlayTeamByTeam(gameDuration, 0, currentQueNum, permissionToRecordVideo,
          questionsList)
    ];
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => pages[modeNum]));
  }

  Widget playBtn() {
    return RaisedButton(
      onPressed: () {
        if (gameDuration > 0) {
          dealPlay();
        } else {
          showSnackBar("Please select time first");
        }
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
            'PLAY',
            textScaleFactor: 1.75,
            style: textStyle(true, false),
          ),
        ),
      ),
    );
  }

  requestPermission() async {
    bool mic = await Permission.microphone.request().isGranted;
    bool cam = await Permission.camera.request().isGranted;
    bool storage = await Permission.storage.request().isGranted;
    bool sensors;
    if (modeNum == 2) {
      sensors = await Permission.sensors.request().isGranted;
    }

    if (mic == true && cam == true && storage == true) {
      if (modeNum < 2) {
        permissionToRecordVideo = true;
      } else {
        if (sensors == true) {
          permissionToRecordVideo = true;
        } else {
          permissionToRecordVideo = false;
        }
      }
    } else {
      permissionToRecordVideo = false;
    }
    setState(() {});
  }

  Widget secLastBox() {
    return Container(
      decoration: boxDecoration(false),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 75,
        horizontal: MediaQuery.of(context).size.width / 35,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(),
            Column(
              children: <Widget>[
                teamBox(true, modeNum == 1 ? "PLAYER\n1" : "TEAM\nBLUE"),
                turnText("1st TURN")
              ],
            ),
            Column(
              children: <Widget>[
                teamBox(false, modeNum == 1 ? "PLAYER\n2" : "TEAM\nRED"),
                turnText("2nd TURN"),
              ],
            ),
            Container()
          ],
        ),
      ),
    );
  }

  Widget turnText(String turn) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Text(
        turn,
        style: textStyle(true, true),
      ),
    );
  }

  Widget teamBox(bool isBlue, String boxName) {
    return Container(
      decoration: BoxDecoration(
        color: isBlue ? Color(Constant.blueColor2) : Color(Constant.redColor),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: containerTxt(boxName),
      ),
    );
  }

  showSnackBar(String txt) {
    SnackBar snackBar = SnackBar(content: Text(txt));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  dealSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt("${questionsList[0].category}") != null) {
      currentQueNum = sharedPreferences.getInt("${questionsList[0].category}");
    } else {
      currentQueNum = 0;
    }
    if (mounted) setState(() {});
  }
}
