import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/submission.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import 'package:share_plus/share_plus.dart';

class ProviderMemes extends ChangeNotifier {
  Reddit? reddit;
  bool isLoading = false;
  String subreddit = "memes";
  List<Meme> memes = [];
  String? lastMeme;
  Queue memesQueue = Queue();

  Future<void> setupReddit() async {
    reddit = await Reddit.createReadOnlyInstance(
        clientId: "Y82I2nvR-d4CNg",
        clientSecret: "mTPPwrOque6TX2WuEAqiMp1b6SU",
        userAgent: "whatever");
    notifyListeners();
  }

  void updateMemeCategory(String subreddit) {
    memes.clear();
    this.subreddit = subreddit;
    lastMeme = null;
    requestNextPage();
  }

  void saveImage(int index) async {
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
      GetIt.I<ThemeMeme>().showToast(Icons.thumb_up, "Saved Image");
    });
  }

  void shareMeme(int index) async {
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

  void requestNextPage() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    if (reddit == null) await setupReddit();
    try {
      List<UserContent> content = await reddit!
          .subreddit(subreddit)
          .hot(limit: 30, after: lastMeme)
          .toList();

      memes.addAll(content
          .map((e) => json.decode(e.toString()))
          .toList()
          .where((element) => imageFilter(element))
          .map((e) => Meme(
              imageGlobal: GlobalKey(),
              id: e['name'],
              url: e['url'],
              height: e['preview']['images'][0]['source']['height'].toString(),
              width: e['preview']['images'][0]['source']['width'].toString()))
          .toList());

      isLoading = false;
      notifyListeners();

      //Save last id
      if (memes.isNotEmpty) {
        lastMeme = memes.last.id;
      }
    } catch (e) {
      //Show toast
      print("Error occurred");
      GetIt.I<ThemeMeme>().showToast(Icons.error, "Error Loading memes");
    }

    // if (!isRequesting) {
    //   return;
    //   if (memes.isEmpty) {
    //     reddit
    //         .subreddit(subreddit)
    //         .hot(limit: 30, after: lastMeme)
    //         .toList()
    //         .then((value) {
    //       List<Meme> newList = value
    //           .map((e) => json.decode(e.toString()))
    //           .toList()
    //           .where((element) => imageFilter(element))
    //           .map((e) => Meme(
    //               imageGlobal: GlobalKey(),
    //               id: e['name'],
    //               url: e['url'],
    //               height:
    //                   e['preview']['images'][0]['source']['height'].toString(),
    //               width:
    //                   e['preview']['images'][0]['source']['width'].toString()))
    //           .toList();
    //       log("First time: newList: ${newList.length}");
    //       memes.addAll(newList.take(5).toList());
    //       saveLastID();

    //       memesQueue.addAll(newList.skip(5));
    //       _streamController.add(memes);
    //       isRequesting = false;
    //       isLoading = false;
    //       notifyListeners();
    //     });
    //   } else {
    //     log("SUCESS LOADING FROM LASTID ${memes.last.getId}");
    //     widget.reddit
    //         .subreddit(subred)
    //         .hot(limit: 30, after: memes.last.getId)
    //         .toList()
    //         .then((value) {
    //       // log(json.decode(value.toString())[0].toString());

    //       List<Meme> newList = value
    //           .map((e) => json.decode(e.toString()))
    //           .toList()
    //           .where((element) => imageFilter(element))
    //           .map((e) => Meme(
    //               imageGlobal: GlobalKey(),
    //               id: e['name'],
    //               url: e['url'],
    //               height:
    //                   e['preview']['images'][0]['source']['height'].toString(),
    //               width:
    //                   e['preview']['images'][0]['source']['width'].toString()))
    //           .toList();
    //       memes.addAll(newList.take(5).toList());
    //       saveLastID();

    //       memesQueue.addAll(newList.skip(5));
    //       _streamController.add(memes);
    //       isRequesting = false;
    //       isLoading = false;
    //       notifyListeners();
    //     });
    // }
    // }
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
