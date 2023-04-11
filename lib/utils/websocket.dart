import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef MessageFunction = void Function(dynamic)?;

class BliveWebScoket {
  BliveWebScoket(
      {required this.rid,
      required this.onMessage,
      required this.onError,
      this.onConnect});

  WebSocket? channel;
  String rid; // 房间id
  MessageFunction onMessage; // 接收到弹幕回调
  Function onError; // 错误回调
  VoidCallback? onConnect; // 连接开启后回调

  connect() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString("serverUrl");
      debugPrint("开始连接");
      if (url == null) {
        throw ("url does not exists");
      }
      channel = await WebSocket.connect(url);
      debugPrint("连接成功");

      if (onConnect != null) {
        onConnect!();
      }

      var config = {
        "cmd": "enter",
        "rid": rid,
        "events": [
          "DANMU_MSG", // 普通弹幕
          "SUPER_CHAT_MESSAGE", // sc?
          "GUARD_BUY", // 舰长
          "SEND_GIFT", // 礼物?
        ]
      };

      channel?.listen(onMessage);
      channel?.add(json.encode(config));
    } catch (e) {
      onError(e);
    }
  }

  disconnect() {
    if (channel == null) {
      return;
    }
    var config = {"cmd": "leave", "rid": rid};
    channel?.add(json.encode(config));
    channel?.close();
  }
}
