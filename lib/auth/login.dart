import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:guessthosebars/admin_side/admin_side.dart';
import 'package:guessthosebars/auth/sign_up.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/res/static_info.dart';
import 'package:guessthosebars/splash/splash_screen.dart';
import 'package:guessthosebars/user_side/select_mode.dart';
import 'package:string_validator/string_validator.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextStyle normalTextStyle;
  TextStyle boldTextStyle;
  TextStyle italicTextStyle =
      TextStyle(color: Colors.white, fontStyle: FontStyle.italic);
  TextStyle blackBoldTextStyle;
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.transparent));
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
          2, (generator) => TextEditingController());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  BoxDecoration whiteBorderBox;
  BoxDecoration yellowBox;
  TextStyle italianTextStyle =
      TextStyle(color: Colors.white, fontStyle: FontStyle.italic);
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  String _message = 'Log in/out by pressing the buttons below.';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    normalTextStyle = _style(false, false);
    boldTextStyle = _style(true, false);
    blackBoldTextStyle = _style(true, true);
    whiteBorderBox = _boxDecoration(false);
    yellowBox = _boxDecoration(true);
  }

  bool forgotPasswordTapped = false;
  bool processing;
  bool pleaseWait = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
//    print('multiplyingNum: ${multiplyingNum}');
    multiplyingNum = 0.95;
//    multiplyingNum = 1.0;//multiplyingNum - 0.5;
//    multiplyingNum = multiplyingNum - 0.5;
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
                    forgotPasswordTapped == true ? backIcon() : Container(),
                    logo(),
                    Form(key: formKey, child: centralCon()),
                    lastCon()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _style(bool isBold, bool isBlack) {
    return TextStyle(
        color: isBlack == true ? Colors.black : Colors.white,
        fontWeight: isBold == true ? FontWeight.w700 : FontWeight.w400);
  }

  Widget logo() {
    return Container(
      height: MediaQuery.of(context).size.height / 3.5,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Image.asset(
          Constant.mainLogoAsset,
          fit: BoxFit.cover,
        ),
      ),
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
          focusedErrorBorder: outlineInputBorder,
          border: outlineInputBorder,
          disabledBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          errorBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          errorStyle: normalTextStyle,
          prefixIcon: Container(
            margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: Icon(
              conNum == 0 ? Icons.local_post_office : Icons.lock,
              color: Colors.black,
            ),
          ),
          hintText: conNum == 0 ? 'email' : 'password',
          hintStyle: normalTextStyle,
        ),
        obscureText: conNum == 0 ? false : true,
        style: normalTextStyle,
        validator: (txt) {
          if (conNum == 0) {
            if (!isEmail(controllers[0].text)) {
              return 'Invalid email address';
            }
          } else if (conNum == 1) {
            if (controllers[0].text.length < 6) {
              return 'Password must be of atleast 6 characters';
            }
          }
        },
      ),
    );
  }

  Widget centralCon() {
    return Container(
      decoration: whiteBorderBox,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 10),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 75.0,
          horizontal: MediaQuery.of(context).size.width / 30),
      child: Column(
        children: <Widget>[
          Text(
            forgotPasswordTapped != true ? 'MEMBER' : 'RESET PASSWORD',
            style: boldTextStyle,
            textScaleFactor: 1.5,
          ),
          reqField(0),
          forgotPasswordTapped != true ? reqField(1) : Container(),
          forgotPasswordTapped != true
              ? forgotPass()
              : Container(
                  height: MediaQuery.of(context).size.height / 75,
                ),
          loginBtn(),
          forgotPasswordTapped != true
              ? GestureDetector(
                  onTap: () {
                    dealFbLogin();
                  },
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, child: fbLogin()),
                )
              : Container()
        ],
      ),
    );
  }

  Widget forgotPass() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100, horizontal: 5.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            forgotPasswordTapped = !forgotPasswordTapped;
            setState(() {});
          },
          child: Text(
            'forgot password?',
            style: italianTextStyle,
            textScaleFactor: 1.25,
          ),
        ),
      ),
    );
  }

  Widget loginBtn() {
    return processing != true
        ? RaisedButton(
            onPressed: () {
              if (formKey.currentState.validate()) {
                forgotPasswordTapped != true
                    ? dealLogin()
                    : dealResetPassword();
              }
            },
            color: Color(Constant.yellowColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Center(
                child: Text(
                  forgotPasswordTapped != true ? "LOGIN" : "SEND",
                  style: blackBoldTextStyle,
                  textScaleFactor: 1.5,
                ),
              ),
            ),
          )
        : Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Signing In   ',
                  style: boldTextStyle,
                  textScaleFactor: 1.5,
                ),
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              ],
            ),
          );
  }

  BoxDecoration _boxDecoration(bool isYellow) {
    return BoxDecoration(
        color: Color(
          isYellow == true ? Constant.yellowColor : Constant.conColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: isYellow == true ? Colors.transparent : Colors.white));
  }

  dealFbLogin() async {
    FacebookLogin facebookSignIn = new FacebookLogin();

    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    String token = '';
    http.Response graphResponse;
    Map<String, dynamic> profile;
    FacebookAccessToken accessToken;
    if (result != null) {
//      final token = await result.accessToken?.token;

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          setState(() {
            pleaseWait = true;
          });
          accessToken = await result.accessToken;
//          token = await result.accessToken.token;
          token = accessToken.token;
          graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
          profile = json.decode(graphResponse.body);
          showAlertDialog(true);
          print('''
         ++++++PROFILE: ${profile}

         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');

          if (profile['email'] != null) {
            await fbauth(profile['email'], profile[Constant.name]);
          } else {
            await fbauth('${profile["id"]}@gmail.com', profile[Constant.name]);
          }
          setState(() {
            pleaseWait = false;
          });
          break;
        case FacebookLoginStatus.cancelledByUser:
//          _showMessage('----Login cancelled by the user.');
          break;
        case FacebookLoginStatus.error:
//          _showMessage('--- Something went wrong with the login process.\n'
//              'Here\'s the error Facebook gave us: ${result.errorMessage}');
          break;
      }
    }
    /* 
  {
   "name": "Iiro Krankka",
   "first_name": "Iiro",
   "last_name": "Krankka",
   "email": "iiro.krankka\u0040gmail.com",
   "id": "<user id here>"
} */
  }

  fbauth(String email, String userName) async {
    try {
      AuthResult authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email, password: '${email}012345');
      await dbref
          .child(Constant.users)
          .child(authResult.user.uid)
          .set({Constant.name: userName, Constant.isAdmin: 0});
      await loginNum2(email, userName);
    } catch (e) {
//      print('fbauthError: ${e.toString()}');
      if (e.toString() ==
          'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)') {
//        print('yes modafucka');
        loginNum2(email, userName);
      } else {
        Navigator.pop(context);
        showSnackBar("Error login with Facebook");
      }
    }
  }

  loginNum2(String email, String userName) async {
    AuthResult authResult1 = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: '${email}012345');
    StaticInfo.currentUser = authResult1.user;
    StaticInfo.userName = userName;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => SelectCategory()),
        (predicate) => false);
  }

  showAlertDialog(bool isGoodNews) {
    CupertinoAlertDialog cupertinoAlertDialog = CupertinoAlertDialog(
      content: isGoodNews
          ? Center(
              child: Row(
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 25,
                  ),
                  Text(
                    "Logging in",
                    style: textStyle,
                    textScaleFactor: 1.75,
                  ),
                ],
              ),
            )
          : Container(),
    );

    showDialog(
        context: context,
        builder: (ctx) {
          return cupertinoAlertDialog;
        });
  }

  Widget fbLogin() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'LOGIN WITH FACEBOOK ',
            textScaleFactor: 1.25,
            style: boldTextStyle,
          ),
          CircleAvatar(
            backgroundColor: Color(Constant.blueColor),
            child: Text(
              'f',
              textScaleFactor: 2.0,
              style: boldTextStyle,
            ),
          )
        ],
      ),
    );
  }

  dealLogin() async {
    try {
      int isAdmin;

      setState(() {
        processing = true;
      });
      AuthResult authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: controllers[0].text, password: controllers[1].text);
      StaticInfo.currentUser = authResult.user;
      await dbref
          .child(Constant.users)
          .child(authResult.user.uid)
//          .child(Constant.isAdmin)
          .once()
          .then((dataSnapshot) {
        isAdmin = dataSnapshot.value[Constant.isAdmin];
        StaticInfo.userName = dataSnapshot.value[Constant.name];
      });

      setState(() {
        processing = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (ctx) => isAdmin == 1 ? AdminSide() : SelectCategory()),
          (predicate) => false);
    } catch (e) {
      setState(() {
        processing = false;
      });
      if (e.toString() ==
          'PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)') {
        showSnackBar('Error: User not found');
      } else if (e.toString() ==
          'PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)') {
        showSnackBar('Error: Wrong password');
      } else if (e.toString() ==
          'PlatformException(error, Given String is empty or null, null)') {
        showSnackBar('Error: Given fields are empty ');
      } else if (e.toString() ==
          'PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)') {
        showSnackBar(
            'Error: Inavild email. The email addrees is badly formated');
      } else if (e.toString() ==
          'PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)') {
        showSnackBar('Error: Problem in network connection');
      } else {
        showSnackBar(e.toString());
      }
    }
  }

  showSnackBar(String chithi) {
    SnackBar snackBar = SnackBar(content: Text(chithi));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  dealResetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: controllers[0].text);
      showSnackBar("Email succesfully sent");
      await Future.delayed(Duration(milliseconds: 2500));
      setState(() {
        forgotPasswordTapped = !forgotPasswordTapped;
      });
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  Widget lastCon() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 10),
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => SignUp()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: whiteBorderBox,
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          child: Center(child: richText()),
        ),
      ),
    );
  }

  Widget richText() {
    List<TextSpan> textSpans = List<TextSpan>.generate(2, (span) {
      return TextSpan();
    });
    textSpans[0] = TextSpan(
        text: "Not a member? Create account ",
        style: TextStyle(color: Colors.white, fontSize: 20.0));
    textSpans[1] = TextSpan(
      text: 'here',
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
    );
    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: TextAlign.center,
    );
  }

  Widget backIcon() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
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
              forgotPasswordTapped = !forgotPasswordTapped;
              setState(() {});
            }),
      ),
    );
  }
}
