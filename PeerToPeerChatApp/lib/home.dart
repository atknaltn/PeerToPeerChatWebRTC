import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/chatlistscreen.dart';
import 'package:peer_to_peer_chat_app/chatscreen.dart';
import 'package:peer_to_peer_chat_app/contacts.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/request_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    startSignalingListener(MyPhone.phoneNumber);
  }
 void startSignalingListener(String userId) async {
  final signalingRef = FirebaseFirestore.instance.collection('signaling');
  
  // Set up the listener
    signalingRef.snapshots().listen((snapshot) async {
    for (var change in snapshot.docChanges) {
      final doc = change.doc;
      final signalingData = doc.data();
      final String documentId = doc.id;

      final String receiverId = signalingData!['receiver'];
      final String senderId = signalingData['sender'];
      final String status = signalingData['status'];

      final String sdpReceiver = signalingData['sdpReceiver'];
      final String sdpSender = signalingData['sdpSender'];

      if (senderId == MyPhone.phoneNumber && status == 'done') 
      {
        print("VAY AQ BAKALIM OLCAK MI");
        RTCSessionDescription answer;
        final answerMap =
            json.decode(sdpReceiver);
            answer = RTCSessionDescription(
            answerMap["sdp"],
            answerMap["type"],
        );
        await MyPhone.webRTCHelpers[receiverId]!.acceptAnswer(answer); 
      }

      // Check if receiverId or senderId equals userId and status is "done"
     /* if (receiverId == userId  && status == 'done') {
        print("VAY AQ BAKALIM OLCAK MI: receiverID:" + receiverId + " status: " + status);
        // Retrieve the remote description and call setRemoteDescription
                                  RTCSessionDescription offer;
                            final offerMap = json.decode(sdpReceiver);
                            offer = RTCSessionDescription(
                              offerMap["sdp"],
                              offerMap["type"],
                            );

                                                        RTCSessionDescription offer2;
                            final offerMap2 = json.decode(sdpSender);
                            offer2 = RTCSessionDescription(
                              offerMap2["sdp"],
                              offerMap2["type"],
                            );

        await MyPhone.webRTCHelper!.setConnections(offer,offer2);
      }*/

      /*if (senderId == userId && status == 'done') {
        print("VAY AQ BAKALIM OLCAK MI 2");
                          RTCSessionDescription answer;
                            final offerMap2 = json.decode(sdpReceiver);
                            answer = RTCSessionDescription(
                              offerMap2["sdp"],
                              offerMap2["type"],
                            );


        await MyPhone.webRTCHelper!.acceptAnswer(answer);
      }*/

    }
  });
}



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
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
              ],
            ),
            title: const Text('Peer2Peer Chat'),
          ),
          body: TabBarView(
            children: [
              const ChatListScreen(),
              const RequestScreen(),
              ContactScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
