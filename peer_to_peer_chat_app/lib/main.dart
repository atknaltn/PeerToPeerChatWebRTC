import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:peer_to_peer_chat_app/screens/chatlistscreen.dart';
import 'package:peer_to_peer_chat_app/screens/contacts.dart';
import 'package:peer_to_peer_chat_app/screens/home.dart';
import 'package:peer_to_peer_chat_app/src/models/contact_service.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';
import 'package:peer_to_peer_chat_app/screens/verify.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ContactService.fetchContacts();
  runApp(MaterialApp(
    initialRoute: 'phone',
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => HomeScreen(),
      'phone': (context) => MyPhone(),
      'verify': (context) => MyVerify(),
      'contactscreen': (context) => ContactScreen(),
      'chatlistscreen': (context) => ChatListScreen(),
    },
  ));
}

