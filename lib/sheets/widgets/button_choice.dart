import 'package:flutter/material.dart';

class ChoiceButton extends StatefulWidget {
  final double width;
  final bool isActive;
  final Color colorMain;
  final Color colorAccent;
  final Function onPress;
  final String text;
  const ChoiceButton(
      {Key? key,
      required this.width,
      required this.text,
      required this.isActive,
      required this.colorMain,
      required this.colorAccent,
      required this.onPress})
      : super(key: key);

  @override
  _ChoiceButtonState createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: MaterialButton(
          color: widget.isActive ? widget.colorMain : Colors.transparent,
          elevation: 0,
          onPressed: () => widget.onPress(),
          splashColor: widget.colorAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: widget.colorMain)),
          child: Text(
            widget.text,
            style: TextStyle(
                color: widget.isActive ? Colors.white : widget.colorMain),
          )),
    );
  }
}
