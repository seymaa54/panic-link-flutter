import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:panic_link/model/user_model.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:provider/provider.dart'; // Contact modelinizi buraya göre düzenleyin

class EditProfile extends StatefulWidget {
  static const String routeName = '/editProfile';
  final UserModel? user;

  const EditProfile({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PhoneNumber number = PhoneNumber(isoCode: 'TR');
  String initialCountry = 'TR';
  late ImagePicker picker;
  File? _imageFile;
  String? _profileImageUrl;
  late FirebaseAuth _auth;
  late User? _currentUser;
  late DatabaseReference databaseReference;


  void _pickImage(ImageSource source) async {
    final pickedImage = await picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        _profileImageUrl = null;
      }
    });
  }
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _surnameFocusNode = FocusNode();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _surnameFocusNode.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _currentUser = _auth.currentUser;

    databaseReference = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.user!.userId);
    // Verileri temizle
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _imageFile = null;
    _profileImageUrl = null;

    // ImagePicker'ı başlat
    picker = ImagePicker();

    if (_currentUser != null) {
      // Yeni kullanıcı bilgilerini yükle
      _nameController.text = widget.user?.name ?? '';
      _surnameController.text = widget.user?.surname ?? '';
      _phoneController.text = widget.user?.phone ?? '';
      _emailController.text = widget.user?.email ?? '';
      _profileImageUrl = widget.user?.profileImageUrl;
    } else {
      _phoneController.text = '+90';
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen e-posta adresinizi girin';
    }
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-posta adresiniz hatalı';
    }
    return null;
  }

  String getButtonText() {
    if (_profileImageUrl != null && _imageFile == null) {
      return 'Fotoğraf Değiştir';
    } else {
      return 'Fotoğraf Ekle';
    }
  }

  Future<void> _reauthenticateUser(String password) async {
    try {
      // Mevcut kullanıcıyı alın
      User? user = _auth.currentUser;

      // Kimlik doğrulama bilgilerini oluşturun
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      // Kullanıcıyı yeniden kimlik doğrulama
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      print("Reauthentication failed: $e");
      throw e;
    }
  }

  Future<void> _updateUserProfile(String password) async {
    try {
      String? downloadUrl;

      if (_imageFile != null) {
        final String fileName = '${widget.user!.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);

        final uploadTask = storageReference.putFile(_imageFile!);
        downloadUrl = await (await uploadTask).ref.getDownloadURL();
      }

      // Kullanıcı verilerini güncelle
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(widget.user!.userId);

      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileImageUrl': downloadUrl ?? _profileImageUrl,
      };

      if (downloadUrl != null) {
        userData['profileImageUrl'] = downloadUrl;
      }

      await userRef.update(userData);

      // Firebase Authentication'da e-posta güncelleme
      if (_currentUser != null) {
        // Kullanıcıyı yeniden kimlik doğrulama
        await _reauthenticateUser(password);

        // E-posta adresini güncelle
        await _currentUser!.updateEmail(_emailController.text.trim());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Değişiklikler başarıyla kaydedildi."),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Değişiklikler kaydedilirken bir hata oluştu: $e"),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.grey[600],
              size: 32,
            ),
          ),
          title: Text(
            'Profili Düzenle',
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Lexend',
                letterSpacing: 0,
                color: Colors.black54),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Container(
                    // Kullanıcı profil resmi gösterme alanı
                    child: _imageFile != null
                        ? ClipOval(
                      child: Image.file(
                        File(_imageFile!.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : (_profileImageUrl != null
                        ? ClipOval(
                      child: Image.network(
                        _profileImageUrl!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error),
                      ),
                    )
                        : ClipOval(
                      child: Image.asset(
                        'assets/images/user.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: ElevatedButton(
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
                    child: Text(
                      getButtonText(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        letterSpacing: 0,
                      ),
                    ),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          letterSpacing: 0,
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      side: MaterialStateProperty.all(
                        BorderSide(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Ad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen adınızı giriniz';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(
                              labelText: 'Soyad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen adınızı giriniz';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Telefon',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(20),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  13), // +90 ve 10 rakam sınırlaması için
                              FilteringTextInputFormatter.deny(RegExp(
                                  r'[^\+0-9]')), // Sadece +, 0-9 rakamları geçerli
                            ],
                            onTap: () {
                              if (!_phoneController.text.startsWith('+90')) {
                                // Eğer metin +90 ile başlamıyorsa, başına +90 ekleyelim
                                _phoneController.text = '+90';
                              }
                            },
                            onChanged: (value) {
                              if (!_phoneController.text.startsWith('+90')) {
                                // Kullanıcı metni sildiğinde veya değiştirdiğinde, başına +90 ekleyelim
                                _phoneController.text = '+90';
                              }
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 12) {
                                return 'Lütfen geçerli bir telefon numarası giriniz';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'E-posta',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(20),
                            ),
                            validator: validateEmail,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _updateUserProfile(widget.user!.password.toString());
                              }
                            },
                            child: Text('Değişiklikleri Kaydet'),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )));
  }
}
