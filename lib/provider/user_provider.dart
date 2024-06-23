import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:panic_link/model/user_model.dart';
import 'package:panic_link/model/device_model.dart';

import '../model/contact_model.dart';
import '../HelpCall.dart';

/*
ChangeNotifier sınıfından türediği için, bu sınıf içinde kullanıcı verilerini dinlemek
 ve güncellemek için gerekli mekanizmaları sağlayabilirsiniz.
 */
class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _userRef;
  UserModel? _userData;
  DeviceModel? _deviceData;

  UserProvider() {
    // Firebase Authentication'dan gelen oturum durumu değişikliklerini dinlemek için bir dinleyici ekler.
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Firebase veritabanında, kullanıcının UID'sini kullanarak kullanıcı düğümüne (node) referans alınır.
        _userRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid);

        // Kullanıcının verileri değiştiğinde veya herhangi bir güncelleme olduğunda bu dinleyici tetiklenir.
        _userRef.onValue.listen((event) {
          // Handle null snapshot value gracefully
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            // Alınan veriyi kullanıcı modeline uygun şekilde işleyerek bir nesne oluşturur.
            _userData =
                UserModel.fromMap(Map<String, dynamic>.from(data as Map));
          } else {
            print("userdata model oluşmadı");
            _userData = null; // Veriler null ise kullanıcı verisini sıfırla
          }
          notifyListeners();
        });
      } else {
        _userData = null; // Kullanıcı çıkış yapmışsa kullanıcı verisini sıfırla
        notifyListeners();
      }
    });
  }
  UserModel? get userData => _userData;

  DeviceModel? get deviceData => _deviceData;

  /*Future<void> registerUser(String email, String password, String name,
      String surname,String identityNumber, String phone) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      _userRef =
          FirebaseDatabase.instance.reference().child('users').child(user.uid);
      _userData = UserModel(
        userId: user.uid,
        name: name,
        surname: surname,
        email: email,
        password: password,
        identityNumber:identityNumber,
        phone: phone,
        profileImageUrl: '',
        contacts: [],
        deviceId: null,
        // Kullanıcı henüz bir cihaza bağlı değil
        helpCalls: [], // Boş yardım çağrıları listesi
      );
      await _userRef.set(_userData!.toMap());
      notifyListeners();
    }
  }*/

  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getUserDataAfterSignIn(String email, String password) async {
    try {
      // Kullanıcıyı giriş yapmaya çalış await ise bir işlemin tamamlanmasını beklemek için
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Kullanıcının verilerini almak için kullanıcı durumunu dinle
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          // Kullanıcı giriş yaptıktan sonra kullanıcı verilerini al
          _userRef = FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(user.uid);
          /*
         DataSnapshot nesnesi, veritabanından alınan veriyi temsil eder.
         snapshot.value ile verinin var olup olmadığı kontrol edilir.
         Eğer veri varsa, UserModel.fromMap metodunu kullanarak snapshot.value'yi UserModel nesnesine dönüştürürüz.
         */
          _userRef.once().then((DataSnapshot snapshot) {
                if (snapshot.value != null) {
                  _userData = UserModel.fromMap(Map<String, dynamic>.from(
                      snapshot.value as Map<String, dynamic>));
                  notifyListeners();
                } else {
                  print("Kullanıcı verileri bulunamadı.");
                }
              } as FutureOr Function(DatabaseEvent value));
        }
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bildirim göster
      print(e);
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
// Giriş başarılı olduğunda, kullanıcı verilerini almak için bir metod çağırın
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await readData(userId);
    } catch (e) {
// Hata durumunda uygun bir şekilde işleyin
      print("Giriş başarısız: $e");
      throw e; // Hata durumunu yukarıya iletmek için yeniden fırlatın
    }
  }

  Future<void> readData(String userId) async {
    DatabaseReference databaseReference;

    try {
      // 'users' düğümüne referans oluştur
      databaseReference =
          FirebaseDatabase.instance.reference().child('users').child(userId);

      // Dinleyici ekle
      databaseReference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        dynamic data = dataSnapshot.value;
        print('DataSnapshot JSON: ${dataSnapshot.value}');

        if (data != null && data is Map<dynamic, dynamic>) {
          // Map<dynamic, dynamic> türündeki veriyi Map<String, dynamic> türüne dönüştür
          Map<String, dynamic> values = Map<String, dynamic>.from(data);

          try {
            // Veriyi UserModel.fromMap ile UserModel'e dönüştür
            UserModel user = UserModel.fromMap(values);

            print('User ID: ${user.userId}');
            print('Name: ${user.name} (Type: ${user.name.runtimeType})');
            print('Surname: ${user.surname}');
            print('Email: ${user.email}(Type: ${user.email.runtimeType})');
            print('Phone: ${user.phone}');
            print('Identity Number: ${user.identityNumber}');
            print('Profile Image URL: ${user.profileImageUrl}');

            // _userData'ya atama yapabilirsiniz
            _userData = user;
          } catch (e) {
            print('UserModel oluşturma hatası: $e');
            _userData = null;
          }
        } else {
          print('Veri alınamadı veya uygun formatta değil.');
          _userData = null;
        }

        // Değişiklikleri dinleyicilere bildir
        notifyListeners();
      });
    } catch (e) {
      print("Veri okuma başarısız: $e");
      throw e;
    }
  }

  //bu kısımda olmuyor
  void updateUserData(Map<String, dynamic> newData) {
    if (_userData != null) {
      _userData!.name = newData['name'] ?? _userData!.name;
      _userData!.surname = newData['surname'] ?? _userData!.surname;
      _userData!.email = newData['email'] ?? _userData!.email;
      _userData!.phone = newData['phone'] ?? _userData!.phone;
      _userData!.profileImageUrl =
          newData['profileImage'] ?? _userData!.profileImageUrl;

      // Firebase veritabanında güncelleme yap
      _userRef.update(_userData!.toMap());
      notifyListeners();
    }
  }

  Future<void> deleteUser() async {
    await _userRef.remove();
    // Kullanıcı verilerini yerel olarak da temizle
    _userData = null;
    _deviceData = null; // Cihaz verilerini temizle
    notifyListeners();
    //update den sonra fetch user datauyı çağıarbilrisn
  }

  void addDevice(DeviceModel device) {
    if (_userData!.deviceId == null) {
      final deviceRef =
          FirebaseDatabase.instance.reference().child('devices').push();
      deviceRef.set(device.toMap()).then((_) {
        _userData!.deviceId =
            deviceRef.key; // Yeni cihazın ID'sini kullanıcıya atayın
        _userRef.update({'deviceId': _userData!.deviceId});
        notifyListeners();
      });
    } else {
      print('Kullanıcı zaten bir cihaza sahip.');
    }
  }

  void _fetchDevices() async {
    if (_userData != null && _userData!.deviceId != null) {
      final deviceRef = FirebaseDatabase.instance
          .reference()
          .child('devices')
          .child(_userData!.deviceId!);
      DataSnapshot snapshot = (await deviceRef.once()) as DataSnapshot;
      // Check for null value before processing
      if (snapshot.value != null) {
        _deviceData =
            DeviceModel.fromMap(snapshot.value as Map<String, dynamic>);
        notifyListeners();
      }
    }
  }
/* void addHelpCall(HelpCall helpCall) {
      _userData!.helpCalls.add(helpCall);
      _userRef.child('helpCalls').push().set(helpCall.toMap());
      notifyListeners();
    }
    List<HelpCall> getHelpCalls() {
      return _userData!.helpCalls;
    }*/
}
