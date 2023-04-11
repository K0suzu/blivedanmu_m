class Gift {
  Gift(dynamic giftObject) {
    userName = giftObject["payload"]["data"]["uname"];
    time = giftObject["payload"]["data"]["timestamp"];
    giftName = giftObject["payload"]["data"]["giftName"];
    count = giftObject["payload"]["data"]["num"];
  }

  String? userName; // 用户名
  int? time; // 发送时间
  String? giftName; // 礼物名
  int? count; // 数量
}
