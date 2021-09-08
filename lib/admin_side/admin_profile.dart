import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/auth/login.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:string_validator/string_validator.dart';

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  List<String> linkStrings = ['Terms & Conditions Link', 'Privacy Policy Link'];
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
          2, (generator) => TextEditingController());
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(color: Colors.white),
  );
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  bool saving = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLinks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(Constant.purpleColor),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 20,
                vertical: MediaQuery.of(context).size.height / 50),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.90),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      topRow(),
                      linksCol(),
                      Container(),
                      Container(),
                      btns(),
                      Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget linksCol() {
    return Column(
      children: <Widget>[
        miniCol(0),
        SizedBox(
          height: MediaQuery.of(context).size.height / 100,
        ),
        miniCol(1)
      ],
    );
  }

  Widget miniCol(int linkNum) {
    return Column(
      children: <Widget>[
        linkTExt(linkNum),
        linkField(linkNum),
      ],
    );
  }

  Widget linkTExt(int linkNum) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          linkStrings[linkNum],
          style: textStyle(false),
          textScaleFactor: 1.25,
        ),
      ),
    );
  }

  Widget linkField(int linkNum) {
    return TextFormField(
      controller: controllers[linkNum],
      decoration: InputDecoration(
          border: outlineInputBorder,
          focusedErrorBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          errorBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          disabledBorder: outlineInputBorder,
          errorStyle: textStyle(false),
          hintStyle: textStyle(false),
          fillColor: Color(Constant.textFieldColor),
          filled: true,
          hintText: '${linkStrings[linkNum]} here'),
      validator: (txt) {
        if (!isURL(txt)) {
          return "Invalid Url";
        }
      },
      style: textStyle(false),
    );
  }

  Widget topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        backIcon(false),
        Text(
          "PROFILE",
          style: textStyle(true),
          textScaleFactor: 1.5,
        ),
//        Container(),
//        Container()
        backIcon(true),
      ],
    );
  }

  TextStyle textStyle(bool isBold) {
    return TextStyle(
      color: Colors.white,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
    );
  }

  Widget backIcon(bool isFarig) {
    return Container(
      decoration: BoxDecoration(
          color: isFarig == false ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.transparent)),
      width: 50.0,
      child: Center(
        child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isFarig ? Colors.transparent : Color(Constant.feroziColor),
            ),
            onPressed: () {
              if (isFarig == false) {
                Navigator.pop(context);
              }
            }),
      ),
    );
  }

  Widget btns() {
    return Column(
      children: <Widget>[
        saving != true
            ? reqBtn(0)
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Saving',
                      style: textStyle(true),
                      textScaleFactor: 1.75,
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  ],
                ),
              ),
        reqBtn(1)
      ],
    );
  }

  Widget reqBtn(int btnNum) {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 80),
        child: FlatButton(
          onPressed: () {
            if (btnNum == 0) {
              dealSave();
            } else {
              dealLogout();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.white),
          ),
          color: Color(Constant.conColor),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                btnNum == 0 ? "SAVE" : 'LOGOUT',
                style: textStyle(true),
                textScaleFactor: 1.5,
              ),
            ),
          ),
        ));
  }

  dealSave() async {
    if (formKey.currentState.validate()) {
      try {
        setState(() {
          saving = true;
        });
        await writeLinks();
        setState(() {
          saving = false;
        });
        showSnackBar('Successfully Saved');
      } catch (e) {
        showSnackBar(e.toString());
      }
    }
  }

  writeLinks() async {
    await dbref.child(Constant.links).set({
      Constant.termsAndConditions: controllers[0].text,
      Constant.privacyPolicy: controllers[1].text
    });
  }

  getLinks() async {
    await dbref.child(Constant.links).once().then((dataSnapshot) {
      if (dataSnapshot != null) {
        controllers[0].text = dataSnapshot.value[Constant.termsAndConditions];
        controllers[1].text = dataSnapshot.value[Constant.privacyPolicy];
        setState(() {});
      }
    });
  }

  showSnackBar(String msg) {
    SnackBar snackBar = SnackBar(content: Text(msg));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  dealLogout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (ctx) => Login()), (a) => false);
  }
}
