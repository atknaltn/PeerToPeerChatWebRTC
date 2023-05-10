import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/chatlistscreen.dart';
import 'package:peer_to_peer_chat_app/chatscreen.dart';
import 'package:peer_to_peer_chat_app/contacts.dart';
import 'package:peer_to_peer_chat_app/request_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Chat List",
                ),
                Tab(
                  text: "Requests",
                ),
                Tab(
                  text: "Contacts",
                ),
                Tab(
                  text: "Chat",
                ),
              ],
            ),
            title: const Text('Peer2Peer Chat'),
          ),
          body: TabBarView(
            children: [
              const ChatListScreen(),
              const RequestScreen(),
              ContactScreen(),
              const ChatScreen()
            ],
          ),
        ),
      ),
    );
  }
}
