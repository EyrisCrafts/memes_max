import 'package:flutter/material.dart';

class AppColor {
  Color main;
  Color accent;
  Color selected;

  AppColor(
    this.main,
    this.accent,
    this.selected,
  );
}

class BackgroundColor {
  Color main;
  Color shade;
  BackgroundColor(this.main, this.shade);
}

List<String> memeCategories = const [
  "memes",
  "dankmemes",
  "AdviceAnimals",
  "ComedyCemetery",
  "terriblefacebookmemes",
  "animememes"
];

List<BackgroundColor> backgroundColors = [
  BackgroundColor(const Color(0xfff0f0f0), Colors.white),
  BackgroundColor(const Color(0xff1B2836), const Color(0xff0b1117)),
];

final List<AppColor> appColors = [
  AppColor(Colors.pink, Colors.pinkAccent, Colors.pink.shade800),
  AppColor(Colors.purple, Colors.purpleAccent, Colors.purple.shade800),
  AppColor(Colors.amber, Colors.amberAccent, Colors.amber.shade800),
  AppColor(Colors.indigo, Colors.indigoAccent, Colors.indigo.shade800),
  AppColor(Colors.teal, Colors.tealAccent, Colors.teal.shade800),
  AppColor(Colors.red, Colors.redAccent, Colors.red.shade800),
];
