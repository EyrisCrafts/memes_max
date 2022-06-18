import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/themeMeme.dart';
import 'package:memes_max/screens/widgets/sheet_settings.dart';
import 'package:memes_max/sheets/sheets_meme_options.dart';
import 'package:memes_max/submission.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/last_meme.dart';

class MemeList extends StatefulWidget {
  final String currentSub;
  final Reddit reddit;
  const MemeList({
    required this.reddit,
    Key? key,
    required this.currentSub,
  }) : super(key: key);

  @override
  MemeListState createState() => MemeListState();
}

String subred = "memes";
List<Meme> memes = [];
Queue memesQueue = Queue();
GlobalKey myKey = GlobalKey();

class MemeListState extends State<MemeList> {
  final StreamController<List<Meme>> _streamController = StreamController();
  late Future<dynamic> firstReq;
  bool _isRequesting = false;

  late bool _isLoading;
  late ScrollController scrollController;

  // late FToast fToast;
  @override
  void initState() {
    log("initstate");
    _isLoading = true;
    // fToast = FToast();
    // fToast.init(context);

    firstReq = requestNextPage();
    super.initState();
  }

  _showToast(Size size, String message, IconData iconData) {
    GetIt.I<ThemeMeme>().showToast(iconData, message);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrollController =
        PrimaryScrollController.of(context) ?? ScrollController();
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: firstReq,
      builder: (context, snapshot) => Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.extentAfter < 1000) {
                requestNextPage();
              }
              return true;
            },
            child: StreamBuilder<List<Meme>>(
              stream: _streamController.stream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Meme>> snapshot) {
                if (snapshot.hasError)
                  // ignore:
                  return const Center(
                    child: Text("Error Ocurred"),
                  );
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                return ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      if (memes.first != null &&
                          (memes.first.getHeight == null ||
                              memes.first.getHeight == "")) {
                        log("Loading empty box");
                        memes.removeAt(0);
                        return const SizedBox(
                          height: 5,
                        );
                      }
                      double imageAspect = double.parse(memes[index].width) /
                          double.parse(memes[index].height);

                      double screenWidth = size.width - 20;
                      double widgetHeight = screenWidth / imageAspect;

                      return index == memes.length - 1
                          ? SizedBox(
                              height: 100,
                              child: Center(child: Consumer<ThemeMeme>(
                                  builder: (context, val, _) {
                                return CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      appColors[val.selectedAppColor].main),
                                );
                              })),
                            )
                          : Consumer<ThemeMeme>(builder: (context, val, _) {
                              return Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                width: size.width - 20,
                                height: widgetHeight,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.6),
                                          offset: const Offset(2, 2),
                                          spreadRadius: 3,
                                          blurRadius: 5),
                                      BoxShadow(
                                          color: backgroundColors[
                                                  val.selectedBackground]
                                              .main,
                                          offset: const Offset(-2, -2),
                                          spreadRadius: 2,
                                          blurRadius: 4)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: RepaintBoundary(
                                          key: memes[index].imageGlobal,
                                          child: CachedNetworkImage(
                                            imageUrl: memes[index].getUrl,
                                            progressIndicatorBuilder:
                                                (context, url, progress) =>
                                                    Center(
                                              child: Consumer<ThemeMeme>(
                                                  builder: (context, val, _) {
                                                return CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(appColors[val
                                                                .selectedAppColor]
                                                            .main),
                                                    value: progress.progress);
                                              }),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Consumer<ThemeMeme>(
                                        builder: (context, value, child) =>
                                            value.isDarkMode
                                                ? Positioned.fill(
                                                    child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.5)),
                                                  ))
                                                : Container(),
                                      ),
                                      // isDarkMode
                                      //     ? Positioned.fill(
                                      //         child: Container(
                                      //         decoration: BoxDecoration(
                                      //             color: Colors.black
                                      //                 .withOpacity(0.5)),
                                      //       ))
                                      //     : Container(),
                                      Positioned.fill(
                                          child: Material(
                                        color: Colors.transparent,
                                        child: Consumer<ThemeMeme>(
                                            builder: (context, val, _) {
                                          return InkWell(
                                            onTap: () =>
                                                _animateToIndex(index, size),
                                            onLongPress: () =>
                                                onTapBottomSheet(index, size),
                                            highlightColor: Colors.transparent,
                                            splashColor:
                                                appColors[val.selectedAppColor]
                                                    .main
                                                    .withOpacity(0.3),
                                          );
                                        }),
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            });
                    },
                    itemCount: snapshot.data?.length ?? 0);
              },
            ),
          ),
          Positioned(
              child: _isLoading
                  ? Consumer<ThemeMeme>(builder: (context, val, _) {
                      return LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            appColors[val.selectedAppColor].main),
                        backgroundColor: Colors.transparent,
                      );
                    })
                  : SizedBox()),
          Positioned(
              child: _isLoading && memes.length == 0
                  ? Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: Consumer<ThemeMeme>(builder: (context, val, _) {
                        return Text("Your Daily dose of Relaxation\n\n:)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: appColors[val.selectedAppColor].main));
                      }),
                    )
                  : SizedBox())
        ],
      ),
    );
  }

  onTapBottomSheet(int index, Size size) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          // return const SheetSettings();
          return const SheetsMemeOptions();
        });
  }

  void addScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int learnScore = prefs.getInt('learn') ?? 0;
    prefs.setInt('learn', learnScore + 1);
  }

  void saveImage(Size size, int index) async {
    if (await Permission.storage.isDenied) {
      PermissionStatus status = await Permission.storage.request();
      if (status.isDenied) return;
    }
    RenderRepaintBoundary? boundary = memes[index]
        .imageGlobal
        ?.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // String bs64 = base64Encode(pngBytes);

    getExternalStorageDirectory().then((directory) {
      File imageFile = File("${directory!.path}/${memes[index].getId}.png");
      imageFile.writeAsBytesSync(pngBytes);
      _showToast(
        size,
        "Saved Image",
        Icons.thumb_up,
      );
    });
  }

  void shareImage(int index) async {
    if (await Permission.storage.isDenied) {
      PermissionStatus status = await Permission.storage.request();
      if (status.isDenied) return;
    }
    RenderRepaintBoundary? boundary = memes[index]
        .imageGlobal
        ?.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // String bs64 = base64Encode(pngBytes);

    getApplicationDocumentsDirectory().then((directory) {
      log("Location is: ${directory.path}/temp");
      File imageFile = File("${directory.path}/temp.png");
      imageFile.writeAsBytesSync(pngBytes);
      Share.shareFiles(
        ['${directory.path}/temp.png'],
        text: 'Checkout this meme',
      );
    });
  }

  double calcWidgetHeight(Meme meme, totalSize) {
    double imageAspect = double.parse(meme.width) / double.parse(meme.height);
    double screenWidth = totalSize.width - 20;
    double widgetHeight = screenWidth / imageAspect;
    return widgetHeight;
  }

  _animateToIndex(i, size) {
    //Sum all the heights
    double totalHeight = 8 +
        memes
            .sublist(0, i + 1)
            .map((e) => calcWidgetHeight(e, size) + 20)
            .reduce((value, element) => value + element);

    scrollController.animateTo(totalHeight,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  saveLastID() {
    log("Checking to SaveLast ID");
    SharedPreferences.getInstance().then((prefs) {
      String lstMemeJSon = prefs.getString(subred) ?? '';
      if (lstMemeJSon.isEmpty) return;
      LastMeme lastMeme = LastMeme.fromJson(lstMemeJSon);

      if (lstMemeJSon == null || lstMemeJSon == "") {
        log("Saving first time, Last ID");
        prefs.setString(
            subred,
            LastMeme(lastID: memes.last.getId, lastAccessed: DateTime.now())
                .toJson());
      } else {
        log("Saving Last ID");
        lastMeme.lastID = memes.last.getId;
        prefs.setString(subred, lastMeme.toJson());
      }
    });
  }

  requestNextPage() async {
    if (!_isRequesting) {
      _isRequesting = true;

      if (memesQueue.length != 0) {
        int i = 0;

        while (memesQueue.length != 0) {
          if (i == 5) break;
          memes.add(memesQueue.removeFirst());
          i++;
        }
        saveLastID();

        log("Taking from Queue, length: ${memesQueue.length}. Added $i");

        _streamController.add(memes);
        _isRequesting = false;

        if (_isLoading || _isLoading == null) {
          setState(() {
            _isLoading = false;
          });
        }

        return;
      }

      setState(() {
        _isLoading = true;
      });

      log("Requesting next page");
      if (memes.isEmpty) {
        widget.reddit.subreddit(subred).hot(limit: 30).toList().then((value) {
          // reddit.subreddit('memes').hot(limit: 10).toList().then((value) {
          // log(value[2].toString());

          List<Meme> newList = value
              .map((e) => json.decode(e.toString()))
              .toList()
              .where((element) => imageFilter(element))
              .map((e) => Meme(
                  imageGlobal: GlobalKey(),
                  id: e['name'],
                  url: e['url'],
                  height:
                      e['preview']['images'][0]['source']['height'].toString(),
                  width:
                      e['preview']['images'][0]['source']['width'].toString()))
              .toList();
          log("First time: newList: ${newList.length}");
          memes.addAll(newList.take(5).toList());
          saveLastID();

          memesQueue.addAll(newList.skip(5));
          _streamController.add(memes);
          _isRequesting = false;
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        log("SUCESS LOADING FROM LASTID ${memes.last.getId}");
        widget.reddit
            .subreddit(subred)
            .hot(limit: 30, after: memes.last.getId)
            .toList()
            .then((value) {
          // log(json.decode(value.toString())[0].toString());

          List<Meme> newList = value
              .map((e) => json.decode(e.toString()))
              .toList()
              .where((element) => imageFilter(element))
              .map((e) => Meme(
                  imageGlobal: GlobalKey(),
                  id: e['name'],
                  url: e['url'],
                  height:
                      e['preview']['images'][0]['source']['height'].toString(),
                  width:
                      e['preview']['images'][0]['source']['width'].toString()))
              .toList();
          memes.addAll(newList.take(5).toList());
          saveLastID();

          memesQueue.addAll(newList.skip(5));
          _streamController.add(memes);
          _isRequesting = false;
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }

  bool imageFilter(dynamic element) {
    return element['url'].toString().contains("i.redd") &&
        !element['url'].toString().contains(".gif") &&
        ((hasCrappyInternet &&
                (element['preview']['images'][0]['source']['height'] *
                        element['preview']['images'][0]['source']['width'] <
                    2250000)) ||
            !hasCrappyInternet);
  }
}
