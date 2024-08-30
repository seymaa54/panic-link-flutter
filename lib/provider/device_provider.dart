import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/model/device_model.dart';
import 'package:panic_link/provider/bluetooth_service_provider.dart';

class DeviceProvider with ChangeNotifier {
  DatabaseReference _deviceRef = FirebaseDatabase.instance.ref();
  Device? _device;
  String _userId = '';
  BluetoothServiceProvider _bluetoothServiceProvider;

  String get userId => _userId;
  Device? get device => _device;
  bool _hasPromptedForPinCode = false; // Kullanıcıya PIN kodu alert'ini yalnızca bir kez göstermek için


  DeviceProvider(this._userId, this._bluetoothServiceProvider) {
    print('DeviceProvider başlatıldı: $_userId');
    _bluetoothServiceProvider.addListener(_onBluetoothStateChanged);
    print('BluetoothServiceProvider dinleniyor.');
  }

  // Kullanıcı kimliğini güncellemek ve Firebase'deki cihaz verilerini yüklemek
  void updateUserId(String userId) {
    _userId = userId;
    _deviceRef = FirebaseDatabase.instance.ref().child('users').child(_userId);
    print('Kullanıcı ID güncellendi: $_userId');
    loadDevice();
  }

  // Firebase Realtime Database'deki cihaz verilerini dinler
  void loadDevice() {
    print('loadDevice çağrıldı. Verileri dinlemeye başlıyoruz.');

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Kullanıcı ID\'si bulunamadı.');
      return;
    }

    final deviceRef = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(userId)
        .child('device');

    deviceRef.onValue.listen((event) {
      final dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null && dataSnapshot.value is Map) {
        final deviceData = dataSnapshot.value as Map<dynamic, dynamic>;

        _device = Device.fromMap(Map<String, dynamic>.from(deviceData));
        print('Cihaz verileri güncellendi: ${_device?.toMap()}');
      } else {
        _device = null;
        print('Cihaz verisi bulunamadı.');
      }

      notifyListeners();
    });
  }

  // Cihaz bilgilerini Firebase'e günceller
// Firebase cihazı günceller
  Future<void> updateDevice(bool isConnected) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Mevcut kullanıcının ID'sini al
      if (userId == null) {
        throw Exception("Kullanıcı ID'si bulunamadı.");
      }

      await _deviceRef.child('users').child(userId).child('device').update({
        'isConnected': isConnected,
      });
      print('Cihaz bağlantı durumu başarıyla güncellendi.');
    } catch (error) {
      print('Firebase\'e veri güncelleme hatası: $error');
    }
  }

// Bağlantı durumunu günceller
  void updateConnectionStatus(bool isConnected) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('Kullanıcı ID\'si bulunamadı.');
      return;
    }

    // Firebase'deki cihaz verisini kontrol etmek için referansı alın
    final deviceRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('device');

    try {
      // Cihazın mevcut olup olmadığını kontrol edin
      final snapshot = await deviceRef.get();

      if (snapshot.exists) {
        // Cihaz mevcutsa güncellenmiş cihazı Firebase'e kaydedin
        final deviceData = snapshot.value as Map<dynamic, dynamic>;
        Device currentDevice = Device.fromMap(Map<String, dynamic>.from(deviceData));

        Device updatedDevice = currentDevice.copyWith(isConnected: isConnected);

        // Güncellenmiş cihazı Firebase'e kaydedin
        await deviceRef.update(updatedDevice.toMap());

        _device = updatedDevice;
        notifyListeners(); // Dinleyicilere bildir
        print('Cihaz bağlantı durumu başarıyla güncellendi: $isConnected');
      } else {
        print('Cihaz mevcut değil.');
      }
    } catch (error) {
      print('Firebase\'de veri okuma veya güncelleme hatası: $error');
    }
  }

// Bluetooth bağlantı durumunu dinler
  void _onBluetoothStateChanged() {
    // Bluetooth durum değiştiğinde yapılacak işlemler
    bool isConnected = _bluetoothServiceProvider.isConnected;
    updateConnectionStatus(isConnected);
  }

  // Cihazı Firebase'e ekler
  Future<void> addDevice(Device device) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Kullanıcı ID'si bulunamadı.");
      }

      final db = FirebaseDatabase.instance.reference()
          .child('users')
          .child(userId)
          .child('device');

      // Otomatik ID oluşturma
      final deviceId = db.push().key;

      // Cihazın ID'sini ekleyin
      device.deviceId = deviceId;

      await db.set(device.toMap());
      print('Cihaz bilgileri başarıyla kaydedildi: ${device.deviceName}');
    } catch (error) {
      print('Firebase\'e veri kaydetme hatası: $error');
    }
  }


  // Pin kodunu günceller
  Future<void> fetchDevice(String deviceId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('Kullanıcı ID\'si bulunamadı.');
        return;
      }

      DatabaseReference deviceRef = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(userId)
          .child('device')
          .child(deviceId);

      DatabaseEvent event = await deviceRef.once();

      if (event.snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _device = Device.fromMap(data);
        notifyListeners();
        print('Cihaz bilgileri başarıyla alındı: ${_device?.toMap()}');
      } else {
        print('Cihaz bulunamadı.');
      }
    } catch (e) {
      print('Cihaz bilgileri alınırken bir hata oluştu: $e');
    }
  }

  Future<void> changePinCode(String deviceId, String currentPinCode, String newPinCode) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('Kullanıcı ID\'si bulunamadı.');
        return;
      }

      DatabaseReference deviceRef = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(userId)
          .child('device')
          .child(deviceId);

      // Mevcut PIN kodunu al
      DatabaseEvent event = await deviceRef.once();
      final deviceData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (deviceData == null) {
        print('Cihaz bilgisi bulunamadı.');
        return;
      }

      final existingPinCode = deviceData['pinCode'] as String?;

      if (existingPinCode != currentPinCode) {
        print('Mevcut PIN kodu yanlış.');
        return;
      }

      // Yeni PIN kodunu güncelle
      await deviceRef.update({'pinCode': newPinCode});

      if (_device != null) {
        _device = _device!.copyWith(pinCode: newPinCode);
        notifyListeners();
        print('PIN kodu başarıyla güncellendi: $newPinCode');
      }
    } catch (e) {
      print('PIN kodu güncellenirken bir hata oluştu: $e');
    }
  }
  // Cihazın bilgilerini ekrana yazdırır
  void viewDeviceInfo() {
    if (_device != null) {
      print('Device ID: ${_device!.deviceId}');
      print('Device Name: ${_device!.deviceName}');
      print('PIN Code: ${_device!.pinCode}');
    } else {
      print('Device not found!');
    }
  }

  // Cihazı Firebase'den kaldırır
  void removeDevice() {
    if (_device != null) {
      print('Cihaz bilgileri Firebase\'den kaldırılıyor.');
      _deviceRef.child('device').remove().then((_) {
        print('Cihaz bilgileri başarıyla kaldırıldı.');
      }).catchError((error) {
        print('Firebase\'den veri kaldırma hatası: $error');
      });
    } else {
      print('Cihaz bilgileri mevcut değil.');
    }
  }


  Future<String?> promptForPinCode(BuildContext context) async {
    String? pinCode;
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        TextEditingController pinController = TextEditingController();
        return AlertDialog(
          title: Text('PIN Kodu Gereklidir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PIN kodu, cihazınızın güvenliğini sağlamak ve yanlış alarm çağrılarını iptal edebilmek için gereklidir. Lütfen aşağıdaki alana PIN kodunuzu girin.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PIN Kodunuz',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (pinController.text.isNotEmpty) {
                  pinCode = pinController.text;
                  Navigator.of(context).pop(pinCode);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lütfen geçerli bir PIN kodu girin.'),
                    ),
                  );
                }
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    ).then((value) {
      print("Dialog closed with value: $value"); // Debug için
    });
    return pinCode;
  }
  @override
  void dispose() {
    print('DeviceProvider dispose ediliyor.');
    _bluetoothServiceProvider.removeListener(_onBluetoothStateChanged);
    super.dispose();
  }
}
