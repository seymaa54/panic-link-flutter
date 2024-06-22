import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/contact_form.dart';
import 'package:panic_link/model/contact_model.dart';
import 'package:panic_link/provider/contact_provider.dart';
import 'package:provider/provider.dart';

import 'home_page_alt.dart';
import 'my_profile_page.dart'; // Assuming Contact model is imported

class MyContacts extends StatefulWidget {
  static const String routeName = '/myContacts';

  const MyContacts({Key? key}) : super(key: key);

  @override
  State<MyContacts> createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Contact> _contacts = []; // List to hold contacts
  late FirebaseAuth _auth;
  User? _currentUser;
  late DatabaseReference _database;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _currentUser = _auth.currentUser;
    _database = FirebaseDatabase.instance.reference();
    _loadContacts();
  }

  void _loadContacts() {
    if (_currentUser != null) {
      _database
          .child('users')
          .child(_currentUser!.uid)
          .child('contacts')
          .get()
          .then((DataSnapshot dataSnapshot) {
        dynamic data = dataSnapshot.value;

        print('mycontacts: Contacts Data: $data'); // Veriyi debug etmek için ekleyin

        if (data != null && data.isNotEmpty) {
          setState(() {
            _contacts = (data as Map).values.map((contactData) {
              print('Contact Data: $contactData'); // Debug için ekleyin
              return Contact.fromMap(Map<String, dynamic>.from(contactData));
            }).toList();
          });
        } else {
          setState(() {
            _contacts = [];
          });
        }

        print('Parsed Contacts: $_contacts'); // Kontakların işlenmiş halini debug için ekleyin
      }).catchError((error) {
        print('Veriler alınırken hata oluştu: $error');
      });
    }
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to ContactForm with pre-filled data for editing
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactForm(contact: contact),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Sil'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteContact(contact);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteContact(Contact contact) async {
    try {
      // Firebase'de contact düğümünden belirtilen contact'ı silelim
      await _database
          .child('users')
          .child(_currentUser!.uid)
          .child('contacts')
          .child(contact.contactId.toString())
          .remove();

      // Veriyi hemen güncellemek için setState içinde _contacts'u güncelleyin
      setState(() {
        _contacts.remove(contact);
      });

      // Silme işlemi başarılı olduğunda kullanıcıya bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${contact.firstName} ${contact.lastName} silindi.'),
          action: SnackBarAction(
            label: 'Geri Al',
            onPressed: () {
              // Geri alındığında kişiyi tekrar ekle
              setState(() {
                _contacts.add(contact);
              });
            },
          ),
        ),
      );
    } catch (error) {
      // Hata durumunda bildirim yap
      print('Contact silinirken hata oluştu: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme işlemi sırasında bir hata oluştu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);

    return GestureDetector(
      onTap: () {
        // Close keyboard or handle tap events
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 19.0),
            child: Text(
              'Kişilerim',
              style: TextStyle(
                fontFamily: 'Lexend',
                color: Colors.black87,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 16, 12, 0),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, ContactForm.routeName);
                },
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.black38,
                  size: 35,
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(
                          0,
                          1,
                        ),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 12),
                        child: Text(
                          'Aşağıdan kişilerinizi yönetin.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${contact.firstName} ${contact.lastName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              contact.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _showOptions(context, contact);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Kişiler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Hesabım',
            ),
          ],
          currentIndex: 0, // Adjust as needed based on your current index logic
          selectedItemColor: Colors.blue,
          onTap: (_selectedIndex) {
            if (_selectedIndex == 0) {
              Navigator.pushNamed(context, MyContacts.routeName);
            } else if (_selectedIndex == 1) {
              Navigator.pushNamed(context, HomePageAlt.routeName);
            } else if (_selectedIndex == 2) {
              Navigator.pushNamed(context, MyProfilePage.routeName);
              //pushreplacemtvsdds
            }
          },
        ),
      ),
    );
  }
}
