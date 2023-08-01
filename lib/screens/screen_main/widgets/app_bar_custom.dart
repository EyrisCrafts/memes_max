import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/screens/screen_favorite/screen_favorites.dart';
import 'package:memes_max/sheets/sheet_meme_category.dart';
import 'package:memes_max/sheets/sheet_settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                  decoration: BoxDecoration(color: appColors[val.selectedAppColor].main, borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          context: context,
                          builder: (context) {
                            return const SheetSettings();
                          });
                    },
                  ));
            }),
          ),
          // Align(
          //   alignment: Alignment.center,
          //   child: Consumer<ThemeMeme>(builder: (context, val, _) {
          //     return MaterialButton(
          //       color: appColors[val.selectedAppColor].main,
          //       height: 40,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(14)),
          //       onPressed: () {
          //         showModalBottomSheet(
          //             shape: const RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.only(
          //                     topLeft: Radius.circular(20),
          //                     topRight: Radius.circular(20))),
          //             context: context,
          //             isScrollControlled: true,
          //             builder: (context) => const SheetMemeCategory());
          //       },
          //       child: const Text(
          //         "Category",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     );
          //   }),
          // ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ThemeMeme>(builder: (context, val, _) {
                  return Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: appColors[val.selectedAppColor].main, borderRadius: BorderRadius.circular(20)),
                    child: IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          Share.share("https://play.google.com/store/apps/details?id=com.eyriscrafts.memesmax");
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
                    decoration: BoxDecoration(color: appColors[val.selectedAppColor].main, borderRadius: BorderRadius.circular(20)),
                    child: IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
