import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:provider/provider.dart';

import '../config.dart';

class SheetsMemeOptions extends StatelessWidget {
  const SheetsMemeOptions({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ThemeMeme>(
        child: Consumer<ThemeMeme>(builder: (context, val, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 0.8,
            child: MaterialButton(
              color: appColors[val.selectedAppColor].main,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              height: 40,
              splashColor: appColors[val.selectedAppColor].accent,
              onPressed: () {
                GetIt.I<ThemeMeme>().learn++;
                // addScore();
                Navigator.pop(context);
                GetIt.I<ThemeMeme>()
                    .showToast(Icons.thumb_up, "Learned Preference");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("See More of This",
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.thumb_up, color: Colors.white)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width * 0.8,
            child: MaterialButton(
              color: appColors[val.selectedAppColor].main,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              height: 40,
              splashColor: appColors[val.selectedAppColor].accent,
              onPressed: () {
                GetIt.I<ThemeMeme>().learn++;
                // addScore();
                Navigator.pop(context);
                GetIt.I<ThemeMeme>()
                    .showToast(Icons.thumb_down, "Learned Preference");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("See Less of This",
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.thumb_down, color: Colors.white)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width * 0.8,
            child: MaterialButton(
              color: appColors[val.selectedAppColor].main,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              height: 40,
              splashColor: appColors[val.selectedAppColor].accent,
              onPressed: () {
                GetIt.I<ProviderMemes>().saveImage(index);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Save to Favorites",
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.favorite, color: Colors.white)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width * 0.8,
            child: MaterialButton(
              color: appColors[val.selectedAppColor].main,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              height: 40,
              splashColor: appColors[val.selectedAppColor].accent,
              onPressed: () {
                GetIt.I<ProviderMemes>().shareMeme(index);
                // shareImage(index);
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
            ),
          )
        ],
      );
    }), builder: (context, val, child) {
      return Container(
          decoration: BoxDecoration(
              color:
                  backgroundColors[val.selectedBackground].main.withAlpha(245),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          width: size.width,
          height: 240,
          child: child);
    });
  }
}
