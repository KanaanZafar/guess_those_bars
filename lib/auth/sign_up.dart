import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:string_validator/string_validator.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextStyle whiteBold;
  TextStyle blackBold;
  TextStyle whiteNormal;
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
          3, (generator) => TextEditingController());
  OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.transparent));
  List<String> hints = ['Name', 'email', 'password'];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  bool processing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    whiteBold = _textStyle(true, false);
    whiteNormal = _textStyle(false, false);
    blackBold = _textStyle(true, true);
  }

  @override
  Widget build(BuildContext context) {
//    double height = MediaQuery.of(context).size.height;
    double multiplyingNum;
//    if (height > 800) {
//      multiplyingNum = 0.95;
//    } else if (height > 700) {
//      multiplyingNum = 1.0;
//    } else if (height > 650) {
//      multiplyingNum = 1.05;
//    } else if (height > 600) {
//      multiplyingNum = 1.25;
//    } else if (height > 500) {
//      multiplyingNum = 1.5;
//    } else {
//      multiplyingNum = 2.0;
//    }
    multiplyingNum = 0.95;
    return SafeArea(
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
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height * multiplyingNum),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    //backIcon(),
                    logo(),
                    Form(key: formKey, child: centralCon()),
                    lastText(),
                    //Container()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget logo() {
    return Row(
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        backIcon(),
//     Container(),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 3.5,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Image.asset(
                Constant.mainLogoAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          color: Colors.transparent,
          child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.transparent,
              ),
              onPressed: () {}),
        ),
//        Container(),
//        Container(), Container()
      ],
    );
  }

  TextStyle _textStyle(bool isBold, bool isBlack) {
    return TextStyle(
        color: isBlack ? Colors.black : Colors.white,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w400);
  }

  Widget centralCon() {
    return Container(
//      decoration: _boxDecoration(false),
      decoration: BoxDecoration(
          color: Color(Constant.conColor),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white)),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 10),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75,
          horizontal: MediaQuery.of(context).size.width / 30),
      child: Column(
        children: <Widget>[
          Text(
            "MEMBER",
            style: whiteBold,
            textScaleFactor: 1.55,
          ),
          reqField(0),
          reqField(1),
          reqField(2),
          signUpBtn()
        ],
      ),
    );
  }

  Widget lastText() {
    List<TextSpan> textSpans = List<TextSpan>.generate(2, (span) {
      return TextSpan();
    });
    textSpans[0] = TextSpan(
        text: "By continuing, you agree to our\n",
        style: TextStyle(color: Colors.white, fontSize: 20.0));
    textSpans[1] = TextSpan(
      text: 'Terms & Conditions',
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
    );
    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: TextAlign.center,
    );
  }

  Widget reqField(int conNum) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: controllers[conNum],
        decoration: InputDecoration(
          fillColor: Color(Constant.textFieldColor),
          filled: true,
          border: _outlineInputBorder,
          focusedErrorBorder: _outlineInputBorder,
          focusedBorder: _outlineInputBorder,
          errorBorder: _outlineInputBorder,
          enabledBorder: _outlineInputBorder,
          disabledBorder: _outlineInputBorder,
          hintText: hints[conNum],
          hintStyle: whiteNormal,
          errorStyle: whiteNormal,
          prefixIcon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
            child: Icon(
              conNum == 0
                  ? Icons.person
                  : conNum == 1 ? Icons.local_post_office : Icons.lock,
              color: Colors.black,
            ),
          ),
        ),
        style: whiteNormal,
        obscureText: conNum == 2 ? true : false,
        validator: (txt) {
          if (conNum == 0) {
            if (txt == '') {
              return 'Please enter your name';
            }
          } else if (conNum == 1) {
            if (!isEmail(txt)) {
              return 'Invalid email address';
            }
          } else if (conNum == 2) {
            if (txt.length < 6) {
              return 'Password must be of atleast 6 characters';
            }
          }
        },
      ),
    );
  }

  dealSignUP() async {
    try {
      setState(() {
        processing = true;
      });
      AuthResult authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: controllers[1].text, password: controllers[2].text);
//   await a
      await dbref
          .child(Constant.users)
          .child(authResult.user.uid)
          .set({Constant.name: controllers[0].text, Constant.isAdmin: 0});
      showSnackBar('Successfully signed up');
      setState(() {
        processing = false;
      });
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        processing = false;
      });
      if (e.toString() ==
          'PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)') {
        showSnackBar('Error: problem in network connection');
      } else if (e.toString() ==
          'PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)') {
        showSnackBar('Error: Invalid email address');
      } else if (e.toString() ==
          'PlatformException(ERROR_WEAK_PASSWORD, The given password is invalid. [ Password should be at least 6 characters ], null)') {
        showSnackBar(
            'Error: Passowrd is weak or invalid . Password should be atleast 6 characters');
      } else if (e.toString() ==
          'PlatformException(error, Given String is empty or null, null)') {
        showSnackBar('Error: Please write in all the fields');
      } else if (e.toString() ==
          'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)') {
        showSnackBar('Error: Given email is already in use');
      } else {
        showSnackBar(e.toString());
      }
    }
  }

  showSnackBar(String chithi) {
    SnackBar snackBar = SnackBar(
      content: Text(chithi),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget signUpBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75),
      child: processing != true
          ? RaisedButton(
              onPressed: () {
                if (formKey.currentState.validate()) {
                  dealSignUP();
                }
              },
              color: Color(Constant.yellowColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 12.5),
                child: Center(
                  child: Text(
                    'SIGN UP',
                    textScaleFactor: 1.5,
                    style: blackBold,
                  ),
                ),
              ),
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Signing Up  ',
                    style: whiteBold,
                    textScaleFactor: 1.5,
                  ),
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                ],
              ),
            ),
    );
  }

  Widget backIcon() {
    return Container(
//        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(Constant.feroziColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }
}
