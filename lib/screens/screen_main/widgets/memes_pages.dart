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
import 'package:memes_max/models/last_meme.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/sheets/sheet_meme_options.dart';
import 'package:memes_max/submission.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'memes_list.dart';

class MemePages extends StatefulWidget {
  final String currentSub;
  final Reddit reddit;

  const MemePages({Key? key, required this.currentSub, required this.reddit})
      : super(key: key);

  @override
  MemePagesState createState() => MemePagesState();
}

class MemePagesState extends State<MemePages> {
  late StreamController<List<Meme>> _streamController;
  late Future<dynamic> firstReq;
  late bool _isRequesting;

  late bool _isLoading;
  late PreloadPageController _pageController;

  @override
  void initState() {
    _streamController = StreamController();
    _isRequesting = false;
    _isLoading = true;
    firstReq = requestNextPage();
    _pageController = PreloadPageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder<List<Meme>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(
              child: Text("Error Ocurred"),
            );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          return PreloadPageView.builder(
              itemCount: memes.length,
              preloadPagesCount: 5,
              controller: _pageController,
              onPageChanged: (value) {
                if (value == memes.length - 2) {
                  requestNextPage();
                }
              },
              itemBuilder: (context, index) {
                if ((memes.first.getHeight == "")) {
                  log("Loading empty box");
                  memes.removeAt(0);
                  return const SizedBox(
                    height: 5,
                  );
                }
                double imageAspect = double.parse(memes[index].width) /
                    double.parse(memes[index].height);

                double screenWidth = size.width;
                double widgetHeight = screenWidth / imageAspect;

                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  width: size.width,
                  height: widgetHeight,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: RepaintBoundary(
                          key: memes[index].imageGlobal,
                          child: CachedNetworkImage(
                            imageUrl: memes[index].getUrl,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: Consumer<ThemeMeme>(
                                  builder: (context, val, _) {
                                return CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        appColors[val.selectedAppColor].main),
                                    value: progress.progress);
                              }),
                            ),
                          ),
                        ),
                      ),
                      Consumer<ThemeMeme>(
                        builder: (context, value, child) => value.isDarkMode
                            ? Positioned.fill(
                                child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5)),
                              ))
                            : Container(),
                      ),
                      // isDarkMode
                      //     ? Positioned.fill(
                      //         child: Container(
                      //         decoration: BoxDecoration(
                      //             color: Colors.black.withOpacity(0.5)),
                      //       ))
                      //     : Container(),
                      Positioned.fill(
                          child: Material(
                        color: Colors.transparent,
                        child: Consumer<ThemeMeme>(builder: (context, val, _) {
                          return InkWell(
                            // onTap: () =>
                            //     _animateToIndex(index, s ize),
                            onLongPress: () => onTapBottomSheet(index, size),
                            highlightColor: Colors.transparent,
                            splashColor: appColors[val.selectedAppColor]
                                .main
                                .withOpacity(0.3),
                          );
                        }),
                      ))
                    ],
                  ),
                );
              });
        });
  }

  onTapBottomSheet(int index, Size size) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
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
      File imageFile = File("${directory?.path}/${memes[index].getId}.png");
      imageFile.writeAsBytesSync(pngBytes);
      GetIt.I<ThemeMeme>().showToast(Icons.thumb_up, "Saved Image");
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

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
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
    bool hasCrappyInternet = GetIt.I<ThemeMeme>().hasCrappyInternet;
    return element['url'].toString().contains("i.redd") &&
        !element['url'].toString().contains(".gif") &&
        ((hasCrappyInternet &&
                (element['preview']['images'][0]['source']['height'] *
                        element['preview']['images'][0]['source']['width'] <
                    2250000)) ||
            !hasCrappyInternet);
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
}
