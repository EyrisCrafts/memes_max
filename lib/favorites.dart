import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/themeMeme.dart';
import 'package:memes_max/submission.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<MemeFile>> paths;
  late List<MemeFile> memes;

  @override
  void initState() {
    paths = loadImagePaths();
    memes = [];
    super.initState();
  }

  Future<List<MemeFile>> loadImagePaths() async {
    log("Looking for images");
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return [];
    List<FileSystemEntity> files = await directory.list().toList();
    return files
        .map((FileSystemEntity e) => MemeFile(path: e.path, key: GlobalKey()))
        .toList();

    // .then((directory) {
    //   directory.list();
    //   File imageFile = File("${directory.path}/temp.png");

    //   imageFile.writeAsBytesSync(pngBytes);
    //   Share.shareFiles(
    //     ['${directory.path}/temp.png'],
    //     text: 'Checkout this meme',
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
              child: Consumer<ThemeMeme>(builder: (context, val, _) {
            return Container(
                color: backgroundColors[val.selectedBackground].main);
          })),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Consumer<ThemeMeme>(builder: (context, val, _) {
                      return Container(
                        margin: const EdgeInsets.only(left: 10),
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: appColors[val.selectedAppColor].main,
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context)),
                      );
                    }),
                    Expanded(
                      child: Consumer<ThemeMeme>(builder: (context, val, _) {
                        return Text(
                          "Favorite Memes",
                          style: TextStyle(
                              color: appColors[val.selectedAppColor].main,
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        );
                      }),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ],
                ),
                FutureBuilder<List<MemeFile>>(
                  future: paths,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    memes = snapshot.data ?? [];
                    return Expanded(
                        child: ListView.builder(
                            itemCount: memes.length,
                            itemBuilder: (context, index) {
                              return Consumer<ThemeMeme>(
                                  builder: (context, val, _) {
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  width: size.width - 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            offset: const Offset(2, 2),
                                            spreadRadius: 3,
                                            blurRadius: 5),
                                        BoxShadow(
                                            color: backgroundColors[
                                                    val.selectedBackground]
                                                .shade,
                                            offset: const Offset(-2, -2),
                                            spreadRadius: 2,
                                            blurRadius: 4)
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        RepaintBoundary(
                                          key: memes[index].key,
                                          child: Image.file(
                                            File(memes[index].getPath),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: Material(
                                          color: Colors.transparent,
                                          child: Consumer<ThemeMeme>(
                                              builder: (context, val, _) {
                                            return InkWell(
                                              onLongPress: () =>
                                                  onTapBottomSheet(index, size),
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: appColors[
                                                      val.selectedAppColor]
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
                            }));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  onTapBottomSheet(int index, Size size) {
    showModalBottomSheet(
        backgroundColor:
            backgroundColors[GetIt.I<ThemeMeme>().selectedBackground].main,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return SizedBox(
            width: size.width,
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  child: Consumer<ThemeMeme>(builder: (context, val, _) {
                    return MaterialButton(
                      color: appColors[val.selectedAppColor].main,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 40,
                      splashColor: appColors[val.selectedAppColor].accent,
                      onPressed: () {
                        shareImage(index);
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Share this Meme",
                              style: TextStyle(color: Colors.white)),
                          Icon(Icons.share_rounded, color: Colors.white)
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
          );
        });
  }

  void shareImage(int index) async {
    RenderRepaintBoundary? boundary = memes[index]
        .key
        .currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

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
}
