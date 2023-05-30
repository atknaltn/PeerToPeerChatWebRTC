import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/phone.dart';
import 'package:peer_to_peer_chat_app/webrtc_helper.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('signaling')
              .where('receiver', isEqualTo: MyPhone.phoneNumber)
              .where('status', isEqualTo: 'pending')
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
                  return ListTile(
                    title: Text('${request['sender']} wants to chat with you'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            await _updateRequest(request, 'accepted');
                            RTCSessionDescription offer;
                            final offerMap = json.decode(request['sdpSender']);
                            offer = RTCSessionDescription(
                              offerMap["sdp"],
                              offerMap["type"],
                            );
                            WebRTCHelper webRTCHelper = WebRTCHelper();
                            MyPhone.webRTCHelpers[request['sender']] =
                                webRTCHelper;
                            // print(">>>>>>>>>>>>>>>>>>>>>>>> PHONE: "+request['sender']);
                            var sdp = await MyPhone
                                .webRTCHelpers[request['sender']]!
                                .answerConnection(offer);
                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('signaling')
                                    .where('sender',
                                        isEqualTo: request['sender'])
                                    .where('receiver',
                                        isEqualTo: MyPhone.phoneNumber)
                                    .where('status', isEqualTo: 'accepted')
                                    .get();
                            List<DocumentSnapshot> documents =
                                querySnapshot.docs;
                            for (int i = 0; i < documents.length; i++) {
                              print("EN AZ BIR KERE GIRDI");
                              DocumentReference documentReference =
                                  FirebaseFirestore.instance
                                      .collection('signaling')
                                      .doc(documents[i].id);

                              await documentReference.update(
                                  {'status': 'done', 'sdpReceiver': sdp});
                            }
                            print("SAAAAA");
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await _updateRequest(request, 'rejected');
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
