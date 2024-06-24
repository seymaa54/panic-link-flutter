import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:panic_link/login_page.dart';
import 'package:panic_link/main.dart';
import 'package:panic_link/otp_phone.dart';
import 'package:panic_link/scan_device.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class CompleteProfile extends StatefulWidget {
  final String userId;

  CompleteProfile({required this.userId});
  static const String routeName = '/completeProfile';

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _telNumberController = TextEditingController();

  late DatabaseReference databaseReference;

  PhoneNumber number = PhoneNumber(isoCode: 'TR');
  String initialCountry = 'TR';

  late ImagePicker picker = ImagePicker();
  File? _imageFile;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _telNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // +90 Türkiye kodu ile başlat
    _telNumberController.text = '+90';
    picker = ImagePicker();
    databaseReference = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.userId);

    // TextField değişikliklerini dinleyin ve +90 ifadesini sabit tutun
    _telNumberController.addListener(() {
      if (!_telNumberController.text.startsWith('+90')) {
        _telNumberController.text = '+90';
        _telNumberController.selection = TextSelection.fromPosition(
            TextPosition(offset: _telNumberController.text.length));
      }
    });
  }

  //resim _imagefile değişk atanıyor
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _updateProfile() async {
    try {
      String? downloadUrl;

      if (_imageFile != null) {
        final String fileName =
            '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);

        final uploadTask = storageReference.putFile(File(_imageFile!.path));
        final snapshot = await uploadTask.whenComplete(() => null);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(widget.userId);
      Map<String, dynamic> userData = {
        'userId': widget.userId,
        'email': FirebaseAuth.instance.currentUser!.email,
        'name': _firstNameController.text.trim(),
        'surname': _lastNameController.text.trim(),
        'identityNumber': _idNumberController.text.trim(),
        'phone': _telNumberController.text.trim(),
        'profileImageUrl': downloadUrl ?? '',
        'contacts': '',
        'deviceId': '',
        'helpCalls': '',
      };

      if (downloadUrl != null) {
        userData['profileImageUrl'] = downloadUrl;
      }

      await userRef.update(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı başarıyla oluşturuldu."),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı oluşturma başarısız."),
        ),
      );
    }
  }

  Future<void> _verifyPhoneNumber() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _telNumberController.text.trim(),
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {
          log(error.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Telefon numarası doğrulama başarısız.1"),
            ),
          );
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
                onVerified: _updateProfile,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          log("Auto retrieval timeout");
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Telefon numarası doğrulama başarısız.2"),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profilini Tamamla',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 28,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageFile != null
                    ? Center(
                        child: ClipOval(
                          child: Image.file(
                            File(_imageFile!.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Center(child: Icon(Icons.person_add_alt_sharp)),
                        iconSize: 100,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Resim Seç"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Text("Galeriden Seç"),
                                        onTap: () {
                                          _pickImage(ImageSource.gallery);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(8.0)),
                                      GestureDetector(
                                        child: Text("Kameradan Çek"),
                                        onTap: () {
                                          _pickImage(ImageSource.camera);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                SizedBox(height: 16),
                Text(
                  'Sizi kolayca tanıyabilmemiz için bilgilerinizi giriniz.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'Ad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Soyad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(labelText: 'TC Kimlik Numarası'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen TC kimlik numaranızı giriniz';
                    }
                    if (value.length != 11) {
                      return 'TC Kimlik numaranız 11 haneden oluşmalıdır';
                    }
                    if (value.startsWith('0')) {
                      return 'Kimlik Numarası 0 ile başlayamaz';
                    }
                    int sum = 0;
                    for (int i = 0; i < 10; i++) {
                      sum += int.parse(value[i]);
                    }

                    int lastDigit = int.parse(value[10]);
                    if (sum % 10 != lastDigit) {
                      return 'Kimlik Numarası Hatalı';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  maxLength: 13,
                  controller: _telNumberController,
                  decoration: InputDecoration(labelText: 'Telefon Numarası'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen telefon numaranızı giriniz';
                    }
                    if (!RegExp(r'^\+90[0-9]{10}$').hasMatch(value)) {
                      return 'Telefon Numarası Geçersiz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(252, 50),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Form geçerli, işlemleri yapabilirsiniz
                        _verifyPhoneNumber();
                      }
                    },
                    child: Text('Gönder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
