import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/splash/splash_screen.dart';

void main() async {
//  runApp(app)
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess Those Bars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: Constant.nunitoFont),
      home: SplashScreen(),
    );
  }
}
