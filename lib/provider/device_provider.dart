import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:panic_link/model/device_model.dart';

class DeviceProvider with ChangeNotifier {
  late DatabaseReference _deviceRef;
  DeviceModel? _device; // Tek bir cihaz için değişken tanımla

  DeviceProvider() {
    _deviceRef = FirebaseDatabase.instance.reference().child('devices');
    _deviceRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        // Veritabanından alınan cihaz verisiyle _device değişkenini güncelle
        Map<dynamic, dynamic>? values = event.snapshot.value as Map<dynamic, dynamic>?; // Tür dönüşümü yapılması
        if (values != null) {
          values.forEach((key, value) {
            _device = DeviceModel.fromMap(Map<String, dynamic>.from(value as Map<String, dynamic>)); // Daha güvenli bir dönüşüm yapılıyor
          });
        }
      } else {
        // Veritabanında cihaz verisi yoksa _device değişkenini null olarak ayarla
        _device = null;
      }
      notifyListeners();
    });

  }

  DeviceModel? get device => _device; // Tek bir cihazı getir

  void viewDeviceInfo() {
    // Burada cihazın bilgilerini görüntüleme işlemi gerçekleştirilebilir
    // Örneğin, cihazın modelini veya özelliklerini konsola yazdırabiliriz
    if (_device != null) {
      print('Device ID: ${_device!.deviceId}');
      print('Device Name: ${_device!.deviceName}');
      print('User ID: ${_device!.userId}');
      print('PIN Code: ${_device!.pinCode}');
    } else {
      print('Device not found!');
    }
  }

  // Diğer metotlar buraya eklenir...

  void removeDevice() {
    if (_device != null) {
      _deviceRef.child(_device!.deviceId).remove();
    }
  }

  void changePinCode(String newPinCode) {
    if (_device != null) {
      _deviceRef.child(_device!.deviceId).update({'pinCode': newPinCode});
    }
  }
}
