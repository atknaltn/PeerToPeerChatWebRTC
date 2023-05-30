import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/webrtc_helper.dart';

import 'chatscreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final webRTCHelper = WebRTCHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('signaling')
              .where(
                Filter.and(
                  Filter("status", isEqualTo: 'done'),
                  Filter.or(
                    Filter("sender", isEqualTo: MyPhone.phoneNumber),
                    Filter("receiver", isEqualTo: MyPhone.phoneNumber),
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
                  String remotePeer;
                  if (request['receiver'] == MyPhone.phoneNumber) {
                    remotePeer = request['sender'];
                  }
                  else{
                    remotePeer = request['receiver'];
                  }
                  return ListTile(
                    title: Text(remotePeer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.join_full),
                          onPressed: () {
                           /* if (request['sender'] == MyPhone.phoneNumber) {
                              RTCSessionDescription answer;
                              final answerMap =
                                  json.decode(request['sdpReceiver']);
                              answer = RTCSessionDescription(
                                answerMap["sdp"],
                                answerMap["type"],
                              );
                              await MyPhone.webRTCHelper!.acceptAnswer(answer);
                            }*/
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(remotePhoneNumber: remotePeer,),));
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
