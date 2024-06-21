import 'package:panic_link/model/contact_model.dart';
import 'package:panic_link/HelpCall.dart';

class UserModel {
  String userId;
  String? name; // Null olabilir
  String? surname; // Null olabilir
  String? email; // Null olabilir
  String? password; // Null olabilir
  String? identityNumber; // Null olabilir
  String? phone; // Null olabilir
  String? profileImageUrl; // Null olabilir
  List<Contact>? contacts; // Opsiyonel alan, null olabilir
  String? deviceId; // Null olabilir
  List<HelpCall>? helpCalls; // Opsiyonel alan, null olabilir

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
    this.deviceId,
    List<HelpCall>? helpCalls, // Liste olarak parametre olarak alındı
  })  : contacts = contacts ?? [], // Boş liste olarak başlatıldı
        helpCalls = helpCalls ?? []; // Boş liste olarak başlatıldı


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
      deviceId: data['deviceId'],
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
      'deviceId': deviceId,
      'helpCalls': helpCalls?.map((x) => x.toMap()).toList(),
    };
  }

  static List<Contact>? _parseContacts(dynamic contactsData) {
    if (contactsData == null) return null;
    if (contactsData is List && contactsData.isNotEmpty) {
      return contactsData.map((e) => Contact.fromMap(e)).toList();
    }
    return [];
  }

  static List<HelpCall>? _parseHelpCalls(dynamic helpCallsData) {
    if (helpCallsData == null) return null;
    if (helpCallsData is List && helpCallsData.isNotEmpty) {
      return helpCallsData.map((e) => HelpCall.fromMap(e)).toList();
    }
    return [];
  }
}
