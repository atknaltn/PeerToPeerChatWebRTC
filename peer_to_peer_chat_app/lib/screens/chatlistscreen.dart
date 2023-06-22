import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';
import 'package:peer_to_peer_chat_app/src/models/contact_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Contact>? contacts;
  @override
  void initState() {
    super.initState();
    contacts = ContactService.allContacts;
  }

  String getContactName(String phoneNumber) {
    for (var contact in contacts!) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        var contactPhoneNumber = contact.phones![0].value!;
        if (contactPhoneNumber == phoneNumber) {
          return contact.givenName ?? '';
        }
      }
    }
    return phoneNumber;
  }

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
                    String receiver_id = request['receiver'].replaceAll(' ', '');
                    if (MyPhone.phoneNumber.contains(receiver_id)) {
                      remotePeer = getContactName(request['sender']);
                    } else {
                      remotePeer = getContactName(request['receiver']);
                    }
                  } else {
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    roomId: room_id,
                                    chatName: remotePeer,
                                  ),
                                ));
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
