import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/sheets/sheet_meme_options.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class MemePages extends StatefulWidget {
  const MemePages({Key? key}) : super(key: key);

  @override
  MemePagesState createState() => MemePagesState();
}

class MemePagesState extends State<MemePages> {
  final PreloadPageController _pageController = PreloadPageController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ProviderMemes>(
      builder: (context, value, child) {
        return PreloadPageView.builder(
            itemCount: value.memes.length,
            preloadPagesCount: 5,
            controller: _pageController,
            onPageChanged: (val) {
              if (val == value.memes.length - 2) {
                GetIt.I<ProviderMemes>().requestNextPage();
                // requestNextPage();
              }
            },
            itemBuilder: (context, index) {
              if ((value.memes.first.getHeight == "")) {
                log("Loading empty box");
                value.memes.removeAt(0);
                return const SizedBox(
                  height: 5,
                );
              }
              double imageAspect = double.parse(value.memes[index].width) /
                  double.parse(value.memes[index].height);

              double screenWidth = size.width;
              double widgetHeight = screenWidth / imageAspect;

              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: size.width,
                height: widgetHeight,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: RepaintBoundary(
                        key: value.memes[index].imageGlobal,
                        child: CachedNetworkImage(
                          imageUrl: value.memes[index].getUrl,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child:
                                Consumer<ThemeMeme>(builder: (context, val, _) {
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
                    Positioned.fill(
                        child: Material(
                      color: Colors.transparent,
                      child: Consumer<ThemeMeme>(builder: (context, val, _) {
                        return InkWell(
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
      },
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
}
