import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/favorites.dart';
import 'package:memes_max/memes.dart';
import 'package:memes_max/models/themeMeme.dart';
import 'package:memes_max/sheets/sheet_settings.dart';
import 'package:memes_max/submission.dart';
import 'package:memes_max/widgets/button_choice.dart';
import 'package:memes_max/widgets/memes_pages.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/last_meme.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({Key? key}) : super(key: key);

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  String memesType = "memes";

  late Reddit reddit;

  Future<Reddit> futureReddit = Reddit.createReadOnlyInstance(
      clientId: "Y82I2nvR-d4CNg",
      clientSecret: "mTPPwrOque6TX2WuEAqiMp1b6SU",
      userAgent: "whatever");

  GlobalKey<MemeListState> memeListKey = GlobalKey<MemeListState>();
  GlobalKey<MemePagesState> memePageKey = GlobalKey<MemePagesState>();

  @override
  void initState() {
    super.initState();
    GetIt.I<ThemeMeme>().setupFToast(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ThemeMeme>(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  elevation: 0,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  title: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Consumer<ThemeMeme>(builder: (context, val, _) {
                          return Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: appColors[val.selectedAppColor].main,
                                  borderRadius: BorderRadius.circular(20)),
                              child: IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.settings,
                                    color: Colors.white),
                                onPressed: openSettings,
                              ));
                        }),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Consumer<ThemeMeme>(builder: (context, val, _) {
                          return MaterialButton(
                            color: appColors[val.selectedAppColor].main,
                            height: 40,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            onPressed: () {
                              onTapBottomSheet(size);
                            },
                            child: const Text(
                              "Category",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                      ),
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<ThemeMeme>(builder: (context, val, _) {
                              return Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: appColors[val.selectedAppColor].main,
                                    borderRadius: BorderRadius.circular(20)),
                                child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.share,
                                        color: Colors.white),
                                    onPressed: () {
                                      Share.share(
                                          "https://play.google.com/store/apps/details?id=com.eyriscrafts.memesmax");
                                    }),
                              );
                            }),
                            const SizedBox(
                              width: 10,
                            ),
                            Consumer<ThemeMeme>(builder: (context, val, _) {
                              return Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: appColors[val.selectedAppColor].main,
                                    borderRadius: BorderRadius.circular(20)),
                                child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.white),
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FavoritesScreen()))),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: FutureBuilder<Reddit>(
              future: futureReddit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  reddit = snapshot.data!;
                  return Consumer<ThemeMeme>(builder: (context, val, _) {
                    return Container(
                      child: val.isScrollableList
                          ? MemeList(
                              key: memeListKey,
                              reddit: reddit,
                              currentSub: memesType,
                            )
                          : MemePages(
                              key: memePageKey,
                              reddit: reddit,
                              currentSub: memesType,
                            ),
                    );
                  });
                }
                return Container(
                  height: 4,
                  alignment: Alignment.topCenter,
                  child: Consumer<ThemeMeme>(builder: (context, val, _) {
                    return LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          appColors[val.selectedAppColor].main),
                      backgroundColor: Colors.transparent,
                    );
                  }),
                );
              },
            ),
          ),
        ),
        builder: (context, val, child) {
          return Scaffold(
              backgroundColor: backgroundColors[val.selectedBackground].main,
              body: child);
        });
  }

  openSettings() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return const SheetSettings();
        });
  }

  onTapBottomSheet(Size size) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            width: size.width,
            height: 400,
            child: Consumer<ThemeMeme>(builder: (context, val, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 13, top: 5, bottom: 10),
                        child: Text("Categories:",
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      )
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "memes"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        setState(() {
                          subred = "memes";
                          memes.clear();
                          memesQueue.clear();
                        });
                        if (GetIt.I<ThemeMeme>().isScrollableList) {
                          memeListKey.currentState?.requestNextPage();
                        } else {
                          memePageKey.currentState?.requestNextPage();
                        }
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Memes", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "dankmemes"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        SharedPreferences.getInstance().then((prefs) {
                          subred = "dankmemes";
                          memes.clear();
                          memesQueue.clear();
                          if (GetIt.I<ThemeMeme>().isScrollableList) {
                            memeListKey.currentState?.requestNextPage();
                          } else {
                            memePageKey.currentState?.requestNextPage();
                          }
                          loadLastMeme(subred, prefs);
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("dankmemes",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "AdviceAnimals"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        SharedPreferences.getInstance().then((prefs) {
                          subred = "AdviceAnimals";
                          memes.clear();
                          memesQueue.clear();
                          if (GetIt.I<ThemeMeme>().isScrollableList) {
                            memeListKey.currentState?.requestNextPage();
                          } else {
                            memePageKey.currentState?.requestNextPage();
                          }
                          loadLastMeme(subred, prefs);
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("AdviceAnimals",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "ComedyCemetery"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        SharedPreferences.getInstance().then((prefs) {
                          subred = "ComedyCemetery";
                          memes.clear();
                          memesQueue.clear();
                          if (GetIt.I<ThemeMeme>().isScrollableList) {
                            memeListKey.currentState?.requestNextPage();
                          } else {
                            memePageKey.currentState?.requestNextPage();
                          }
                          loadLastMeme(subred, prefs);
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("ComedyCemetery",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "terriblefacebookmemes"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        SharedPreferences.getInstance().then((prefs) {
                          subred = "terriblefacebookmemes";
                          memes.clear();
                          memesQueue.clear();
                          if (GetIt.I<ThemeMeme>().isScrollableList) {
                            memeListKey.currentState?.requestNextPage();
                          } else {
                            memePageKey.currentState?.requestNextPage();
                          }
                          loadLastMeme(subred, prefs);
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("terriblefacebookmemes",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MaterialButton(
                      color: subred == "animememes"
                          ? appColors[val.selectedAppColor].selected
                          : appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        SharedPreferences.getInstance().then((prefs) {
                          subred = "animememes";
                          memes.clear();
                          memesQueue.clear();
                          if (GetIt.I<ThemeMeme>().isScrollableList) {
                            memeListKey.currentState?.requestNextPage();
                          } else {
                            memePageKey.currentState?.requestNextPage();
                          }
                          loadLastMeme(subred, prefs);
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Anime Memes",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          );
        });
  }

  loadLastMeme(String subred, SharedPreferences prefs) {
    String lstMemeJSon = prefs.getString(subred) ?? '';
    LastMeme lastMeme = LastMeme.fromJson(lstMemeJSon);
    if (lastMeme != null) {
      if (DateTime.now().difference(lastMeme.lastAccessed).inHours > 6) {
        prefs.setString(subred, "");
      } else {
        memes.add(Meme(id: lastMeme.lastID, url: ''));
      }
    }
  }
}
