import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/webrtc_helper.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
                  .where(
                  Filter.or(
                    Filter("sender", isEqualTo: MyPhone.phoneNumber),
                    Filter.or(
                      Filter.and(
                        Filter("type", isEqualTo: "peer"),
                        Filter("receiver", isEqualTo: MyPhone.phoneNumber),
                      ),
                      Filter.and(
                        Filter("type", isEqualTo: "group"),
                        Filter("members", arrayContains: MyPhone.phoneNumber),
                      ),
                    ),
                  ),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot request = snapshot.data!.docs[index];
                  String room_id = request.id;
                  String remotePeer;
                  if (request['type'] == "peer") {
                                    if (request['receiver'] == MyPhone.phoneNumber) {
                    remotePeer = request['sender'];
                  }
                  else{
                    remotePeer = request['receiver'];
                  }
                  }
                  else{
                    remotePeer = "GROUP";
                  }
                  return ListTile(
                    title: Text(remotePeer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_right_outlined),
                          onPressed: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(remotePhoneNumber: remotePeer,),));
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(roomId: room_id,),));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _updateRequest(DocumentSnapshot request, String status) async {
    await FirebaseFirestore.instance
        .collection('signaling')
        .doc(request.id)
        .update({'status': status});
  }
}
