import 'dart:developer';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/models/provider_game.dart';
import 'package:memes_max/screens/screen_favorite/screen_favorites.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/screens/screen_main/screen_main.dart';
import 'package:memes_max/service_locator.dart';
import 'package:memes_max/submission.dart';
import 'package:memes_max/sheets/widgets/button_choice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models/last_meme.dart';
import 'screens/screen_main/widgets/memes_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await GetIt.I<ThemeMeme>().loadFromPrefs();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    loadingPreferences = loadPreferences();
  }

  List stuff = [];
  late Future loadingPreferences;

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String lstMemeJSon = prefs.getString(subred) ?? '';
    if (lstMemeJSon.isEmpty) return;
    LastMeme lastMeme = LastMeme.fromJson(lstMemeJSon);
    if (lastMeme != null) {
      if (DateTime.now().difference(lastMeme.lastAccessed).inHours > 6) {
        prefs.setString(subred, "");
      } else {
        memes.add(Meme(id: lastMeme.lastID, url: ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar color
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GetIt.I<ThemeMeme>()),
        ChangeNotifierProvider(create: (context) => GetIt.I<ProviderGame>())
      ],
      child: MaterialApp(
          title: "Memax",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: FutureBuilder(
            future: loadingPreferences,
            builder: (context, snapshot) {
              return const ScreenMain();
            },
          )),
    );
  }
}
