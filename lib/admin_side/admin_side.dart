import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/admin_side/add_question.dart';
import 'package:guessthosebars/admin_side/admin_profile.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';

class AdminSide extends StatefulWidget {
  @override
  _AdminSideState createState() => _AdminSideState();
}

class _AdminSideState extends State<AdminSide> {
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  List<Question> allQuestions = List<Question>();

//  bool dataLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    readFirebase();
    loadList();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
//    loadList();
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
//          appBar: CommonWidget(context).adminAppbar(true),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                topRow(),
                Expanded(
                    child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 10),
                  itemBuilder: (ctx, index) {
                    return questionWidget(allQuestions[index]);
                  },
                  itemCount: allQuestions.length,
                )),
              ],
            ),
          ),
          bottomNavigationBar: addingCon(),
        ),
      ),
    );
  }

  TextStyle _textStyle(bool isBold, bool isFerozi) {
    return TextStyle(
        color: isFerozi ? Color(Constant.feroziColor) : Colors.white,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.w700);
  }

  BoxDecoration _boxDecoration(bool isWhite) {
    return BoxDecoration(
      border: Border.all(color: isWhite ? Colors.transparent : Colors.white),
      borderRadius: BorderRadius.circular(isWhite ? 20.0 : 10.0),
      color: isWhite ? Colors.white : Color(Constant.conColor),
    );
  }

  Widget topRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 70),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            "WELCOME ADMIN",
            textScaleFactor: 2.0,
            style: _textStyle(false, false),
          ),
          queMark()
        ],
      ),
    );
  }

  Widget queMark() {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => AdminProfile()));
      },
      child: Container(
        decoration: _boxDecoration(true),
//      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/75),
//      width: MediaQuery.of(context).size.width/10,
        width: 60.0,
        child: Center(
          child: Text(
            '?',
            style: _textStyle(true, true),
            textScaleFactor: 3.0,
          ),
        ),
      ),
    );
  }

  Widget addingCon() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 15, vertical: 10.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        width: MediaQuery.of(context).size.width,
        decoration: _boxDecoration(false),
        child: Text(
          "+",
          style: _textStyle(true, false),
          textAlign: TextAlign.center,
          textScaleFactor: 2.0,
        ),
      ),
      onTap: () {
        goToAddQuestion(Question());
      },
    );
  }

  loadList() async {
   for (int i = 0; i < Constant.categoriesList.length; i++) {
      await readFirebase(i);
    }
  }

  readFirebase(int catNum) {
    dbref
        .child(Constant.questions)
        .child("${catNum}")
        .onChildAdded
        .listen((event) {
      if (event.snapshot != null) {
        allQuestions.add(Question.fromMap(event.snapshot.value));
        allQuestions.sort((a, b) => b.queId.compareTo(a.queId));
        if (mounted) setState(() {});
      }
    });
  }

  Widget questionWidget(Question question) {
    return GestureDetector(
      onTap: () {
        goToAddQuestion(question);
      },
      child: Container(
        decoration: _boxDecoration(false),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 40,
            vertical: MediaQuery.of(context).size.height / 65),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              question.queStatement.length > 23
                  ? "${question.queStatement.substring(0, 22)}..."
                  : question.queStatement.trim(),
              style: _textStyle(true, false),
              textScaleFactor: 1.5,
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Future<void> goToAddQuestion(Question que) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => AddQuestion(que)));
  }
}

/* genuine working code regarding readfirebase and loadlist
  loadList() async {
    for (int i = 0; i < Constant.categoriesList.length; i++) {
      await readFirebase(i);
    }

    await allQuestions.sort((a, b) => b.queId.compareTo(a.queId));
    setState(() {
      dataLoaded = true;
    });
  }

  readFirebase(int catNum) async {
    await dbref
        .child(Constant.questions)
        .child("${catNum}")
        .once()
        .then((dataSnapshot) {
      if (dataSnapshot != null) {
        Map mainMap;
        mainMap = dataSnapshot.value;
        if (mainMap != null) {
          List valsList = mainMap.values.toList();
          for (int i = 0; i < valsList.length; i++) {
            allQuestions.add(Question.fromMap(valsList[i]));
          }
        }
      }
    });
  }

 */
