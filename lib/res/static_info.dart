import 'package:firebase_auth/firebase_auth.dart';
import 'package:guessthosebars/models/question.dart';

class StaticInfo {
  static FirebaseUser currentUser;
  static String userName = '';

  static List<List<Question>> listOfLists =
      List<List<Question>>.generate(10, (generator) => List<Question>());
}
