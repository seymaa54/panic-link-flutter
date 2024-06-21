import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/contact_form.dart';
import 'package:panic_link/device_status.dart';
import 'package:panic_link/gloabal_var.dart';
import 'package:panic_link/my_contacts.dart';
import 'package:panic_link/my_profile_page.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:panic_link/real_time_tracking.dart';
import 'package:provider/provider.dart';

import 'model/contact_model.dart';
import 'model/user_model.dart';

class HomePageAlt extends StatefulWidget {
  static const String routeName = '/homePageAlt';

  const HomePageAlt({super.key});

  @override
  State<HomePageAlt> createState() => _HomePageAltState();
}

class _HomePageAltState extends State<HomePageAlt>
    with TickerProviderStateMixin {
  /*
  ettiniz. final FirebaseAuth _auth = FirebaseAuth.instance; ifadesi,
   Firebase Authentication servisini kullanarak uygulamada oturum açmış
    olan kullanıcı bilgilerini yönetmek için gereklidir. Bu ifade,
    Firebase'in auth paketinden FirebaseAuth sınıfını kullanarak, oturum açma, kayıt olma, oturumu kapatma gibi kimlik doğrulama işlemlerini yönetmek için Firebase ile bağlantı sağlar.
   */
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  User? _currentUser;
  List<Contact> _contacts = []; // List to hold contacts
  bool _isAlertShown = false; // Flag to track if alert dialog is shown
// Kullanıcının contacts listesi

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('kullanıcı null değil');
      print(_currentUser?.email);
      _loadContacts();
    }
  }
  void _loadContacts() {
    // Önce var olan dinleyiciyi kaldıralım
    _database.child('users')
        .child(_currentUser!.uid)
        .child('contacts')
        .get()
        .then((DataSnapshot dataSnapshot) {
    dynamic data = dataSnapshot.value;

      print('Contacts Data: $data'); // Veriyi debug etmek için ekleyin

    if (data != null && data.isNotEmpty) {
    setState(() {
    _contacts = (data as Map).values.map((contactData) {
    print('Contact Data: $contactData'); // Debug için ekleyin
    return Contact.fromMap(Map<String, dynamic>.from(contactData));
    }).toList();
    });

        // Eğer kişi listesi boşsa alert dialogu kaldıralım
        _isAlertShown = false;
      } else {
        setState(() {
          _contacts = [];
        });

        // Eğer kişi listesi boş ise ve alert daha önce gösterilmediyse showDialog çağır
        if (!_isAlertShown) {
          _isAlertShown = true; // Alert gösterildiğini işaretle
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Kişi Listesi Boş'),
                content: Text('Kişi eklemek için devam etmek istiyor musunuz?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('İptal'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _isAlertShown = false; // Alert kapatıldı, bayrağı sıfırla
                    },
                  ),
                  TextButton(
                    child: Text('Devam Et'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, ContactForm.routeName);
                      _isAlertShown = false; // Alert kapatıldı, bayrağı sıfırla
                    },
                  ),
                ],
              );
            },
          );
        }
      }

      print('LOAD Parsed Contacts: $_contacts'); // Kontakların işlenmiş halini debug için ekleyin
    }, onError: (error) {
      print('Veriler alınırken hata oluştu: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          currentIndex: _selectedIndex,
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
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child:  Consumer<UserProvider>(
            builder: (context, userProvider, _) {      // Kullanıcı verilerini al
              UserModel? userData = userProvider.userData;
              return Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 8, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 25.0, top: 12.3),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child:userData != null && userData.profileImageUrl != null
                                                ? Image.network(
                                              userData.profileImageUrl!,
                                              fit: BoxFit.cover,
                                            )
                                                : Image.asset(
                                              'assets/images/user.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                userData != null
                                                    ? 'Merhaba, ${userData.name}'
                                                    : 'Merhaba',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'Lexend',
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                0, 4, 0, 0),
                                            child: Text(
                                              'Cihaz bağlantısını yönetin ve kontrol edin.',
                                              maxLines: 3,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Lexend',
                                                fontSize: 14,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white54,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Color(0x34000000),
                                        offset: Offset(0.0, -2),
                                      )
                                    ],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20, 6, 20, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              'Hızlı servis',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 12, 16, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 105,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white60,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Builder(
                                                builder: (context) => InkWell(
                                                  splashColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                          EdgeInsets.zero,
                                                          backgroundColor:
                                                          Colors.transparent,
                                                          alignment:
                                                          AlignmentDirectional(
                                                              0, 0)
                                                              .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                          child: Container(
                                                            height: 400,
                                                            width: 400,
                                                          ),
                                                        );
                                                      },
                                                    ).then(
                                                            (value) => setState(() {}));
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.swap_horiz_rounded,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                        Padding(
                                                          padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 8, 0, 0),
                                                          child: Text(
                                                            'Transfer',
                                                            style: TextStyle(
                                                              fontFamily: 'Lexend',
                                                              letterSpacing: 0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white60,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () async {
                                                  Navigator.pushNamed(context,
                                                      RealTimeTracking.routeName);
                                                },
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .stacked_line_chart_rounded,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .fromSTEB(0, 8, 0, 0),
                                                      child: Text(
                                                        'Anlık İzleme',
                                                        style: TextStyle(
                                                          fontFamily: 'Lexend',
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 110,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white60,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () async {
                                                  Navigator.pushNamed(context,
                                                      DeviceStatus.routeName);
                                                },
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.settings,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .fromSTEB(0, 8, 0, 0),
                                                      child: Text(
                                                        'Cihaz Ayarları',
                                                        style: TextStyle(
                                                          fontFamily: 'Lexend',
                                                          letterSpacing: 0,
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
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Card(
                                              child: Container(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor:
                                                        Colors.transparent,
                                                        focusColor:
                                                        Colors.transparent,
                                                        hoverColor:
                                                        Colors.transparent,
                                                        highlightColor:
                                                        Colors.transparent,
                                                        onTap: () async {},
                                                        child: Container(
                                                          height: 420,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white60,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                8),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize.max,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Container(
                                                                width: 260,
                                                                height: 260,
                                                                decoration:
                                                                BoxDecoration(
                                                                  shape:
                                                                  BoxShape.circle,
                                                                  gradient:
                                                                  LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xFF00968A), // İlk renk
                                                                      Color(
                                                                          0xFFF2A384), // İkinci renk
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .bluetooth_connected,
                                                                    color: Colors
                                                                        .white, // İkon rengi
                                                                    size: 90,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(0,
                                                                    8, 0, 60),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 28),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ));
  }
}
