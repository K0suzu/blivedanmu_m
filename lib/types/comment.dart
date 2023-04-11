class Comment {
  Comment(dynamic commentObject) {
    userName = commentObject["payload"]["info"][2][1];
    time = commentObject["payload"]["info"][0][4];
    content = commentObject["payload"]["info"][1];
  }

  String? userName; // 用户名
  int? time; // 发送时间
  String? content; // 弹幕内容
}
