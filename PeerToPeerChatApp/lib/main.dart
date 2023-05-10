import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/chatlistscreen.dart';
import 'package:peer_to_peer_chat_app/chatscreen.dart';
import 'package:peer_to_peer_chat_app/contacts.dart';
import 'package:peer_to_peer_chat_app/home.dart';
import 'package:peer_to_peer_chat_app/message.dart';
import 'package:peer_to_peer_chat_app/request_screen.dart';
import 'package:peer_to_peer_chat_app/webrtc_helper.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/verify.dart';
import 'message.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: 'phone',
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => HomeScreen(),
      'phone': (context) => MyPhone(),
      'verify': (context) => MyVerify(),
      'contactscreen': (context) => ContactScreen(),
      'requestscreen': (context) => RequestScreen(),
      'chatlistscreen': (context) => ChatListScreen(),
      'chat': (context) => ChatScreen(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  final chatController = TextEditingController();
  final webRTCHelper = WebRTCHelper();
  DateTime date = DateTime(2017, 9, 7, 17, 30);

  @override
  void initState() {
    super.initState();
  }

  void _answerButtonPressed() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Offer SDP'),
          content: TextField(controller: _controller),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                RTCSessionDescription offer;
                final offerMap = json.decode(_controller.text);
                offer = RTCSessionDescription(
                  offerMap["sdp"],
                  offerMap["type"],
                );
                webRTCHelper.answerConnection(offer);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _setRemoteButtonPressed() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Answer SDP'),
          content: TextField(controller: _controller),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                RTCSessionDescription answer;
                final answerMap = json.decode(_controller.text);
                answer = RTCSessionDescription(
                  answerMap["sdp"],
                  answerMap["type"],
                );
                webRTCHelper.acceptAnswer(answer);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Observer(builder: (_) {
              return GroupedListView<Message, DateTime>(
                padding: EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                elements: webRTCHelper.messages.toList(),
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
                      await webRTCHelper.sendMessage(chatController.text);
                      chatController.clear();
                    })
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: Text('Offer'),
                onPressed: () {
                  webRTCHelper.offerConnection();
                  print("sa");
                },
              ),
              ElevatedButton(
                child: Text('Answer'),
                onPressed: () {
                  _answerButtonPressed();
                },
              ),
              ElevatedButton(
                child: Text('Set Remote'),
                onPressed: () {
                  _setRemoteButtonPressed();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
