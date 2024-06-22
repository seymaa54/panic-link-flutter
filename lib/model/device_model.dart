class DeviceModel {
  String deviceId;
  String deviceName;
  String userId; // Kullanıcı ID'sini saklamak için
  String pinCode;

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.userId,
    required this.pinCode,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> data) {
    return DeviceModel(
      deviceId: data['deviceId'],
      deviceName: data['deviceName'],
      userId: data['userId'],
      pinCode: data['pinCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'userId': userId,
      'pinCode': pinCode,
    };
  }
}
