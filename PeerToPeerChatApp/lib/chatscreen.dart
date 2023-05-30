import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peer_to_peer_chat_app/message.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ChatScreen extends StatefulWidget {
  final String remotePhoneNumber;
  const ChatScreen({super.key, required this.remotePhoneNumber});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final chatController = TextEditingController();
  DateTime date = DateTime(2017, 9, 7, 17, 30);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[IconButton(icon: Icon(Icons.exit_to_app),onPressed: () {
          MyPhone.webRTCHelpers[widget.remotePhoneNumber]!.endSession();
          
          print("slm");
        },),],
        /*<Widget>[
          Padding(padding: const EdgeInsets.only(right: 16.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Container()],),)
        ],*/
      ),
      body: Column(
        children: [
          Expanded(
            child: Observer(builder: (_) {
              return GroupedListView<Message, DateTime>(
                padding: EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                elements: MyPhone.webRTCHelpers[widget.remotePhoneNumber]!.messages.toList(),
                groupBy: (message) => DateTime(
                  message.date.year,
                  message.date.month,
                  message.date.day,
                ),
                groupHeaderBuilder: (Message message) => SizedBox(
                  height: 40,
                  child: Center(
                    child: Card(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(DateFormat.yMMMd().format(message.date)),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, Message message) {
                  return Align(
                    alignment: message.isSentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message.text),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            color: Colors.grey.shade300,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      await MyPhone.webRTCHelpers[widget.remotePhoneNumber]!
                          .sendMessage(chatController.text);
                      chatController.clear();
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
