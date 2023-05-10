import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer_to_peer_chat_app/signal_handler.dart';
import 'package:peer_to_peer_chat_app/request_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> contacts = [];
  List<String> _appUsers = [];
  bool isLoading = true;
  var signaling = SignalHandler();

  @override
  void initState() {
    super.initState();
    getContactPermission();
    _getAppUsers();
  }

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContacts() async {
    contacts = await ContactsService.getContacts();
    var toRemove = [];
    for (var element in contacts) {
      if (element.phones == null || element.phones!.isEmpty) {
        toRemove.add(element);
      }
    }
    for (var element in toRemove) {
      contacts.remove(element);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getAppUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<String> appUsers = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String phoneNumber = doc.id;
      appUsers.add(phoneNumber);
    }
    setState(() {
      _appUsers = appUsers;
    });
  }

  bool comparePhoneNumbers(String phoneNumber1) {
    String string1 = phoneNumber1.replaceAll(' ', '');
    if (_appUsers.contains(string1)) {
      return true;
    }
    return false;
  }

  showSendRequestDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Request'),
          content: Text('Do you want to send request "${contact.givenName!}"?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                bool isSended = await signaling.sendRequest(
                    context, contact.phones![0].value!);
                if (isSended == false) {
                  Fluttertoast.showToast(
                      msg: "You already sent a request to this user.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Contact> finalContacts = [];
    for (var element in contacts) {
      if (comparePhoneNumbers(element.phones![0].value!.toString())) {
        finalContacts.add(element);
      }
    }
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: finalContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    showSendRequestDialog(finalContacts[index]);
                  },
                  leading: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.white.withOpacity(0.1),
                          offset: const Offset(-3, -3),
                        ),
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(3, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xff262626),
                    ),
                    child: Text(
                      finalContacts[index].givenName![0],
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)],
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  title: Text(
                    finalContacts[index].givenName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.cyanAccent,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    finalContacts[index].phones![0].value!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xffC4c4c4),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  horizontalTitleGap: 12,
                );
              },
            ),
    );
  }
}
