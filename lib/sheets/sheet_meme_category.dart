import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:provider/provider.dart';

class SheetMemeCategory extends StatelessWidget {
  const SheetMemeCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ThemeMeme>(builder: (context, val, _) {
      return Container(
          width: size.width,
          height: 400,
          decoration: BoxDecoration(
              color: backgroundColors[val.selectedBackground].main,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
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
              ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        child: Selector<ProviderMemes, String>(
                            selector: (p0, p1) => p1.subreddit,
                            builder: (context, subred, _) {
                              return MaterialButton(
                                color: memeCategories[index] == subred
                                    ? appColors[val.selectedAppColor].selected
                                    : appColors[val.selectedAppColor].main,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                height: 40,
                                splashColor:
                                    appColors[val.selectedAppColor].accent,
                                onPressed: () {
                                  GetIt.I<ProviderMemes>().updateMemeCategory(
                                      memeCategories[index]);
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(memeCategories[index],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
                                ),
                              );
                            }),
                      ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: memeCategories.length),

              // SizedBox(height: 10),
              // SizedBox(
              //   width: size.width * 0.8,
              //   child: MaterialButton(
              //     // color: subred == "AdviceAnimals"
              //     //     ? appColors[val.selectedAppColor].selected
              //     //     : appColors[val.selectedAppColor].main,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //     height: 40,
              //     splashColor: appColors[val.selectedAppColor].accent,
              //     onPressed: () {
              //       GetIt.I<ProviderMemes>()
              //           .updateMemeCategory("AdviceAnimals");

              //       SharedPreferences.getInstance().then((prefs) {
              //         // subred = "AdviceAnimals";
              //         // memes.clear();
              //         // memesQueue.clear();
              //         // GetIt.I<ProviderMemes>().requestNextPage();
              //         // // if (GetIt.I<ThemeMeme>().isScrollableList) {
              //         // //   GetIt.I<ProviderMemes>().requestNextPage();
              //         // //   // memeListKey.currentState?.requestNextPage();
              //         // // } else {
              //         // //   memePageKey.currentState?.requestNextPage();
              //         // // }
              //         // loadLastMeme(subred, prefs);
              //         // setState(() {});
              //         Navigator.pop(context);
              //       });
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text("AdviceAnimals",
              //             style: TextStyle(color: Colors.white)),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // SizedBox(
              //   width: size.width * 0.8,
              //   child: MaterialButton(
              //     // color: subred == "ComedyCemetery"
              //     //     ? appColors[val.selectedAppColor].selected
              //     //     : appColors[val.selectedAppColor].main,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //     height: 40,
              //     splashColor: appColors[val.selectedAppColor].accent,
              //     onPressed: () {
              //       GetIt.I<ProviderMemes>()
              //           .updateMemeCategory("ComedyCemetery");

              //       SharedPreferences.getInstance().then((prefs) {
              //         // subred = "ComedyCemetery";
              //         // memes.clear();
              //         // memesQueue.clear();
              //         // GetIt.I<ProviderMemes>().requestNextPage();
              //         // // if (GetIt.I<ThemeMeme>().isScrollableList) {
              //         // //   GetIt.I<ProviderMemes>().requestNextPage();
              //         // //   // memeListKey.currentState?.requestNextPage();
              //         // // } else {
              //         // //   memePageKey.currentState?.requestNextPage();
              //         // // }
              //         // loadLastMeme(subred, prefs);
              //         // setState(() {});
              //         Navigator.pop(context);
              //       });
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: const [
              //         Text("ComedyCemetery",
              //             style: TextStyle(color: Colors.white)),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // SizedBox(
              //   width: size.width * 0.8,
              //   child: MaterialButton(
              //     // color: subred == "terriblefacebookmemes"
              //     //     ? appColors[val.selectedAppColor].selected
              //     //     : appColors[val.selectedAppColor].main,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //     height: 40,
              //     splashColor: appColors[val.selectedAppColor].accent,
              //     onPressed: () {
              //       SharedPreferences.getInstance().then((prefs) {
              //         // subred = "terriblefacebookmemes";
              //         GetIt.I<ProviderMemes>()
              //             .updateMemeCategory("terriblefacebookmemes");
              //         // memes.clear();
              //         // memesQueue.clear();
              //         // GetIt.I<ProviderMemes>().requestNextPage();

              //         // // if (GetIt.I<ThemeMeme>().isScrollableList) {
              //         // //   GetIt.I<ProviderMemes>().requestNextPage();
              //         // //   // memeListKey.currentState?.requestNextPage();
              //         // // } else {
              //         // //   memePageKey.currentState?.requestNextPage();
              //         // // }
              //         // loadLastMeme(subred, prefs);
              //         // setState(() {});
              //         Navigator.pop(context);
              //       });
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: const [
              //         Text("terriblefacebookmemes",
              //             style: TextStyle(color: Colors.white)),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // SizedBox(
              //   width: size.width * 0.8,
              //   child: MaterialButton(
              //     // color: subred == "animememes"
              //     //     ? appColors[val.selectedAppColor].selected
              //     //     : appColors[val.selectedAppColor].main,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //     height: 40,
              //     splashColor: appColors[val.selectedAppColor].accent,
              //     onPressed: () {
              //       GetIt.I<ProviderMemes>().updateMemeCategory("animememes");

              //       SharedPreferences.getInstance().then((prefs) {
              //         // subred = "animememes";
              //         // memes.clear();
              //         // memesQueue.clear();
              //         // GetIt.I<ProviderMemes>().requestNextPage();
              //         // // if (GetIt.I<ThemeMeme>().isScrollableList) {
              //         // //   GetIt.I<ProviderMemes>().requestNextPage();
              //         // //   // memeListKey.currentState?.requestNextPage();
              //         // // } else {
              //         // //   memePageKey.currentState?.requestNextPage();
              //         // // }
              //         // loadLastMeme(subred, prefs);
              //         // setState(() {});
              //         Navigator.pop(context);
              //       });
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: const [
              //         Text("Anime Memes",
              //             style: TextStyle(color: Colors.white)),
              //       ],
              //     ),
              //   ),
              // )
            ],
          ));
    });
  }
}
