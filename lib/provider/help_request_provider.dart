import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:panic_link/model/contact_model.dart';
import 'package:panic_link/model/help_request_model.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';
import 'contact_provider.dart'; // Contact modelinizi buraya göre düzenleyin

class HelpRequestProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final UserProvider _userProvider; // UserProvider'ı ekleyin

  String? _firstName;
  String? _lastName;
  String? _phone;
  BuildContext? _context;

  HelpRequestProvider(this._userProvider, this._context);

  Future<void> sendHelpRequest(BuildContext context) async {
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    List<Contact> contacts = contactProvider.contacts;
    UserModel? currentUser = _userProvider.userData;

    // UserModel'dan kullanıcı bilgilerini al
    _firstName = currentUser?.name;
    _lastName = currentUser?.surname;
    _phone = currentUser?.phone;

    print('Kişi listesi: $contacts');

    if (contacts.isEmpty) {
      print('Kişi listesi boş');
      return;
    }

    print('Yardım çağrısı metotu çağrıldı');
    DateTime now = DateTime.now();
    final subject = 'Panic Link Yardım Çağrısı';
    final body = 'Panic Link uygulamasından $_firstName $_lastName adlı kullanıcı sizin için yardım çağrısı yapıyor! '
        'İletişim için telefon numarası: $_phone.';

    final emailRecipients = contacts.map((contact) => contact.email).toList();
    final phoneRecipients = contacts.map((contact) => contact.phoneNumber).toList();

    bool emailSent = false;
    bool smsSent = false;

    final Email email = Email(
      body: body,
      subject: subject,
      recipients: emailRecipients,
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
      emailSent = true;
    } catch (error) {
      print('Yardım çağrısı email gönderilirken hata oluştu: $error');
    }

    try {
      for (String phone in phoneRecipients) {
        var result = await BackgroundSms.sendMessage(
          phoneNumber: phone,
          message: body,
          simSlot: 1,
        );

        if (result == SmsStatus.sent) {
          smsSent = true;
          print("SMS başarıyla gönderildi: $phone");
        } else {
          print('Yardım çağrısı SMS gönderilirken hata oluştu: $phone');
        }
      }
    } catch (error) {
      print('Yardım çağrısı SMS gönderilirken hata oluştu: $error');
    }

    if (context != null) {
      if (emailSent && smsSent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Yardım çağrısı kişilerinize email ve SMS olarak gönderildi')));
      } else if (emailSent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Yardım çağrısı kişilerinize email olarak gönderildi')));
      } else if (smsSent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Yardım çağrısı kişilerinize SMS olarak gönderildi')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Yardım çağrısı gönderilirken hata oluştu')));
      }
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    if (_userProvider.currentUser != null) {
      await addHelpCall(now);
    } else {
      print('Mevcut kullanıcı doğrulanamadı, HelpCall eklenmedi');
    }
  }

  Future<void> addHelpCall(DateTime timestamp) async {
    try {
      HelpCall newHelpCall = HelpCall(timestamp: timestamp);

      var newHelpCallRef = _database
          .child('users')
          .child(_userProvider.currentUser!.uid)
          .child('helpCalls')
          .push();
      newHelpCall.callId = newHelpCallRef.key!;
      await newHelpCallRef.set(newHelpCall.toMap());

      print('Yeni HelpCall eklendi: ${newHelpCall.callId}');
    } catch (error) {
      print('HelpCall eklenirken hata oluştu: $error');
    }
  }
}
