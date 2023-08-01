import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/screens/screen_main/screen_main.dart';
import 'package:memes_max/service_locator.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar color
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GetIt.I<ThemeMeme>()), ChangeNotifierProvider(create: (context) => GetIt.I<ProviderMemes>())],
      child: MaterialApp(
        title: "Memax",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: const ScreenMain(),
      ),
    );
  }
}
