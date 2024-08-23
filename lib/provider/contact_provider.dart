import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:panic_link/model/contact_model.dart'; // Contact modelinizi buraya göre düzenleyin

class ContactProvider with ChangeNotifier {
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  String _userId = '';
  List<Contact> _contacts = [];

  ContactProvider(this._userId);

  void updateUserId(String userId) {
    _userId = userId;
    // Yeni kullanıcı kimliği ile ilgili işlemleri burada yapın, örneğin:
    loadContacts();
  }

  void loadContacts() {
    _database
        .child('users')
        .child(_userId)
        .child('contacts')
        .onValue
        .listen((event) {
      var dataSnapshot = event.snapshot;
      var contactsData = dataSnapshot.value;

      if (contactsData != null) {
        if (contactsData is Map) {
          _contacts = contactsData.values.map((contactData) {
            return Contact.fromMap(Map<String, dynamic>.from(contactData));
          }).toList();
        } else if (contactsData is List) {
          _contacts = contactsData.map((contactData) {
            return Contact.fromMap(Map<String, dynamic>.from(contactData));
          }).toList();
        } else {
          _contacts = [];
        }
      } else {
        _contacts = [];
      }

      notifyListeners();
    });
  }

  List<Contact> get contacts => _contacts;

  // Yeni bir contact eklemek için metot
  Future<void> addContact(Contact newContact) async {
    try {
      // Firebase'de contact düğümüne yeni contact ekleyelim
      var newContactRef =
      _database.child('users').child(_userId).child('contacts').push();
      newContact.contactId = newContactRef
          .key!; // Firebase'den otomatik olarak oluşturulan ID'yi al
      await newContactRef
          .set(newContact.toMap()); // Contact'i Firebase'e kaydet

      // Başarılı eklemeyi bildirelim
      print(
          'Yeni contact eklendi: ${newContact.firstName} ${newContact.lastName}');
    } catch (error) {
      // Hata durumunda bildirim yapalım
      print('Contact eklenirken hata oluştu: $error');
    }
  }

  // Contact silmek için metot
  /* Future<void> deleteContact(Contact contact) async {
    try {
      if (contact.contactId != null) {
        await _database
            .child('users')
            .child(_userId)
            .child('contacts')
            .child(contact.contactId!)
            .remove();

        print('Contact silindi: ${contact.contactId}');
      } else {
        print('Contact ID null: Contact silinemedi');
      }
    } catch (error) {
      print('Contact silinirken hata oluştu: $error');
    }
  }*/
  Future<void> updateContact(String contactId, Contact updatedContact) async {
    try {
      // Firebase'de contact düğümünde belirtilen contact'ı güncelleyelim
      await _database
          .child('users')
          .child(_userId)
          .child('contacts')
          .child(contactId)
          .update(updatedContact.toMap());

      // Başarılı güncellemeyi bildirelim
      print(
          'Contact güncellendi: ${updatedContact.firstName} ${updatedContact.lastName}');
    } catch (error) {
      // Hata durumunda bildirim yapalım
      print('Contact güncellenirken hata oluştu: $error');
    }
  }
}
