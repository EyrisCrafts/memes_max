import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/themeMeme.dart';
import 'package:memes_max/widgets/button_choice.dart';
import 'package:provider/provider.dart';

class SheetSettings extends StatelessWidget {
  const SheetSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ThemeMeme>(
        child: Column(
          children: [
            Stack(
              children: [
                // GradientCircularProgressIndicator(
                //   gradientColors: [
                //     appColors[selectedAppColor].accent,
                //     appColors[selectedAppColor].main,
                //     appColors[selectedAppColor].selected
                //   ],
                //   radius: 40,
                //   strokeWidth: 8.0,
                //   backgroundColor: Colors.grey[350],
                //   value: learn / 100,
                // ),

                Container(
                  height: 80,
                  width: 80,
                  alignment: Alignment.center,
                  child: const Text("Learning",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    splashColor: Colors.pinkAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      // selectedAppColor = 0;
                      GetIt.I<ThemeMeme>().updateAppColor(0);
                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    splashColor: Colors.purpleAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      // selectedAppColor = 1;
                      GetIt.I<ThemeMeme>().updateAppColor(1);
                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    splashColor: Colors.amberAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      // selectedAppColor = 2;
                      GetIt.I<ThemeMeme>().updateAppColor(2);
                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    splashColor: Colors.indigoAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      // selectedAppColor = 3;
                      GetIt.I<ThemeMeme>().updateAppColor(3);
                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    splashColor: Colors.tealAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.teal,
                    ),
                    onPressed: () {
                      // selectedAppColor = 4;
                      GetIt.I<ThemeMeme>().updateAppColor(4);
                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    splashColor: Colors.redAccent,
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // selectedAppColor = 5;
                      GetIt.I<ThemeMeme>().updateAppColor(5);

                      // saveSelectedAccent(selectedAppColor);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.radio_button_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // selectedBackground = 0;
                      GetIt.I<ThemeMeme>().updateBackgroundColor(0);
                      // saveSelectedBackground(selectedBackground);
                      // setState(() {});
                      // modalSetState(() {});
                    }),
                IconButton(
                    icon: Icon(
                      Icons.radio_button_off,
                      color: backgroundColors[1].main,
                    ),
                    onPressed: () {
                      // selectedBackground = 1;
                      GetIt.I<ThemeMeme>().updateBackgroundColor(1);
                      // saveSelectedBackground(selectedBackground);
                      // modalSetState(() {});
                      // setState(() {});
                    }),
              ],
            ),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    GetIt.I<ThemeMeme>().updateDarkMode();
                    return;
                    // isDarkMode = !isDarkMode;
                    // saveDarkPreferences(isDarkMode);
                    // setState(() {});
                    // modalSetState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<ThemeMeme>(builder: (context, val, _) {
                        return Text("Dark Memes",
                            style: TextStyle(
                                color: val.selectedBackground == 1
                                    ? Colors.white
                                    : Colors.black));
                      }),
                      IconButton(
                          icon: Consumer<ThemeMeme>(builder: (context, val, _) {
                            return Icon(
                              val.isDarkMode
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: val.selectedBackground == 1
                                  ? Colors.white
                                  : Colors.black,
                            );
                          }),
                          onPressed: null),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Consumer<ThemeMeme>(builder: (context, val, _) {
                  return ChoiceButton(
                    text: "Scroll Memes",
                    width: size.width * 0.4,
                    isActive: val.isScrollableList,
                    colorMain: appColors[val.selectedAppColor].main,
                    colorAccent: appColors[val.selectedAppColor].accent,
                    onPress: () {
                      // isScrollableList = !isScrollableList;
                      GetIt.I<ThemeMeme>().updateIsScrollableList(true);
                      // saveScrollablePreferences(isScrollableList);
                      // setState(() {});
                      // modalSetState(() {});
                    },
                  );
                }),
                Consumer<ThemeMeme>(builder: (context, val, _) {
                  return ChoiceButton(
                    text: "Swipe Memes",
                    width: size.width * 0.4,
                    isActive: !val.isScrollableList,
                    colorMain: appColors[val.selectedAppColor].main,
                    colorAccent: appColors[val.selectedAppColor].accent,
                    onPress: () {
                      // isScrollableList = !isScrollableList;
                      GetIt.I<ThemeMeme>().updateIsScrollableList(false);
                      // saveScrollablePreferences(isScrollableList);
                      // setState(() {});
                      // modalSetState(() {});
                    },
                  );
                }),
              ],
            ),
            Consumer<ThemeMeme>(builder: (context, val, _) {
              return ChoiceButton(
                text: "I have crappy Internet",
                width: size.width * 0.8,
                isActive: val.hasCrappyInternet,
                colorMain: appColors[val.selectedAppColor].main,
                colorAccent: appColors[val.selectedAppColor].accent,
                onPress: () {
                  GetIt.I<ThemeMeme>().updateCrappyInternet();
                  // hasCrappyInternet = !hasCrappyInternet;
                  // saveInternetPreferences(hasCrappyInternet);
                  // setState(() {});
                  // modalSetState(() {});
                },
              );
            }),
          ],
        ),
        builder: (context, val, child) {
          return Container(
              decoration: BoxDecoration(
                  color: backgroundColors[val.selectedBackground]
                      .main
                      .withAlpha(245),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              height: 370,
              child: child);
        });
  }
}
