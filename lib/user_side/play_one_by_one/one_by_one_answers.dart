import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';

class OneByOneAnswers extends StatefulWidget {
  Widget topRow;

//  Widget btnsRow;
  int player1Corrects;
  int player1Wrongs;
  int player2Corrects;
  int player2Wrongs;
  List<Question> miniList0;
  List<Question> miniList1;

  OneByOneAnswers(
      this.topRow,
//      this.btnsRow,
      this.player1Corrects,
      this.player1Wrongs,
      this.player2Corrects,
      this.player2Wrongs,
      this.miniList0,
      this.miniList1);

  @override
  _OneByOneAnswersState createState() => _OneByOneAnswersState(
      topRow,
//      btnsRow,
      player1Corrects,
      player1Wrongs,
      player2Corrects,
      player2Wrongs,
      miniList0,
      miniList1);
}

class _OneByOneAnswersState extends State<OneByOneAnswers> {
  Widget topRow;

//  Widget btnsRow;
  int player1Corrects;
  int player1Wrongs;
  int player2Corrects;
  int player2Wrongs;
  List<Question> miniList0;
  List<Question> miniList1;

  _OneByOneAnswersState(
      this.topRow,
//      this.btnsRow,
      this.player1Corrects,
      this.player1Wrongs,
      this.player2Corrects,
      this.player2Wrongs,
      this.miniList0,
      this.miniList1);

  int player1Score;
  int player2Score;
  bool isPlayer1Won;
  bool isTie;
  List<FontWeight> fontWeights = [
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    player1Score = player1Corrects - player1Wrongs;
    player2Score = player2Corrects - player2Wrongs;
    isPlayer1Won = player1Score > player2Score ? true : false;

    isTie = player1Score == player2Score ? true : false;


  }

  int currentPlayerSelected = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(Constant.purpleColor),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 50,
            horizontal: MediaQuery.of(context).size.width / 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              topRow,
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              playersRow(),
              decisionsRow(),
              quesList(),
//              Padding(
//                padding: EdgeInsets.symmetric(
//                    vertical: MediaQuery.of(context).size.height / 35),
//                child: btnsRow,
//              )
            ],
          ),
        ),
      ),
    ));
  }

  BoxDecoration playerBoxDecoration(bool isBlue, int itemNum) {
    return BoxDecoration(
        color: Color(isBlue ? Constant.blueColor2 : Constant.redColor),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color: currentPlayerSelected == itemNum
                ? Colors.white
                : Colors.transparent,
            width: 3.0));
  }

  Widget playerCol(bool isBlue, int itemNum, bool isWon) {
    return Column(
      children: <Widget>[crownOrCon(isWon), playerCon(isBlue, itemNum)],
    );
  }

  Widget crownOrCon(bool isWon) {
//    return Container(
//        height: 75.0,
//        width: 75.0,
//        child: Image.asset(
//          Constant.crownAsset,
//          fit: BoxFit.cover,
//        ));
    return Container(
        margin: EdgeInsets.only(bottom: 0.2),
        height: 75.0,
        width: 75.0,
        child: isTie != true
            ? isWon
                ? Image.asset(
                    Constant.crownAsset,
                    fit: BoxFit.cover,
                  )
                : Container()
            : Container());
  }

  Widget playerCon(bool isBlue, int currentPlayer) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentPlayerSelected = currentPlayer;
        });
      },
      child: Container(
        decoration: playerBoxDecoration(isBlue, currentPlayer),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 50,
            horizontal: MediaQuery.of(context).size.width / 25),
        child: Center(
          child: Text(
            isBlue ? "Player 1" : "Player 2",
            textScaleFactor: 1.125,
            style: textStyle(1),
          ),
        ),
      ),
    );
  }

  Widget playersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
//        playerCon(true, 0),
//        playerCon(false, 1),
        playerCol(true, 0, isPlayer1Won),
        playerCol(false, 1, !isPlayer1Won)
      ],
    );
  }

  TextStyle textStyle(int itemNum) {
    return TextStyle(color: Colors.white, fontWeight: fontWeights[itemNum]);
  }

  BoxDecoration rightBox(bool isWrong) {
    return BoxDecoration(
      color: Color(Constant.lightConColor2),
      borderRadius: BorderRadius.circular(17.5),
      border: Border.all(
          color:
              Color(isWrong == false ? Constant.greenColor : Constant.redColor),
          width: 4.0),
    );
  }

  Widget decisionsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(),
          decisionCol(false),
          decisionCol(true),
          Container()
        ],
      ),
    );
  }

  Widget decisionCol(bool isWrong) {
    return Column(
      children: <Widget>[
        Text(
          isWrong ? "WRONG" : "RIGHT",
          style: textStyle(1),
          textScaleFactor: 1.5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 100,
        ),
        decisionBox(isWrong),
      ],
    );
  }

  Widget decisionBox(bool isWrong) {
    return Container(
      decoration: rightBox(isWrong),
      height: 75.0,
      width: 75.0,
      child: Center(
        child: Text(
          "${currentPlayerSelected == 0 ? isWrong ? player1Wrongs : player1Corrects : isWrong ? player2Wrongs : player2Corrects}",
          style: textStyle(2),
          textScaleFactor: 1.125,
        ),
      ),
    );
  }

  BoxDecoration queBoxDecoration(bool isFerozi) {
    return BoxDecoration(
      color: Color(Constant.lightConColor),
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(
          color: Color(
            isFerozi ? Constant.feroziColor : Constant.redColor,
          ),
          width: 4.0),
    );
  }

  Widget quesList() {
    List<Widget> tmp = List<Widget>();
    List<Widget> tmp1 = List<Widget>();
    for (int i = 0; i < miniList0.length; i++) {
      tmp.add(queContainer(miniList0[i]));
    }
    for (int j = 0; j < miniList1.length; j++) {
      tmp1.add(queContainer(miniList1[j]));
    }
    return Column(
      children: currentPlayerSelected == 0 ? tmp : tmp1,
    );
  }

  Widget queContainer(Question question) {
    double _height = MediaQuery.of(context).size.height / 2.5;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: queBoxDecoration(
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
                    style: textStyle(3),
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
              style: textStyle(0),
              textScaleFactor: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
