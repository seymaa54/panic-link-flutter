import 'package:panic_link/model/contact_model.dart';
import 'package:panic_link/model/help_request_model.dart';
import 'package:panic_link/model/device_model.dart';

class UserModel {
  String userId;
  String? name;
  String? surname;
  String? email;
  String? password;
  String? identityNumber;
  String? phone;
  String? profileImageUrl;
  List<Contact>? contacts;
  Device? device;
  List<HelpCall>? helpCalls;

  UserModel({
    required this.userId,
    this.name,
    this.surname,
    this.email,
    this.password,
    this.identityNumber,
    this.phone,
    this.profileImageUrl,
    List<Contact>? contacts,
    this.device,
    List<HelpCall>? helpCalls,
  })  : contacts = contacts ?? [],
        helpCalls = helpCalls ?? [];

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      name: data['name'],
      surname: data['surname'],
      email: data['email'],
      password: data['password'],
      identityNumber: data['identityNumber'],
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      contacts: _parseContacts(data['contacts']),
      device: _parseDevice(data['device']), // _parseDevice metodu kullanılıyor
      helpCalls: _parseHelpCalls(data['helpCalls']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'identityNumber': identityNumber,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'contacts': contacts?.map((x) => x.toMap()).toList(),
      'device': device?.toMap(),
      'helpCalls': helpCalls?.map((x) => x.toMap()).toList(),
    };
  }

  static List<Contact>? _parseContacts(dynamic contactsData) {
    if (contactsData == null) return null;
    if (contactsData is List) {
      return contactsData.map((e) => Contact.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  static Device? _parseDevice(dynamic deviceData) {
    if (deviceData == null) return null;

    // Eğer gelen veri Map türündeyse, bunu Map<String, dynamic> türüne dönüştür
    if (deviceData is Map) {
      return Device.fromMap(Map<String, dynamic>.from(deviceData));
    } else {
      // Eğer gelen veri Map değilse, bu durumda veriyi işleyemeyiz, null döndür
      return null;
    }
  }


  static List<HelpCall>? _parseHelpCalls(dynamic helpCallsData) {
    if (helpCallsData == null) return null;
    if (helpCallsData is List) {
      return helpCallsData.map((e) => HelpCall.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }
}
