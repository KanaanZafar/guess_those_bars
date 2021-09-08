import 'package:flutter/material.dart';
import 'package:guessthosebars/res/constants.dart';
import 'package:guessthosebars/user_side/show_categories.dart';

class SelectCategory extends StatefulWidget {
  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  List<String> modes = ['SINGLE PLAYER', '1 VS 1', 'TEAM VS TEAM'];

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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(
                  Constant.mainLogoAsset,
                  height: 250.0,
                  width: 250.0,
                  fit: BoxFit.cover,
                ),
                modesCol()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget modesCol() {
    List<Widget> tmp = List<Widget>();
    for (int i = 0; i < modes.length; i++) {
      tmp.add(modeWidget(i));
    }
    return Column(children: tmp);
  }

  Widget modeWidget(int modeNum) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (ctx) => ShowCategories(modeNum)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 100),
        decoration: BoxDecoration(
            border: Border.all(
                color: Color(Constant.stylishBorderColor), width: 1.75),
            borderRadius: BorderRadius.circular(25.0),
            color: Color(Constant.conColor)),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 75),
        child: Center(
          child: Text(
            modes[modeNum],
            textScaleFactor: 1.5,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
/* GridView.builder(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 15,
                  horizontal: MediaQuery.of(context).size.width / 30),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: MediaQuery.of(context).size.height / 40,
                crossAxisSpacing: MediaQuery.of(context).size.height / 40,
              ),
              itemBuilder: (BuildContext context, int index) {
                return catWidget(index);
              },
              itemCount: Constant.categoriesList.length,
            ), */

/*
   */
