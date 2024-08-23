import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panic_link/provider/contact_provider.dart';
import 'package:panic_link/model/contact_model.dart'; // Contact modelinizi buraya göre düzenleyin

class ContactForm extends StatefulWidget {
  static const String routeName = '/contactForm';
  final Contact? contact;
  const ContactForm({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late FirebaseAuth _auth;
  late User? _currentUser;
  late String _cId; // Burada ContactForm'a ait bir id alanı tanımlanmalıdır.


  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _currentUser = _auth.currentUser;
    _cId = widget.contact?.contactId ?? ''; // Burada mevcut contact'ın id'si alınır

    // Initialize the form with the contact data if it's provided
    if (widget.contact != null) {
      _nameController.text = widget.contact!.firstName;
      _surnameController.text = widget.contact!.lastName;
      _phoneController.text = widget.contact!.phoneNumber;
      _emailController.text = widget.contact!.email;
    } else {
      // +90 Türkiye kodu ile başlat
      _phoneController.text = '+90';
    }
    _phoneController.addListener(() {
      if (!_phoneController.text.startsWith('+90')) {
        _phoneController.text = '+90';
        _phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: _phoneController.text.length));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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


  //contactmodel kullanılarak newcontact nesensi oluşturulır.
  //bu nesne  contactproviderın addcontact metdouyla mecvut kulalnıcnun contact listesine firebasede kaydedilir
  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      // Form geçerli, verileri alalım
      String firstName = _nameController.text.trim();
      String lastName = _surnameController.text.trim();
      String phoneNumber = _phoneController.text.trim();
      String email = _emailController.text.trim();

      // Yeni Contact oluşturalım
      Contact newContact = Contact(
        contactId: widget.contact != null ? widget.contact!.contactId : _cId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      ContactProvider contactProvider = ContactProvider(_currentUser!.uid);

      // Eğer düzenleme modundayızsa, contactId'yi aktar
      if (widget.contact != null) {
        // updateContact metodunu çağır
        await contactProvider.updateContact(_cId, newContact);
      } else {
        // Yeni bir kişi ekleniyor, saveContact metodunu çağır
        await contactProvider.addContact(newContact);
      }

      // İşlem tamamlandıktan sonra formu temizleyelim
      _nameController.clear();
      _surnameController.clear();
      _phoneController.clear();
      _emailController.clear();

      // İşlem tamamlandıktan sonra SnackBar göstermek için mounted kontrolü yapalım
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.contact != null ? 'Kişi başarıyla güncellendi' : 'Yeni kişi başarıyla eklendi')),
        );
      }

      // Formu kaydettikten sonra mevcut sayfayı kapatıp önceki sayfaya dön
      Navigator.pop(context, true); // true, "My Contacts" sayfasında güncelleme yapmak için bir işarettir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey,
            size: 32,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 19),
                              child: Text(
                                widget.contact != null ? 'Düzenle' : 'Kişi Ekle',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                return 'Lütfen soyadınızı giriniz';
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen telefon numarası giriniz';
                              }
                              if (!RegExp(r'^\+90[0-9]{10}$').hasMatch(value)) {
                                return 'Telefon Numarası Geçersiz';
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
                          padding: EdgeInsets.only(top: 50),
                          child: ElevatedButton(
                            onPressed: _saveContact,
                            child: Text('Kaydet'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}