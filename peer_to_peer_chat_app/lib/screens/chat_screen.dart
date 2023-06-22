import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:peer_to_peer_chat_app/Services/AESencrypter.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';
import 'package:peer_to_peer_chat_app/webrtc_mesh.dart';
import 'package:peer_to_peer_chat_app/services/firestore_signalling.dart';

import '../src/models/contact_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String chatName;
  final WebRTCMesh webRTCMesh;

  ChatScreen({Key? key, required this.roomId, required this.chatName})
      : webRTCMesh = WebRTCMesh<FirestoreSignalling>(
          roomID: roomId,
          signallingCreator: (roomId, localPeerID) =>
              FirestoreSignalling(roomId: roomId, localPeerID: localPeerID),
        ),
        super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Contact>? contacts;
  final _messages = <Message>[];
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    contacts = ContactService.allContacts;
  }

 @override
  void dispose() {
    super.dispose();
    FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
    'members': FieldValue.arrayRemove([MyPhone.phoneNumber])
  });

    widget.webRTCMesh.dispose();
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

  void _sendMessage(String message) {
    widget.webRTCMesh.printPeers();
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      widget.webRTCMesh.sendToAllPeers(message);
      widget.webRTCMesh.messageStream.add(Message(
        message: message,
        type: 'text',
        from: widget.webRTCMesh.localPeerID,
      ));
      _textController.clear();
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            widget.webRTCMesh.printPeers();
          },
        ),
      ],
      title: Row(
        children: [
          Text(widget.chatName,
              style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
        ],
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<Message>(
            stream: widget.webRTCMesh.messageStream.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('No messages yet'),
                );
              }

              _messages.add(snapshot.data!);
              
              return ListView.builder(
               // controller: _scrollController,
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final reversedIndex = _messages.length - 1 - index;
                  final message = _messages[reversedIndex];
                  //final message = _messages[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(message.from)
                        .get(),
                    builder: (context, snapshot) {
                      final decryptedMessage;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text('User not found');
                      }
                      if ((message.type == 'message' || message.type == 'failed_datachannel') && message.from != MyPhone.phoneNumber) {
                         var remotePublicKey = snapshot.data!['publicKey'];
                        final sharedKey = AESencrypter.performDiffieHellmanExchange(MyPhone.keyPair['privateKey']!, remotePublicKey);
                        print("shared key: $sharedKey, messageType: ${message.type}");
                        decryptedMessage = /*message.message;*/AESencrypter.performAESDecryption(sharedKey, message.message!);

                      }
                     else {
                        decryptedMessage = message.message;
                      }
                      return ListTile(
                        title: Text(decryptedMessage ?? ''),
                        subtitle: Text(getContactName(message.from)),
                        trailing: Text(message.type),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendMessage(_textController.text);
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}