class Contact {
  String? contactId;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;

  Contact({
    this.contactId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      contactId: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': contactId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
