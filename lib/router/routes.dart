import 'package:blivedanmu_m/views/danmaku.dart';
import 'package:blivedanmu_m/views/home.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  "/home": (context) => const MyHomePage(),
  "/danmaku": (context) => const Danmaku()
};
