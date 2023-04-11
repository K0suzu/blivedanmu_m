import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListText extends StatelessWidget {
  ListText(this.data, {super.key, this.color});

  String data;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(color: color, height: 2),
    );
  }
}
