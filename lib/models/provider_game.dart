import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class ProviderGame extends ChangeNotifier {
  late Reddit reddit;
  bool isLoading = true;

  void setupReddit() async {
    isLoading = true;
    reddit = await Reddit.createReadOnlyInstance(
        clientId: "Y82I2nvR-d4CNg",
        clientSecret: "mTPPwrOque6TX2WuEAqiMp1b6SU",
        userAgent: "whatever");
    notifyListeners();
  }
}
