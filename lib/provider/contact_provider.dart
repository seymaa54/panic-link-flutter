import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:panic_link/model/contact_model.dart'; // Contact modelinizi buraya göre düzenleyin

class ContactProvider with ChangeNotifier {
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  String _userId = '';
  List<Contact> _contacts = [];

  ContactProvider(this._userId) {
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
      var newContactRef = _database.child('users').child(_userId).child('contacts').push();
      newContact.contactId = newContactRef.key!; // Firebase'den otomatik olarak oluşturulan ID'yi al
      await newContactRef.set(newContact.toMap()); // Contact'i Firebase'e kaydet

      // Başarılı eklemeyi bildirelim
      print(
          'Yeni contact eklendi: ${newContact.firstName} ${newContact.lastName}');
    } catch (error) {
      // Hata durumunda bildirim yapalım
      print('Contact eklenirken hata oluştu: $error');
    }
  }

  // Contact silmek için metot
  Future<void> deleteContact(String contactId) async {
    try {
      // Firebase'de contact düğümünden belirtilen contact'ı silelim
      await _database
          .child('users')
          .child(_userId)
          .child('contacts')
          .child(contactId)
          .remove();

      // Başarılı silmeyi bildirelim
      print('Contact silindi: $contactId');
    } catch (error) {
      // Hata durumunda bildirim yapalım
      print('Contact silinirken hata oluştu: $error');
    }
  }

  // Contact güncellemek için metot (opsiyonel olarak kullanılabilir)
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
