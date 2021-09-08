import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/res/static_info.dart';
import 'package:guessthosebars/user_side/game_options.dart';
import 'package:guessthosebars/user_side/leader_board.dart';
import 'package:guessthosebars/user_side/user_profile.dart';

class ShowCategories extends StatefulWidget {
  int modeNum;

  ShowCategories(this.modeNum);

  @override
  _ShowCategoriesState createState() => _ShowCategoriesState(modeNum);
}

class _ShowCategoriesState extends State<ShowCategories> {
  int modeNum;
  List<String> gameTypes = [
    Constant.free.toUpperCase(),
    Constant.premium.toUpperCase()
  ];
  int gameTypePointer = 0;
  int freeCatsCount = 2;

//  int premiumCatsCount = 8;
  int premiumCatsCount;

  _ShowCategoriesState(this.modeNum);

  DatabaseReference dbref = FirebaseDatabase.instance.reference();

//  List<List<Question>> listOfLists =
//      List<List<Question>>.generate(11, (generator) => List<Question>());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (modeNum < 2) {
      premiumCatsCount = 5;
    } else {
      premiumCatsCount = 8;
    }
    setState(() {});
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Constant.wallpaperAsset), fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
//            extendBody: false,
//      body: ,
//        extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            child: reqAppBar(),
            preferredSize: Size.fromHeight(100.0),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              gameTypeRows(),
              customGridView(),
              selectMode(),
              gameTypePointer == 0
                  ? buyPremiumCon()
                  : SliverToBoxAdapter(child: Container()),
              leaderBoard(),
              profile(),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ))
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(bool isBold, bool isWhite) {
    return TextStyle(
        color: isWhite ? Colors.white : Colors.black.withOpacity(0.8),
        fontWeight: isBold ? FontWeight.w800 : FontWeight.w500);
  }

  Widget outerCon(Widget widget1, Widget widget2) {
    return Container(
      decoration: boxDecoration(false),
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75,
          horizontal: MediaQuery.of(context).size.width / 6),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 10,
          vertical: MediaQuery.of(context).size.height / 80),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[widget1, widget2],
      )),
    );
  }

  Widget selectMode() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: outerCon(
            whiteCircleIcon(true),
            Text(
              'SELECT MODE',
              style: _textStyle(false, true),
              textScaleFactor: 1.25,
            )),
      ),
    );
  }

  Widget leaderBoard() {
    return SliverToBoxAdapter(
      child: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => LeaderBoard()));
          },
          child: outerCon(
            Text(
              "LEADERBOARD",
              style: _textStyle(false, true),
              textScaleFactor: 1.25,
            ),
            whiteCircleIcon(false),
          )),
    );
  }

  Widget buyPremiumCon() {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width,
        decoration: boxDecoration(true),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 50,
            horizontal: MediaQuery.of(context).size.width / 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                Constant.crownAsset,
                height: 100.0,
                width: 100.0,
                fit: BoxFit.cover,
              ),
              Column(
                children: <Widget>[
                  Text(
                    "BUY PREMIUM",
                    style: _textStyle(true, false),
                    textScaleFactor: 2.0,
                  ),
                  Text(
                    "Get access to unlimited fun",
                    textScaleFactor: 1.0,
                    style: _textStyle(true, false),
                  ),
                ],
              ),
              Container(),
              FlatButton(
                onPressed: () {},
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.75,
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height / 75),
                  child: Center(
                    child: Text(
                      "BUY \$7.99",
                      style: _textStyle(true, true),
                      textScaleFactor: 1.75,
                    ),
                  ),
                ),
              ),
              Container(),
              Container(),
              Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget profile() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => UserProfile()));
        },
        child: outerCon(
          Text(
            "         PROFILE",
            style: _textStyle(false, true),
            textScaleFactor: 1.25,
          ),
          whiteCircleIcon(false),
        ),
      ),
    );
  }

  Widget whiteCircleIcon(bool isSelectMode) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(
        isSelectMode ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
        color: Color(Constant.feroziColor),
      ),
    );
  }

  BoxDecoration boxDecoration(bool isYellow) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(35.0),
      border: Border.all(color: Color(Constant.stylishBorderColor), width: 1.5),
      color: Color(isYellow ? Constant.yellowColor : Constant.conColor),
    );
  }

  Widget catWidget(int catNum) {
//    print('==${catNum} and ${StaticInfo.listOfLists[catNum][0].category}');
    return GestureDetector(
      onTap: StaticInfo.listOfLists[catNum].length > 0
          ? () {
//              print(
//                  'bakchodi: ${listOfLists[catNum].length} \n ${listOfLists[catNum]}');


              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => GameOptions(
                          modeNum,
                          StaticInfo.listOfLists[catNum],
                          catWidgetUi(catNum))));
            }
          : null,
      child: catWidgetUi(catNum),
    );
  }

  Widget catWidgetUi(int catNum) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 50),
      decoration: BoxDecoration(
        color: Color(Constant.textFieldColor),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          catNum > 1
              ? Image.asset(
                  Constant.categoriesAssets[catNum],
//            height: 150.0,
//            width: 150.0,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  Constant.categoriesAssets[catNum],
                  height: 150.0,
                  width: 150.0,
                  fit: BoxFit.cover,
                ),
          catNum < 2
              ? Text(
                  Constant.categoriesList[catNum],
                  style: _textStyle(true, true),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.5,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget customGridView() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 50,
          horizontal: MediaQuery.of(context).size.width / 30),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((ctx, index) {
//          int tmp = gameTypePointer + 1;
//          print('num: ${tmp}');
//          int tmp = gameTypePointer == 0 ? 0 : freeCatsCount;
          int tmp;
          if (gameTypePointer == 0) {
            tmp = 0;
          } else {
            tmp = freeCatsCount;
            if (modeNum < 2) {
              tmp = tmp + 3;
            }
          }

          return catWidget(index + tmp);
        }, //childCount: Constant.categoriesList.length),
            childCount:
                gameTypePointer == 0 ? freeCatsCount : premiumCatsCount),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: MediaQuery.of(context).size.height / 40,
            crossAxisSpacing: MediaQuery.of(context).size.width / 40),
      ),
    );
  }

  readFirebase() {
//    dbref.child(Constant.questions).child('1').onChildAdded.listen((event) {
//      print('--key: ${event.snapshot.key}');
//      print('++ ${event.snapshot.value}');
//    });
    for (int i = 0; i < Constant.categoriesList.length; i++) {
      initalizeList(i);
    }
  }

  initalizeList(int listNum) {
    dbref
        .child(Constant.questions)
        .child('${listNum}')
        .onChildAdded
        .listen((event) {
//      List<Question> tmp = List<Question>();
//      tmp.add(Question.fromMap(event.snapshot.value));
      if (event.snapshot != null) {
        StaticInfo.listOfLists[listNum]
            .add(Question.fromMap(event.snapshot.value));
        int index = StaticInfo.listOfLists[listNum].length;
        if (index % 4 == 0) {
          Question que = Question.fromMap(event.snapshot.value);
          que.category = 10;

          StaticInfo.listOfLists[9].add(que);
//          listOfLists[10].sort((a, b) => b.queId.compareTo(a.queId));
        }

        StaticInfo.listOfLists[listNum]
            .sort((a, b) => b.queId.compareTo(a.queId));
        if (mounted) setState(() {});
      }
    });
  }

  Widget reqAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      color: Color(Constant.purpleColor),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              Constant.mainLogoAsset,
              height: 75.0,
              width: 75.0,
            ),
            SizedBox(
              width: 2.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'GUESS',
                  style: _textStyle(true, true),
                  textScaleFactor: 2.0,
                ),
                Text(
                  ' THOSE BARS',
                  style: _textStyle(true, true),
                  textScaleFactor: 1.125,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget gameTypeRows() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            gameTypeCon(0),
            gameTypeCon(1),
          ],
        ),
      ),
    );
  }

  Widget gameTypeCon(int gametypeNum) {
    return GestureDetector(
      onTap: () {
        setState(() {
          gameTypePointer = gametypeNum;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3.0,
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 100),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: gameTypePointer == gametypeNum
                  ? Color(Constant.stylishBorderColor)
                  : Colors.transparent,
              width: 5.0),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 0.0),
                spreadRadius: 2.5,
                blurRadius: 1.25),
          ],
        ),
        child: Center(
          child: Text(
            gameTypes[gametypeNum],
            textScaleFactor: 1.5,
            style: _textStyle(true, false),
          ),
        ),
      ),
    );
  }
}
