import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/sheets/widgets/button_choice.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SheetSettings extends StatelessWidget {
  const SheetSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ThemeMeme>(
        child: Column(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Consumer<ThemeMeme>(builder: (context, theme, _) {
                return SleekCircularSlider(
                  innerWidget: (a) => const SizedBox(),
                  appearance: CircularSliderAppearance(
                      customColors:
                          CustomSliderColors(trackColor: Colors.transparent, progressBarColor: Colors.transparent, dotColor: Colors.transparent, trackColors: appColors.map((e) => e.main).toList()),
                      customWidths: CustomSliderWidths(progressBarWidth: 10)),
                  min: 0,
                  max: 100,
                  initialValue: theme.learn.toDouble(),
                );
              }),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  appColors.length,
                  (index) => IconButton(
                      splashColor: appColors[index].accent,
                      icon: Icon(
                        Icons.circle,
                        color: appColors[index].main,
                      ),
                      onPressed: () {
                        GetIt.I<ThemeMeme>().updateAppColor(index);
                      }),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.radio_button_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      GetIt.I<ThemeMeme>().updateBackgroundColor(0);
                    }),
                IconButton(
                    icon: Icon(
                      Icons.radio_button_off,
                      color: backgroundColors[1].main,
                    ),
                    onPressed: () {
                      GetIt.I<ThemeMeme>().updateBackgroundColor(1);
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
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<ThemeMeme>(builder: (context, val, _) {
                        return Text("Dark Memes", style: TextStyle(color: val.selectedBackground == 1 ? Colors.white : Colors.black));
                      }),
                      IconButton(
                          icon: Consumer<ThemeMeme>(builder: (context, val, _) {
                            return Icon(
                              val.isDarkMode ? Icons.check_box : Icons.check_box_outline_blank,
                              color: val.selectedBackground == 1 ? Colors.white : Colors.black,
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
                      GetIt.I<ThemeMeme>().updateIsScrollableList(true);
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
                      GetIt.I<ThemeMeme>().updateIsScrollableList(false);
                    },
                  );
                }),
              ],
            ),
            // Consumer<ThemeMeme>(builder: (context, val, _) {
            //   return ChoiceButton(
            //     text: "I have crappy Internet",
            //     width: size.width * 0.8,
            //     isActive: val.hasCrappyInternet,
            //     colorMain: appColors[val.selectedAppColor].main,
            //     colorAccent: appColors[val.selectedAppColor].accent,
            //     onPress: () {
            //       GetIt.I<ThemeMeme>().updateCrappyInternet();
            //     },
            //   );
            // }),
          ],
        ),
        builder: (context, val, child) {
          return Container(
              decoration: BoxDecoration(
                  color: backgroundColors[val.selectedBackground].main.withAlpha(245), borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              height: 370,
              child: child);
        });
  }
}
