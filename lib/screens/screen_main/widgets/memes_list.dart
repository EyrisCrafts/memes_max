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
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/sheets/sheet_settings.dart';
import 'package:memes_max/sheets/sheet_meme_options.dart';
import 'package:memes_max/submission.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class MemeList extends StatefulWidget {
  const MemeList({
    Key? key,
  }) : super(key: key);

  @override
  MemeListState createState() => MemeListState();
}

// String subred = "memes";
// List<Meme> memes = [];
// Queue memesQueue = Queue();

class MemeListState extends State<MemeList> {
  // final StreamController<List<Meme>> _streamController = StreamController();
  // late Future<dynamic> firstReq;
  // bool _isRequesting = false;

  // late bool _isLoading;
  late ScrollController scrollController;

  @override
  void initState() {
    // _isLoading = true;

    // firstReq = requestNextPage();

    super.initState();
  }

  _showToast(Size size, String message, IconData iconData) {
    GetIt.I<ThemeMeme>().showToast(iconData, message);
  }

  @override
  void dispose() {
    // _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrollController =
        PrimaryScrollController.of(context) ?? ScrollController();
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.extentAfter < 1000) {
              GetIt.I<ProviderMemes>().requestNextPage();
            }
            return true;
          },
          child: Consumer<ProviderMemes>(builder: (context, provMemes, _) {
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (context, index) {
                  if ((provMemes.memes.first.getHeight == "")) {
                    provMemes.memes.removeAt(0);
                    return const SizedBox(
                      height: 5,
                    );
                  }
                  double imageAspect =
                      double.parse(provMemes.memes[index].width) /
                          double.parse(provMemes.memes[index].height);

                  double screenWidth = size.width - 20;
                  double widgetHeight = screenWidth / imageAspect;

                  return index == provMemes.memes.length - 1
                      ? SizedBox(
                          height: 100,
                          child: Center(child:
                              Consumer<ThemeMeme>(builder: (context, val, _) {
                            return CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  appColors[val.selectedAppColor].main),
                            );
                          })),
                        )
                      : Consumer<ThemeMeme>(builder: (context, val, _) {
                          return Container(
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                                      key: provMemes.memes[index].imageGlobal,
                                      child: CachedNetworkImage(
                                        imageUrl: provMemes.memes[index].getUrl,
                                        progressIndicatorBuilder:
                                            (context, url, progress) => Center(
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
                itemCount: provMemes.memes.length);
          }),
        ),
      ],
    );
  }

  onTapBottomSheet(int index, Size size) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return SheetsMemeOptions(
            index: index,
          );
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
    RenderRepaintBoundary? boundary = GetIt.I<ProviderMemes>()
        .memes[index]
        .imageGlobal
        ?.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // String bs64 = base64Encode(pngBytes);

    getExternalStorageDirectory().then((directory) {
      File imageFile = File(
          "${directory!.path}/${GetIt.I<ProviderMemes>().memes[index].getId}.png");
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
    RenderRepaintBoundary? boundary = GetIt.I<ProviderMemes>()
        .memes[index]
        .imageGlobal
        ?.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // String bs64 = base64Encode(pngBytes);

    getApplicationDocumentsDirectory().then((directory) {
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
        GetIt.I<ProviderMemes>()
            .memes
            .sublist(0, i + 1)
            .map((e) => calcWidgetHeight(e, size) + 20)
            .reduce((value, element) => value + element);

    scrollController.animateTo(totalHeight,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  saveLastID() {
    SharedPreferences.getInstance().then((prefs) {
      String lstMemeJSon =
          prefs.getString(GetIt.I<ProviderMemes>().subreddit) ?? '';
      if (lstMemeJSon.isEmpty) return;
      LastMeme lastMeme = LastMeme.fromJson(lstMemeJSon);

      if (lstMemeJSon == "") {
        prefs.setString(
            GetIt.I<ProviderMemes>().subreddit,
            LastMeme(
                    lastID: GetIt.I<ProviderMemes>().memes.last.getId,
                    lastAccessed: DateTime.now())
                .toJson());
      } else {
        lastMeme.lastID = GetIt.I<ProviderMemes>().memes.last.getId;
        prefs.setString(GetIt.I<ProviderMemes>().subreddit, lastMeme.toJson());
      }
    });
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
}
