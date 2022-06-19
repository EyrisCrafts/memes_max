import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/provider_memes.dart';
import 'package:memes_max/screens/screen_main/widgets/app_bar_custom.dart';
import 'package:memes_max/screens/screen_main/widgets/memes_list.dart';
import 'package:memes_max/screens/screen_main/widgets/memes_pages.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:provider/provider.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({Key? key}) : super(key: key);

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  @override
  void initState() {
    super.initState();
    GetIt.I<ThemeMeme>().setupFToast(context);
    GetIt.I<ProviderMemes>().requestNextPage();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double statusHeight = MediaQuery.of(context).viewPadding.top;

    return Consumer<ThemeMeme>(
        child: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[const CustomAppBar()];
              },
              body: Consumer<ThemeMeme>(builder: (context, val, _) {
                return Container(
                  child: val.isScrollableList
                      ? const MemeList()
                      : const MemePages(),
                );
              }),
            ),
            Positioned(
                top: 55 + statusHeight,
                child: Consumer2<ThemeMeme, ProviderMemes>(
                    builder: (context, val, memes, _) {
                  if (!memes.isLoading) return const SizedBox();
                  return SizedBox(
                    width: size.width,
                    height: 5,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          appColors[val.selectedAppColor].main),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                })),
            Positioned(
              child: Consumer2<ThemeMeme, ProviderMemes>(
                  builder: (context, val, provMemes, _) {
                if (!(provMemes.isLoading && provMemes.memes.isEmpty))
                  return const SizedBox();
                return Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: Text("Your Daily dose of Relaxation\n\n:)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: appColors[val.selectedAppColor].main)),
                );
              }),
            )
          ],
        ),
        builder: (context, val, child) {
          return Scaffold(
              backgroundColor: backgroundColors[val.selectedBackground].main,
              body: child);
        });
  }
}
