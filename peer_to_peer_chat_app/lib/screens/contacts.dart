import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
  static _ContactScreenState? of(BuildContext context) =>
    context.findAncestorStateOfType<_ContactScreenState>();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> contacts = [];
  List<String> _appUsers = [];
  bool isLoading = true;
  final List<Contact> _selectedItems = [];
  String groupName = '';

  @override
  void initState() {
    super.initState();
    getContactPermission();
    _getAppUsers();
  }



  String getContactName(String phoneNumber) {
  for (var contact in contacts) {
    if (contact.phones != null && contact.phones!.isNotEmpty) {
      var contactPhoneNumber = contact.phones![0].value!;
      if (contactPhoneNumber == phoneNumber) {
        return contact.givenName ?? '';
      }
    }
  }
  return '';
}

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(Contact itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
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
    for (var element in _appUsers) {
      if (element.contains(string1) && phoneNumber1 != MyPhone.phoneNumber) {
        return true;
      }
    }
    return false;
  }

  String generateRoomID() {
    return DateTime.now().millisecondsSinceEpoch.toString();
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
                var roomId = generateRoomID();
                print('Creating room $roomId');
                final created = DateTime.now().millisecondsSinceEpoch;
                String receiverId = contact.phones![0].value!.toString().replaceAll(' ', '');
                await FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .set({
                  'created': created,
                  'sender': MyPhone.phoneNumber,
                  'type': "peer",
                  'receiver': receiverId,
                  'members': '',
                });
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
    final List<Contact> items = [];
    for (var element in contacts) {
      if (comparePhoneNumbers(element.phones![0].value!.toString())) {
        finalContacts.add(element);
        items.add(element);
      }
    }
    //final List<Contact> items = finalContacts;
    return Scaffold(
      appBar: AppBar(
        // Add an app bar with a "Create Group Chat" button
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            // When pressed, show a dialog to create a group chat
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return MultiSelect(items: finalContacts);
                },
              );
            },
          ),
        ],
      ),
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

class MultiSelect extends StatefulWidget {
  final List<Contact> items;
  final roomId;
  const MultiSelect({Key? key, required this.items, this.roomId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<Contact> _selectedItems = [];
  final TextEditingController _groupNameController = TextEditingController();

  String generateRoomID() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(Contact itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() async {
    var roomId = generateRoomID();
    print('Creating room $roomId');
    final created = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).set({
      'created': created,
      'sender': MyPhone.phoneNumber,
      'type': "group",
      'receiver': '',
      'groupName': _groupNameController.text, // Added groupName field
      'members':
          _selectedItems.map((e) => e.phones![0].value!.toString()).toList()
    });
    Navigator.pop(context, _selectedItems);
  }
  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contacts'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
              ),
            ),
            const SizedBox(height: 16),
                      ...widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item.givenName!),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
            ],
          

        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
