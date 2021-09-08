import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/admin_side/admin_side.dart';
import 'package:guessthosebars/models/question.dart';
import 'package:guessthosebars/res/constants.dart';

class AddQuestion extends StatefulWidget {
  Question question;

  AddQuestion(this.question);

  @override
  _AddQuestionState createState() => _AddQuestionState(question);
}

class _AddQuestionState extends State<AddQuestion> {
  Question questionFromPrevClass;

  _AddQuestionState(this.questionFromPrevClass);

  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
          5, (generator) => TextEditingController());
  List<String> hintTexts = ['Write Question statement', 'A', 'B', 'C', 'D'];
  int categoryPointer = -1;
  bool listExpanded = false;
  bool isPremium = false;
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: Colors.transparent));
  int correctAnsNumber = -1;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  bool saving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (questionFromPrevClass.queId == null) {
//      print('yes empty question');

      questionFromPrevClass.queId = 0;
      questionFromPrevClass.queStatement = '';
      questionFromPrevClass.category = -1;
      questionFromPrevClass.optA = '';
      questionFromPrevClass.optB = '';
      questionFromPrevClass.optC = '';
      questionFromPrevClass.optD = '';
      questionFromPrevClass.correctAnswer = '';
      questionFromPrevClass.whatAnswered = Constant.notAnsweredYet;
    } else {
      print('else true');
    }
    controllers[0].text = questionFromPrevClass.queStatement;
    controllers[1].text = questionFromPrevClass.optA;

    controllers[2].text = questionFromPrevClass.optB;
    controllers[3].text = questionFromPrevClass.optC;
    controllers[4].text = questionFromPrevClass.optD;
    categoryPointer = questionFromPrevClass.category;
    if (questionFromPrevClass.correctAnswer == '') {
      correctAnsNumber = -1;
    } else {
      for (int i = 1; i < controllers.length; i++) {
        if (controllers[i].text == questionFromPrevClass.correctAnswer) {
          correctAnsNumber = i;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (ctx) => AdminSide()), (a) => false);
      },
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Constant.wallpaperAsset), fit: BoxFit.cover),
          ),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 75,
                  horizontal: MediaQuery.of(context).size.width / 15),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: backIcon(),
                        ),
                        queStatementCol(),
                        optionsCol(),
                        selectCategory(),
                        listExpanded == true ? categoriesCol() : Container(),
                        saving == false
                            ? btns()
                            : Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Saving  ',
                                      textScaleFactor: 1.75,
                                      style: _textStyle(true, false, 25.0),
                                    ),
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      backgroundColor:
                                          Color(Constant.yellowColor),
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: 40.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget queStatementCol() {
    return reqField(0, 6);
  }

  Widget optionTxt(int itemNum) {
    return GestureDetector(
      onTap: () {
        correctAnsNumber = itemNum;
        setState(() {});
      },
      child: Container(
        decoration: correctAnsNumber == -1 || correctAnsNumber != itemNum
            ? boxDecoration(false)
            : yellowBox(),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width / 25,
            horizontal: MediaQuery.of(context).size.width / 20),
        child: Text(
          hintTexts[itemNum],
          style: _textStyle(
              true,
              correctAnsNumber == -1 || correctAnsNumber != itemNum
                  ? false
                  : true,
              22.5),
        ),
      ),
    );
  }

  Widget optionRow(int itemNum) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        optionTxt(itemNum),
        Container(
          width: MediaQuery.of(context).size.width / 1.40,
          child: reqField(itemNum, 1),
        )
      ],
    );
  }

  Widget optionsCol() {
    List<Widget> tmp = List<Widget>();
    for (int i = 0; i < 4; i++) {
      tmp.add(optionRow(i + 1));
    }
    return Column(
      children: tmp,
    );
  }

  Widget reqField(int conNum, int totalLines) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 80),
      child: TextFormField(
        controller: controllers[conNum],
        decoration: InputDecoration(
          border: outlineInputBorder,
          fillColor: Color(correctAnsNumber == conNum
              ? Constant.yellowColor
              : Constant.textFieldColor),
          filled: true,
          disabledBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          errorBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          focusedErrorBorder: outlineInputBorder,
          hintText: '${hintTexts[conNum]} here',
          hintStyle: _textStyle(
              conNum == 0 ? true : false,
              correctAnsNumber == conNum ? true : false,
              conNum == 0 ? 30.0 : 22.5),
        ),
        style: _textStyle(
            conNum == 0 ? true : false,
            correctAnsNumber == conNum ? true : false,
            conNum == 0 ? 30.0 : 22.5),
        maxLines: totalLines,
        validator: (txt) {
          if (txt == '') {
            return 'Please fill this field';
          }
          for (int i = 0; i < controllers.length; i++) {
            if (i != conNum) {
              if (controllers[i].text == txt) {
                return 'Answers cannot be same';
              }
            }
          }
        },
      ),
    );
  }

  TextStyle _textStyle(bool isBold, bool isBlack, double fontSize) {
    return TextStyle(
        color: isBlack ? Colors.black : Colors.white,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.w600);
  }

  BoxDecoration boxDecoration(bool isWhite) {
    return BoxDecoration(
      color: isWhite ? Colors.white : Color(Constant.conColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  BoxDecoration yellowBox() {
    return BoxDecoration(
      color: Color(Constant.yellowColor),
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  Widget selectCategory() {
    return GestureDetector(
      onTap: () {
        listExpanded = !listExpanded;
        setState(() {});
      },
      child: Container(
        decoration: boxDecoration(false),
        width: MediaQuery.of(context).size.width / 1.15,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 75),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 25, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  categoryPointer == -1
                      ? 'CHOOSE CATEGORY'
                      : "${Constant.categoriesList[categoryPointer]}",
                  textScaleFactor: 1.125,
                  style: _textStyle(true, false, 22.5),
                ),
              ),
            ),
            Icon(
              listExpanded == false ? Icons.expand_more : Icons.expand_less,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget categoriesCol() {
    List<Widget> tmp = List<Widget>();
    for (int i = 0; i < Constant.categoriesList.length - 1; i++) {
      tmp.add(singleCategoryWidget(i));
    }
    return Column(
      children: tmp,
    );
  }

  Widget singleCategoryWidget(int catNum) {
    return GestureDetector(
      onTap: () {
        categoryPointer = catNum;
        listExpanded = false;
        setState(() {});
      },
      child: Container(
        decoration: boxDecoration(false),
        width: MediaQuery.of(context).size.width / 1.15,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 100),
        padding: EdgeInsets.symmetric(
            vertical: catNum > 1 ? 0.1 : 10.0,
            horizontal: MediaQuery.of(context).size.width / 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              Constant.categoriesList[catNum],
              textAlign: TextAlign.start,
              style: _textStyle(false, false, 17.5),
            ),
            catNum > 1
                ? Image.asset(
                    Constant.crownAsset,
                    height: 50.0,
                    width: 50.0,
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget btns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        btn(0),
        btn(1),
      ],
    );
  }

  Widget btn(int btnNum) {
    return FlatButton(
        onPressed: () {
          if (btnNum == 1) {
             if (formKey.currentState.validate()) {
              if (categoryPointer != -1) {
                if (correctAnsNumber != -1) {
                  dealSave();
                } else {
                  showSnackBar("Please choose the correct answer");
                }
              } else {
                showSnackBar('Please choose the category');
              }
            }
//            testing();
          } else {
            dealRemove();
          }
        },
        color: Color(btnNum == 0 ? Constant.purpleColor : Constant.yellowColor),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
                color: btnNum == 0 ? Colors.white : Colors.transparent)),
        child: Container(
          width: btnNum == 0
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width / 2.4,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              btnNum == 0 ? 'Remove' : 'SAVE',
              style: btnNum == 0
                  ? _textStyle(false, false, 22.5)
                  : _textStyle(true, true, 22.5),
            ),
          ),
        ));
  }

  dealSave() async {
    setState(() {
      saving = true;
    });
    if (questionFromPrevClass.queId != 0) {
      deleteQuestion();
    }
    Question question = Question();
    question.queId = DateTime.now().millisecondsSinceEpoch;
    question.queStatement = controllers[0].text;
    question.optA = controllers[1].text;
    question.optB = controllers[2].text;
    question.optC = controllers[3].text;
    question.optD = controllers[4].text;
    question.correctAnswer = controllers[correctAnsNumber].text;
//    question.category = Constant.categoriesList[categoryPointer];
    question.whatAnswered = Constant.notAnsweredYet;
    question.category = categoryPointer;
    writeData(question);
  }

  writeData(Question question) async {
    try {
      await dbref
          .child(Constant.questions)
//          .child(categoryPointer > 3 ? Constant.premium : Constant.free)
//          .child(question.category.replaceAll('/', ''))
          .child('${question.category}')
          .child('${question.queId}')
          .set(question.toMap());
      setState(() {
        saving = false;
      });
      showSnackBar("Successfully saved");
      await Future.delayed(Duration(milliseconds: 750));
//      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => AdminSide()),
          (predicate) => false);
    } catch (e) {
      setState(() {
        saving = false;
      });
      showSnackBar(e.toString());
    }
  }

  showSnackBar(String chithi) {
    SnackBar snackBar = SnackBar(content: Text(chithi));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget backIcon() {
    return Container(
      decoration: boxDecoration(true),
      width: 50.0,
      child: Center(
        child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(Constant.feroziColor),
            onPressed: () {
//              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (ctx) => AdminSide()),
                  (predicate) => false);
            }),
      ),
    );
  }

  dealRemove() async {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].text = '';
    }
    categoryPointer = -1;
    correctAnsNumber = -1;
    setState(() {});

    if (questionFromPrevClass.queId != 0) {
      setState(() {
        saving = true;
      });
      await deleteQuestion();
//      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => AdminSide()),
          (predicate) => false);
    }
  }

  deleteQuestion() async {
    await dbref
        .child(Constant.questions)
        .child('${questionFromPrevClass.category}')
        .child('${questionFromPrevClass.queId}')
        .remove();
  }
/*
  testing() async {
    setState(() {
      saving = true;
    });
    for (int i = 0; i < 201; i++) {
      Question question = Question();
      question.queId = DateTime.now().millisecondsSinceEpoch;
//      question.queStatement =
//          "que ${i} cat 2 sansdfgdsfkgldlgjdlfjgldf\ndsfghkdfhgk\nfgjgjdkfgdghkkfjdhkdghkdfhghhdlfjghdfglk\njflksdjflksdjfksjdfjhkdfshdfksgkhdfkghl\nsfkjdhfskhkjhdksghkhdfg\nsansdfgdsfkgldlgjdlfjgldf\ndsfghkdfhgk\nfgjgjdkfgdghkkfjdhkdghkdfhghhdlfjghdfglk\njflksdjflksdjfksjdfjhkdfshdfksgkhdfkghl\nsfkjdhfskhkjhdksghkhdfg\nsansdfgdsfkgldlgjdlfjgldf\ndsfghkdfhgk\nfgjgjdkfgdghkkfjdhkdghkdfhghhdlfjghdfglk\njflksdjflksdjfksjdfjhkdfshdfksgkhdfkghl\nsfkjdhfskhkjhdksghkhdfg\nsansdfgdsfkgldlgjdlfjgldf\ndsfghkdfhgk\nfgjgjdkfgdghkkfjdhkdghkdfhghhdlfjghdfglk\njflksdjflksdjfksjdfjhkdfshdfksgkhdfkghl\nsfkjdhfskhkjhdksghkhdfg";
      question.queStatement = 'Okay This is question ${i} of cateogy 10';
      List anses = [
        "a ${i} Okay This is the answer A",
        "b ${i} Okay This is the answer B",
        "c ${i} Okay This is Answer C",
        "d ${i} Okay This is the answer D"
      ];
      question.optA = anses[0];
      question.optB = anses[1];
      question.optC = anses[2];
      question.optD = anses[3];

      question.correctAnswer = anses[i % 4];
//      question.correctAnswer = controllers[correctAnsNumber].text;
//    question.category = Constant.categoriesList[categoryPointer];
      question.whatAnswered = Constant.notAnsweredYet;
//      question.category = categoryPointer;
      question.category = 9;
      await dbref
          .child(Constant.questions)
//          .child(categoryPointer > 3 ? Constant.premium : Constant.free)
//          .child(question.category.replaceAll('/', ''))
          .child('${question.category}')
          .child('${question.queId}')
          .set(question.toMap());
    }
    setState(() {
      saving = false;
    });
  } */
}
