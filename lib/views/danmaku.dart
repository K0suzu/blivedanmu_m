import 'dart:convert';

import 'package:blivedanmu_m/types/gift.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../components/list_text.dart';
import '../types/comment.dart';
import '../utils/websocket.dart';

class Danmaku extends StatelessWidget {
  const Danmaku({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map<String, dynamic>;

    return DanmakuContent(
      rid: arguments["rid"],
    );
  }
}

class DanmakuContent extends StatefulWidget {
  const DanmakuContent({super.key, required this.rid});

  final String rid;

  @override
  State<DanmakuContent> createState() => _DanmakuContentState();
}

class _DanmakuContentState extends State<DanmakuContent> {
  List<Comment> commentList = [];
  List<Gift> giftList = [];

  final commentListKey = GlobalKey<AnimatedListState>();

  bool isLoading = true;

  late BliveWebScoket bliveWebScoket = BliveWebScoket(
      rid: widget.rid,
      onConnect: () {
        // 连接成功，关闭连接中提示
        setState(() {
          isLoading = false;
        });
      },
      onError: (e) {
        // 总之就是不知道怎么回事
        Navigator.of(context).pop();
      },
      onMessage: (message) {
        if (message == "heartbeat") return;
        var msg = json.decode(message);
        switch (msg["payload"]["cmd"]) {
          // 新弹幕
          case "DANMU_MSG":
            Comment comment = Comment(msg);
            setState(() {
              commentList.insert(0, comment);
              commentListKey.currentState!
                  .insertItem(0, duration: const Duration(seconds: 1));
            });
            break;
          // 新礼物
          case "SEND_GIFT":
            Gift gift = Gift(msg);
            setState(() {
              giftList.insert(0, gift);
            });
            break;
          default:
        }
      });

  @override
  void dispose() {
    bliveWebScoket.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    bliveWebScoket.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RenderGift(
                  giftList: giftList,
                ),
                const Divider(),
                RenderComment(
                  commentList: commentList,
                  listKey: commentListKey,
                ),
              ],
            ),
    );
  }
}

class RenderGift extends StatelessWidget {
  const RenderGift({super.key, required this.giftList});

  final List<Gift> giftList;

  String formatTime(int time) {
    DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(time);
    return formatDate(currentTime, [HH, ":", nn, ":", ss]);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
          itemCount: giftList.length,
          itemBuilder: (ctx, index) {
            return ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListText(
                    giftList[index].userName ?? "",
                    color: Colors.cyan,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListText(
                      "赠送",
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ListText(
                          "${giftList[index].giftName}",
                          color: Colors.pinkAccent,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListText("X"),
                        ),
                        ListText("${giftList[index].count}")
                      ],
                    ),
                  ),
                  Opacity(
                      opacity: 0.7,
                      child: ListText(formatTime(giftList[index].time ?? 0))),
                ],
              ),
            );
          }),
    );
  }
}

class RenderComment extends StatelessWidget {
  const RenderComment(
      {super.key, required this.commentList, required this.listKey});
  final List<Comment> commentList;
  final GlobalKey<AnimatedListState> listKey;

  String formatTime(int time) {
    DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(time);
    return formatDate(currentTime, [HH, ":", nn, ":", ss]);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 3,
        child: AnimatedList(
            key: listKey,
            initialItemCount: commentList.length,
            itemBuilder: (ctx, index, animation) {
              return FadeTransition(
                opacity: animation,
                child: ListTile(
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListText(
                        commentList[index].userName ?? "",
                        color: Colors.cyan,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ListText(":"),
                      ),
                      Expanded(
                          child: ListText(commentList[index].content ?? "")),
                      Opacity(
                        opacity: 0.7,
                        child: ListText(
                            formatTime(commentList[index].time?.toInt() ?? 0)),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
