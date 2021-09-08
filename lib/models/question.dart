import 'package:guessthosebars/res/constants.dart';

class Question {
  int queId;
  String queStatement;
  String optA;
  String optB;
  String optC;
  String optD;
  int category;

//  String isPremium;
  String correctAnswer;
  String whatAnswered;

  Question(
      {this.queId,
      this.queStatement,
      this.optA,
      this.optB,
      this.optC,
      this.optD,
      this.category,
//      this.isPremium,
      this.correctAnswer,
      this.whatAnswered});

  Question.fromMap(Map<dynamic, dynamic> map) {
    this.queId = map[Constant.queId];
    this.queStatement = map[Constant.queStatement];
    this.optA = map[Constant.optA];
    this.optB = map[Constant.optB];
    this.optC = map[Constant.optC];
    this.optD = map[Constant.optD];
    this.category = map[Constant.category];
//    this.isPremium = map[Constant.isPremium];
    this.correctAnswer = map[Constant.correctAnswer];
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.queId: this.queId,
      Constant.queStatement: this.queStatement,
      Constant.optA: this.optA,
      Constant.optB: this.optB,
      Constant.optC: this.optC,
      Constant.optD: this.optD,
      Constant.category: this.category,
//      Constant.isPremium: this.isPremium,
      Constant.correctAnswer: this.correctAnswer,
      Constant.whatAnswered: this.whatAnswered
    };
  }

  @override
  String toString() {
    return 'Question{queId: $queId, queStatement: $queStatement, optA: $optA, optB: $optB, optC: $optC, optD: $optD, category: $category, correctAnswer: $correctAnswer, whatAnswered: $whatAnswered}';
  }
}
