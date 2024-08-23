import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/contact_form.dart';
import 'package:panic_link/device_status.dart';
import 'package:panic_link/my_contacts.dart';
import 'package:panic_link/my_profile_page.dart';
import 'package:panic_link/provider/bluetooth_service_provider.dart';
import 'package:panic_link/provider/contact_provider.dart';
import 'package:panic_link/provider/device_provider.dart';
import 'package:panic_link/provider/help_request_provider.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:panic_link/real_time_tracking.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'model/contact_model.dart';
import 'model/device_model.dart';
import 'model/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ekleyin

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

  late User? _currentUser;
  List<Contact> _contacts = []; // List to hold contacts
// Kullanıcının contacts listesi
  late Timer _timer;
  bool _showDialog = false;
  bool _buttonPressed = false;
  bool isConnected = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Kullanıcı bilgilerini tutacak değişkenler
  File? _selectedImage;
  int _selectedIndex = 1;

  bool _isAlertShown2 =
      false; // Alert dialogunun açık olup olmadığını kontrol etmek için bir değişken
  bool _isPinPromptShown =
      false; // Alert penceresinin gösterilip gösterilmediğini kontrol eden bir değişken

  late VoidCallback _bluetoothListener; // Listener callback referansı

  BluetoothServiceProvider? bluetoothService;
  DeviceProvider? deviceProvider;

  @override
  void initState() {
    super.initState();
    _requestSmsPermission();
    bluetoothService =
        Provider.of<BluetoothServiceProvider>(context, listen: false);
    _currentUser = _auth.currentUser;

    // Bluetooth'u başlat
    bluetoothService!.initBluetooth();

    // Cihazın bağlı olup olmadığını kontrol et
    // DeviceProvider'ı alın
    deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    // Cihazın bağlı olup olmadığını kontrol et
    if (bluetoothService?.isConnected == true) {
      print('Cihaz bağlı, DeviceProvider oluşturuluyor.');

      // Kullanıcı ID'sini güncelle
      deviceProvider!.updateUserId(_currentUser!.uid);

      // PIN kodu gerekli mi kontrol et
      _checkAndSaveDevice();
    } else {
      // Cihaz bağlı değilse, dinleyici ekle
      bluetoothService!.addListener(_checkAndSaveDevice);
    }
  }

  @override
  void dispose() {
    // Listener'ı kaldır
    bluetoothService?.removeListener(_checkAndSaveDevice);
    //   bluetoothService?.removeListener(_bluetoothListener);
    super.dispose();
  }

  Future<void> _requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }


  void _checkAndSaveDevice() async {
    if (bluetoothService!.isConnected) {

      // Debug için değerleri kontrol et
      print('Device: ${deviceProvider!.device}');
      print('Is PIN Prompt Shown: $_isPinPromptShown');

      if (_currentUser == null) {
        print('Kullanıcı bilgisi bulunamadı.');
        return;
      }

      // Kullanıcı ID'sini güncelle
      deviceProvider!.updateUserId(_currentUser!.uid);

      // Cihaz mevcut değilse ve PIN kodu penceresi henüz gösterilmediyse
      if (deviceProvider!.device == null && !_isPinPromptShown) {
        _isPinPromptShown = true;

        // Kullanıcıdan PIN kodunu iste
        String? pinCode = await deviceProvider!.promptForPinCode(context);
        if (pinCode != null) {
          // Yeni cihaz nesnesi oluştur
          var device = Device(
            deviceName: bluetoothService!.deviceName,
            pinCode: pinCode,
            isConnected: true,
          );

          // Cihazı Firebase'e ekle
          await deviceProvider!.addDevice(device);

          // Snackbar'ı widget'ın render edilmesinden sonra göster
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cihaz bilgileri kaydedildi.')),
              );
            }
          });

          // Dinlemeyi durdur
          bluetoothService!.removeListener(_checkAndSaveDevice);
        }
      } else {
        // Cihaz varsa veya PIN kodu penceresi zaten gösterildiyse
        print('Cihaz zaten mevcut veya PIN kodu penceresi zaten gösterildi.');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startTimer(BuildContext context) {
    const duration = Duration(minutes: 1);
    _timer = Timer(duration, () {
      if (_isAlertShown2) {
        print('Süre bitti');
        // Dialog açıkken yardım çağrısı yap
        _helpRequestCall();
        Navigator.of(context).pop(); // AlertDialog'u kapat
      }
    });
  }

  void _showAlert(BuildContext context) {
    if (!_isAlertShown2) {
      _isAlertShown2 = true; // Alert dialog açıldı olarak işaretlenir
      setState(() {
        _buttonPressed = true; // ElevatedButton rengini kırmızı yap
      });
      _startTimer(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        // Dışarı tıklamayla kapatmayı devre dışı bırak
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Yardım Çağrısı'),
            content: Text(
                'Yardım çağrısı göndermek üzeresiniz. İptal etmezseniz 2 dakika içinde yardım çağrısı gönderilecektir.'),
            actions: <Widget>[
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  _showPinCodeDialog(context); // PIN kodu doğrulama dialogunu göster
                },
              ),
              TextButton(
                child: Text('Devam Et'),
                onPressed: () {
                  _timer.cancel();
                  _helpRequestCall(); // Yardım çağrısını burada gönder
                  _isAlertShown2 =
                      false; // Alert dialog kapatıldı olarak işaretlenir
                  Navigator.of(context).pop(); // AlertDialog'u kapat
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showPinCodeDialog(BuildContext context) {
    String enteredPinCode = '';

    // DeviceProvider'ı context üzerinden alalım
   // final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PIN Kodu Doğrulama'),
          content: TextField(
            onChanged: (value) {
              enteredPinCode = value;
            },
            obscureText: true,
            // Girişin gizli olmasını sağlar (PIN için uygun)
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'PIN Kodunu Girin',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop(); // PIN dialogunu kapat
              },
            ),
            TextButton(
              child: Text('Onayla'),
              onPressed: () {
                if (deviceProvider!.device?.pinCode == enteredPinCode) {
                  // PIN kodu doğruysa
                  _timer.cancel();
                  setState(() {
                    _buttonPressed =
                        false; // İptal edildiğinde düğme rengi geri alınır
                  });
                  _isAlertShown2 =
                      false; // Alert dialog kapatıldı olarak işaretlenir

                  Navigator.of(context).pop(); // PIN dialogunu kapat
                  Navigator.of(context).pop(); // Ana AlertDialog'u kapat

                  // Yardım çağrısı iptal edildi mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Yardım çağrısı iptal edildi.'),
                    ),
                  );
                } else {
                  // PIN kodu yanlışsa
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Yanlış PIN kodu. Yardım çağrısını iptal edemediniz.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _helpRequestCall() async {
    print('helprequestCall metodu çağrıldı');
    Provider.of<HelpRequestProvider>(context, listen: false)
        .sendHelpRequest(context);
    setState(() {
      _buttonPressed = false;
      _showDialog = false;
    });
  }

  Future<void> _convertAndSendToBluetooth() async {
    if (_selectedImage == null) return;

    // getImageBytes fonksiyonunu kullanarak dosya yolundan List<int> verisini al
    List<int> imageBytes =
        await Provider.of<BluetoothServiceProvider>(context, listen: false)
            .getImageBytes(_selectedImage!.path);
    Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);

    img.Image? originalImage = img.decodeImage(uint8ImageBytes);
    if (originalImage == null) return;

    img.Image resizedImage =
        img.copyResize(originalImage, width: 240, height: 240);
    Uint8List gifBytes = Uint8List.fromList(img.encodeGif(resizedImage));

    // sendImage fonksiyonuna Uint8List türünde veri gönderiyoruz
    Provider.of<BluetoothServiceProvider>(context, listen: false)
        .sendImage(gifBytes);
  }

  Future<Uint8List> _convertTo240x240Gif(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      final resizedImage = img.copyResize(image, width: 240, height: 240);
      final gifBytes = img.encodeGif(resizedImage);
      return Uint8List.fromList(gifBytes);
    }
    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);
    backgroundColor:
    Color(0xFFEEF1F5);
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
      backgroundColor: Color(0xFFEEF1F5), // Hex kodunu burada kullanıyoruz
      body: Container(
        child: SafeArea(
          top: true,
          child: Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              // Kullanıcı verilerini al
              UserModel? userData = userProvider.userData;

              // Kullanıcı verileri yüklendikten sonra ContactProvider'ı sağlayıcıya ekleyin
              return userData != null
                  ? ChangeNotifierProvider(
                      create: (_) => ContactProvider(userData.userId),
                      child: Consumer<ContactProvider>(
                        builder: (context, contactProvider, _) {
                          List<Contact> contacts = contactProvider.contacts;
                          print("USER DATA");
                          print(userData.toString());
                          print(contacts);
                          return Stack(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.w, 8.h, 8.w, 0.h),
                                          // EdgeInsets ayarlarını güncelle
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 25.w,
                                                        top: 12.3.h),
                                                    // EdgeInsets ayarlarını güncelle
                                                    child: Container(
                                                      width: 60.w,
                                                      // Genişlik ekran boyutuna göre ayarlandı
                                                      height: 60.h,
                                                      // Yükseklik ekran boyutuna göre ayarlandı
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: userData != null &&
                                                              userData.profileImageUrl !=
                                                                  null
                                                          ? Image.network(
                                                              userData
                                                                  .profileImageUrl!,
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.w, 0.h, 0.w, 0.h),
                                                // EdgeInsets ayarlarını güncelle
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              // Genel metin rengi
                                                              fontFamily:
                                                                  'Lexend',
                                                              letterSpacing: 0,
                                                              fontSize: 18.sp,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'Merhaba, ',
                                                              ),
                                                              TextSpan(
                                                                text: userData !=
                                                                        null
                                                                    ? userData
                                                                        .name
                                                                    : '',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .blue, // Kullanıcının adını mavi yapıyoruz
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.w,
                                                                  4.h,
                                                                  0.w,
                                                                  0.h),
                                                      // EdgeInsets ayarlarını güncelle
                                                      child: Text(
                                                        'Cihaz bağlantısını yönetin ve kontrol edin.',
                                                        maxLines: 3,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'Lexend',
                                                          fontSize: 14.sp,
                                                          // Font boyutu ekran boyutuna göre ayarlandı
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
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.w, 24.h, 0.w, 0.h),
                                          // EdgeInsets ayarlarını güncelle
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // Genişlik ekran boyutuna göre ayarlandı
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
                                                topLeft: Radius.circular(16.r),
                                                // Border radius ekran boyutuna göre ayarlandı
                                                topRight: Radius.circular(16
                                                    .r), // Border radius ekran boyutuna göre ayarlandı
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.w, 6.h, 20.w, 0.h),
                                                  // EdgeInsets ayarlarını güncelle
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        'Hızlı servis',
                                                        style: TextStyle(
                                                          fontFamily: 'Lexend',
                                                          letterSpacing: 0,
                                                          fontSize: 16
                                                              .sp, // Font boyutu ekran boyutuna göre ayarlandı
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(16.w, 12.h,
                                                          16.w, 0.h),
                                                  // EdgeInsets ayarlarını güncelle
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 102.w,
                                                        // Genişlik ekran boyutuna göre ayarlandı
                                                        height: 100.h,
                                                        // Yükseklik ekran boyutuna göre ayarlandı
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white60,
                                                          borderRadius: BorderRadius
                                                              .circular(8
                                                                  .r), // Border radius ekran boyutuna göre ayarlandı
                                                        ),
                                                        child: Builder(
                                                          builder: (context) =>
                                                              InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              final ImagePicker
                                                                  _picker =
                                                                  ImagePicker();
                                                              final XFile?
                                                                  pickedFile =
                                                                  await _picker
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                              if (pickedFile !=
                                                                  null) {
                                                                setState(() {
                                                                  _selectedImage =
                                                                      File(pickedFile
                                                                          .path);
                                                                });

                                                                await _convertAndSendToBluetooth();
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 102.w,
                                                              // Genişlik ekran boyutuna göre ayarlandı
                                                              height: 100.h,
                                                              // Yükseklik ekran boyutuna göre ayarlandı
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .swap_horiz_rounded,
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 40
                                                                        .sp, // Icon boyutu ekran boyutuna göre ayarlandı
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.w,
                                                                            8.h,
                                                                            0.w,
                                                                            0.h),
                                                                    // EdgeInsets ayarlarını güncelle
                                                                    child: Text(
                                                                      'Transfer',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Lexend',
                                                                        letterSpacing:
                                                                            0,
                                                                        fontSize:
                                                                            14.sp, // Font boyutu ekran boyutuna göre ayarlandı
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
                                                        width: 102.w,
                                                        // Genişlik ekran boyutuna göre ayarlandı
                                                        height: 100.h,
                                                        // Yükseklik ekran boyutuna göre ayarlandı
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white60,
                                                          borderRadius: BorderRadius
                                                              .circular(8
                                                                  .r), // Border radius ekran boyutuna göre ayarlandı
                                                        ),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            Navigator.pushNamed(
                                                                context,
                                                                RealTimeTracking
                                                                    .routeName);
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .stacked_line_chart_rounded,
                                                                color:
                                                                    Colors.grey,
                                                                size: 40
                                                                    .sp, // Icon boyutu ekran boyutuna göre ayarlandı
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.w,
                                                                            8.h,
                                                                            0.w,
                                                                            0.h),
                                                                // EdgeInsets ayarlarını güncelle
                                                                child: Text(
                                                                  'Anlık İzleme',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lexend',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 14
                                                                        .sp, // Font boyutu ekran boyutuna göre ayarlandı
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 110.w,
                                                        // Genişlik ekran boyutuna göre ayarlandı
                                                        height: 100.h,
                                                        // Yükseklik ekran boyutuna göre ayarlandı
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white60,
                                                          borderRadius: BorderRadius
                                                              .circular(8
                                                                  .r), // Border radius ekran boyutuna göre ayarlandı
                                                        ),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            Navigator.pushNamed(
                                                                context,
                                                                DeviceStatus
                                                                    .routeName);
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.settings,
                                                                color:
                                                                    Colors.grey,
                                                                size: 40
                                                                    .sp, // Icon boyutu ekran boyutuna göre ayarlandı
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.w,
                                                                            8.h,
                                                                            0.w,
                                                                            0.h),
                                                                // EdgeInsets ayarlarını güncelle
                                                                child: Text(
                                                                  'Cihaz Ayarları',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lexend',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 14
                                                                        .sp, // Font boyutu ekran boyutuna göre ayarlandı
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
                                                Consumer<
                                                    BluetoothServiceProvider>(
                                                  builder: (context,
                                                      bluetoothService, child) {
                                                    isConnected =
                                                        bluetoothService
                                                            .isConnected;
                                                    bool isHelpMessageReceived =
                                                        bluetoothService
                                                                .receivedMessage
                                                                .toLowerCase() ==
                                                            'help';

                                                    if (isHelpMessageReceived) {
                                                      // Eğer yardım mesajı alındıysa, alert dialogu göster
                                                      WidgetsBinding.instance!
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        _showAlert(context);
                                                      });
                                                    }
                                                    if (isConnected) {
                                                      // Sadece bu kısımda DeviceProvider'a ihtiyacınız var
                                                      WidgetsBinding.instance!
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        // Consumer'ı burada kullanıyoruz
                                                        Consumer<
                                                            DeviceProvider>(
                                                          builder: (context,
                                                              deviceProvider,
                                                              child) {
                                                            _checkAndSaveDevice();
                                                            return SizedBox(); // Bu Consumer'ın kendi return widget'ı, boyutsuz bir widget kullanıyoruz
                                                          },
                                                        );
                                                      });
                                                    }

                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 5.h,
                                                          ),
                                                          child: Card(
                                                            child: Container(
                                                              width: 300.w,
                                                              height: 440.h,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {},
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            710.h,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white60,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.r),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.only(right: 208, bottom: 20),
                                                                              // Padding ayarlarını düzenleyin
                                                                              child: Card(
                                                                                color: isConnected ? Colors.green : Colors.red,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.all(7.w),
                                                                                  child: Text(
                                                                                    isConnected ? 'Cihaz Bağlı' : 'Cihaz Bağlı Değil',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 16.sp,
                                                                                    ),
                                                                                    textAlign: TextAlign.left,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(bottom: 28.0),
                                                                              child: Center(
                                                                                child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                    // Butona basıldığında yapılacak işlem belirtilmediği için boş bıraktım
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: isHelpMessageReceived ? Colors.red : Colors.blue,
                                                                                    shape: CircleBorder(),
                                                                                    padding: EdgeInsets.all(80.w),
                                                                                  ),
                                                                                  child: Icon(
                                                                                    Icons.bluetooth_connected,
                                                                                    color: Colors.white,
                                                                                    size: 95.sp,
                                                                                  ),
                                                                                ),
                                                                              ),
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
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Center(
                      child:
                          CircularProgressIndicator()); // Veriler yükleniyorsa, bir yükleme göstergesi göster
            },
          ),
        ),
      ),
    );
  }

//userprovidera almak istiyorum//
/*bunu kaldırabiliriz.çünkü userprovider da zaten kulnaıcı bilgileri
  alınıyor. buradaki firstname ksımları lazm ve load contacts metpsu
  kullanıcı bilgilieri helprequest sayfasında yine userproviderdan alabilirim
  loadv-contacts meetodunu da çağırabilirim yine
   */
/*void _getCurrentUser() {
    _currentUser = _auth.currentUser; // _currentUser'ı burada atıyoruz
    if (_currentUser != null) {
      _database
          .child('users')
          .child(_currentUser!.uid)
          .get()
          .then((DataSnapshot dataSnapshot) {
        dynamic data = dataSnapshot.value;
        if (data != null) {
          setState(() {
            _firstName = data['name'];
            _lastName = data['surname'];
            _email = data['email'];
            _phone = data['phone'];
          });
          print(_firstName);
          print(_lastName);

          print(_email);
          print(_phone);
        }
      }).catchError((error) {
        print('Kullanıcı bilgileri alınırken hata oluştu: $error');
      });

      _loadContacts();
    } else {
      print('Kullanıcı null');
    }
  }
*/
//contact providera gitsin
/* void _loadContacts() {
    // Önce var olan dinleyiciyi kaldıralım
    _database
        .child('users')
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

      print(
          'LOAD Parsed Contacts: $_contacts'); // Kontakların işlenmiş halini debug için ekleyin
    }, onError: (error) {
      print('Veriler alınırken hata oluştu: $error');
    });
  }*/
}
