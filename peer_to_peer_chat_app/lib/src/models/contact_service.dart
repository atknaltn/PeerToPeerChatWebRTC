import 'package:contacts_service/contacts_service.dart';

class ContactService {
  static List<Contact>? allContacts;

  static Future<void> fetchContacts() async {
    allContacts = await ContactsService.getContacts();
  }
}