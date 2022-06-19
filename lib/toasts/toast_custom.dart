import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:memes_max/config.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:provider/provider.dart';

class ToastCustom extends StatelessWidget {
  const ToastCustom({Key? key, required this.iconData, required this.message})
      : super(key: key);
  final IconData iconData;
  final String message;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 45,
      width: size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Consumer<ThemeMeme>(builder: (context, val, _) {
            return Container(
              alignment: Alignment.center,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                color: appColors[val.selectedAppColor].main,
              ),
              child: Icon(iconData, color: Colors.white),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Consumer<ThemeMeme>(builder: (context, val, _) {
                return Text(message,
                    style:
                        TextStyle(color: appColors[val.selectedAppColor].main));
              }),
            ),
          )
        ],
      ),
    );
  }
}
