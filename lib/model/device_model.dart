class Device {
  String? deviceId;
  String? deviceName;
  bool isConnected;
  String? pinCode;

  Device({
    this.deviceId,
    this.deviceName,
    this.pinCode,
    this.isConnected = false,
  });

  Device copyWith({
    String? deviceId,
    String? deviceName,
    bool? isConnected,
    String? pinCode,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      isConnected: isConnected ?? this.isConnected,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      pinCode: map['pinCode'],
      isConnected: map['isConnected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'pinCode': pinCode,
      'isConnected': isConnected,
    };
  }
}
