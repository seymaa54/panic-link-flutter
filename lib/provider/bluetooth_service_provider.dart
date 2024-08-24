import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hex/hex.dart';

class BluetoothServiceProvider with ChangeNotifier {
  BluetoothDevice? connectedDevice;
  List<BluetoothService> discoveredServices = [];
  StreamSubscription<BluetoothConnectionState>? connectionStateSubscription;
  Map<Guid, StreamSubscription<List<int>>?> characteristicValueSubscriptions = {};
  String _receivedMessage = ''; // Variable to store received message

  String _deviceName = ''; // Variable to store received message

  String get receivedMessage => _receivedMessage;
  bool _isHelpDialogShown = false;
  bool get isConnected => connectedDevice != null;

  String get deviceName => _deviceName;

  set receivedMessage(String value) {
    _receivedMessage = value;
    if (_receivedMessage.toLowerCase() == 'help') {
      triggerHelpAction();
    }
    notifyListeners();
  }

  VoidCallback? onHelpMessageReceived;

  void triggerHelpAction() {
    if (onHelpMessageReceived != null) {
      onHelpMessageReceived!(); // Callback'i çağır
    }
  }
  Future<void> initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    var initialState = await FlutterBluePlus.state;

    StreamSubscription<BluetoothAdapterState>? subscription;

    if (initialState == BluetoothAdapterState.on) {
      startScan();
    } else {
      subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.on) {
          startScan();
          subscription?.cancel();
        }
      });
    }

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> startScan() async {
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      for (var result in results) {
        if (result.device.advName== "BLE-Secure-Server") {
          connectToDevice(result.device);
          _deviceName=result.device.advName;
          return;
        }
      }
    }, onError: (e) => print(e));

    await FlutterBluePlus.startScan(
      withServices: [],
      withNames: [],
      timeout: Duration(seconds: 15),
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: true, mtu: null);

    await device.connectionState.where((val) => val == BluetoothConnectionState.connected).first;

    connectedDevice = device;
    notifyListeners();

    await discoverServices(device);
    subscribeToConnectionState(device);


    if (Platform.isAndroid) {
      await device.requestMtu(200);
    }
    //burayı değiştirdim
   /* if (isConnected && Platform.isAndroid) {
      try {
        await device.requestMtu(200);
        print('MTU isteği başarıyla gönderildi.');
      } catch (e) {
        print('MTU isteği sırasında hata oluştu: $e');
      }
    } else {
      print('Cihaz bağlı değil veya platform Android değil.');
    }*/


  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    discoveredServices = services;
    notifyListeners();

    print("Discovered Services:");
    for (var service in services) {
      print("Service: ${service.uuid}");
      for (var characteristic in service.characteristics) {
        print("- Characteristic: ${characteristic.uuid}");
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true); // Bildirimleri aç
          characteristicValueSubscriptions[characteristic.uuid] = characteristic.value.listen((value) {
            receivedMessage = String.fromCharCodes(value);
            notifyListeners();
            print('Gelen mesaj: $receivedMessage');
          });
        }
      }
    }
  }



  void subscribeToConnectionState(BluetoothDevice device) {
    connectionStateSubscription = device.state.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.disconnected) {
        connectedDevice = null;
        discoveredServices.clear();
        characteristicValueSubscriptions.values.forEach((subscription) {
          subscription?.cancel();
        });
        characteristicValueSubscriptions.clear();
        notifyListeners(); // Notify listeners on disconnect
      } else if (state == BluetoothConnectionState.connected) {
        connectedDevice = device;
        notifyListeners(); // Notify listeners on reconnect
      }
    });
  }

  Future<List<int>> getImageBytes(String imagePath) async {
    File imageFile = File(imagePath);
    Uint8List imageData = await imageFile.readAsBytes();
    return imageData;
  }

  Future<void> sendImage(Uint8List imageData) async {
    try {
      print('Image data length: ${imageData.length}');
      for (int i = 0; i < 10 && i < imageData.length; i++) {
        print('Image data byte $i: ${imageData[i]}');
      }
    } catch (e) {
      print('Error loading image bytes: $e');
      return;
    }

    for (var service in discoveredServices) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == "47524f89-07c8-43b6-bf06-a21c77bfdee8") {
          int chunkSize = c.device.mtuNow - 3;
          for (int i = 0; i < imageData.length; i += chunkSize) {
            List<int> subImageData = imageData.sublist(i, min(i + chunkSize, imageData.length));
            await c.write(subImageData, withoutResponse: false, timeout: 15000); // 15 saniye = 15000 milisaniye
          }
        }
      }
    }

    await stopTransfer();
  }
  Future<void> stopListening() async {
    for (var service in discoveredServices) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(false); // Bildirimleri kapat
        }
      }
    }

    for (var subscription in characteristicValueSubscriptions.values) {
      await subscription?.cancel();
    }
    characteristicValueSubscriptions.clear();
  }

  Future<void> startListening() async {
    for (var service in discoveredServices) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true); // Bildirimleri tekrar aç
          characteristicValueSubscriptions[characteristic.uuid] = characteristic.value.listen((value) {
            receivedMessage = String.fromCharCodes(value);
            notifyListeners();
            print('Gelen mesaj: $receivedMessage');
          });
        }
      }
    }
  }

  Future<void> stopTransfer() async {
    List<int> blankData = [];
    for (var service in discoveredServices) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == "47524f89-07c8-43b6-bf06-a21c77bfdee8") {
          await c.write(blankData);
        }
      }
    }
  }
}
