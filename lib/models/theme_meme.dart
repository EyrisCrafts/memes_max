import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memes_max/toasts/toast_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeMeme extends ChangeNotifier {
  int learn = 0;
  int selectedAppColor = 0;
  int selectedBackground = 0;
  bool hasCrappyInternet = false;
  bool isScrollableList = true;
  bool isDarkMode = true;

  late FToast fToast;

  void showToast(IconData iconData, String message) {
    fToast.showToast(
        child: ToastCustom(iconData: iconData, message: message),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2));
  }

  void setupFToast(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
  }

  void updateLearning() {
    learn++;
    notifyListeners();
    saveToPrefs();
  }

  Future<void> loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    learn = prefs.getInt('learn') ?? 0;
    selectedAppColor = prefs.getInt('accent') ?? 0;
    selectedBackground = prefs.getInt('background') ?? 1;
    hasCrappyInternet = prefs.getBool('internet') ?? false;
    isScrollableList = prefs.getBool('scrollable') ?? true;
    isDarkMode = prefs.getBool('darkmode') ?? true;
  }

  void saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('learn', learn);
    prefs.setInt('accent', selectedAppColor);
    prefs.setInt('background', selectedBackground);
    prefs.setBool('internet', hasCrappyInternet);
    prefs.setBool('scrollable', isScrollableList);
    prefs.setBool('darkmode', isDarkMode);
  }

  void updateDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
    saveToPrefs();
  }

  void updateCrappyInternet() {
    hasCrappyInternet = !hasCrappyInternet;
    notifyListeners();
    saveToPrefs();
  }

  void updateIsScrollableList(bool isScrollable) {
    isScrollableList = isScrollable;
    notifyListeners();
    saveToPrefs();
  }

  void updateBackgroundColor(int color) {
    selectedBackground = color;
    notifyListeners();
    saveToPrefs();
  }

  void updateAppColor(int color) {
    selectedAppColor = color;
    notifyListeners();
    saveToPrefs();
  }
}
