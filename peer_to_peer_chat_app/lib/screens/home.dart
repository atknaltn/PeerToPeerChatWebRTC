import 'package:flutter/material.dart';
import 'package:peer_to_peer_chat_app/screens/chatlistscreen.dart';
import 'package:peer_to_peer_chat_app/screens/contacts.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';

import 'package:peer_to_peer_chat_app/Services/AESencrypter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AESencrypter.generateKeyPairAndStorePublicKey(MyPhone.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Chat List",
                ),
                Tab(
                  text: "Contacts",
                ),
              ],
            ),
            title: const Text('Peer2Peer Chat'),
          ),
          body: TabBarView(
            children: [
              const ChatListScreen(),
              ContactScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
