import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/webrtc_helper.dart';

class SignalHandler {
  Future<bool> sendRequest(BuildContext context, String phoneNumber) async {
    // Check if there is already a pending request from the same sender to the same receiver
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('signaling')
        .where('sender', isEqualTo: MyPhone.phoneNumber)
        .where('receiver', isEqualTo: phoneNumber)
        .where('status', isEqualTo: 'pending')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return false;
    } else {
      String sdp = await MyPhone.webRTCHelper!.offerConnection();
      await FirebaseFirestore.instance.collection('signaling').add({
        'sender': MyPhone.phoneNumber,
        'receiver': phoneNumber,
        'status': 'pending',
        'sdpSender': sdp,
        'sdpReceiver': ''
      });
    }
    return true;
  }
}
