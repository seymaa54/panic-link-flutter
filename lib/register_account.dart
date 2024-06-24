import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/complete_profile.dart';
import 'package:panic_link/login_page.dart';
import 'package:panic_link/privacyPolicy.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:panic_link/verificationEmail.dart';

class RegisterAccount extends StatefulWidget {
  static const String routeName = '/registerAccount';

  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final _formKey = GlobalKey<FormState>();

  final emailAddressLoginFocusNode = FocusNode();
  final passwordLoginFocusNode = FocusNode();

  final confirmPasswordLoginFocusNode = FocusNode();



  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool passwordCreateVisibility = false;
  bool passwordConfirmVisibility = false;
  bool privacyPolicyChecked = false;
  late User? _currentUser;


  @override
  void dispose() {
    emailAddressLoginFocusNode.dispose();
    passwordLoginFocusNode.dispose();
    confirmPasswordLoginFocusNode.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
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
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }
  Future<void> registerNewUser(BuildContext context) async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        throw "Parolalar Eşleşmiyor!";
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _currentUser = userCredential.user;

      // Doğrulama e-postasını gönder
      await _currentUser!.sendEmailVerification();

      // Kullanıcı e-postasını doğrulayana kadar bekleyin
      await _currentUser!.reload();
      if (_currentUser!.emailVerified) {
        // Firebase Realtime Database'e kullanıcı bilgilerini kaydetme
        DatabaseReference usersRef = FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(_currentUser!.uid);

        Map<String, dynamic> userDataMap = {
          "userId": _currentUser!.uid,
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "name": '',
          "surname": '',
          "identityNumber": '',
          "phone": '',
          "contacts": '',
          "deviceId": '',
          "identityNumber": '',
          "helpCalls": '',


        };

        usersRef.set(userDataMap);

        // CompleteProfile sayfasına yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfile(userId: _currentUser!.uid),
          ),
        );
      } else {
        // E-posta doğrulanmamışsa, kullanıcıyı doğrulama ekranına yönlendirme gerekli
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationEmail(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image:
                          AssetImage('assets/images/createAccount_bg@2x.png'),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 13, 10, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset(
                                  'assets/images/780e0e64d323aad2cdd5.png',
                                  width: 170,
                                  height: 95,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(-1, -1),
                                ),
                                Text(
                                  'Panic Link',
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'Başlamak İçin',
                                    style: TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 2, 0, 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Aşağıda hesabınızı oluşturun.',
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 1, 0, 0),
                                        child: TextFormField(
                                          controller: _emailController,
                                          focusNode: emailAddressLoginFocusNode,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'E-posta Adresi',
                                            hintText: 'E-postanızı giriniz...',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor:
                                                Theme.of(context).cardColor,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 24),
                                          ),
                                          validator: validateEmail,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 9, 0, 0),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          focusNode: passwordLoginFocusNode,
                                          obscureText:
                                              !passwordCreateVisibility,
                                          decoration: InputDecoration(
                                            labelText: 'Şifre',
                                            hintText: 'Şifrenizi giriniz...',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor:
                                                Theme.of(context).cardColor,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 24),
                                            suffixIcon: InkWell(
                                              onTap: () => setState(
                                                () => passwordCreateVisibility =
                                                    !passwordCreateVisibility,
                                              ),
                                              focusNode: FocusNode(
                                                  skipTraversal: true),
                                              child: Icon(
                                                passwordCreateVisibility
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 9, 0, 0),
                                        child: TextFormField(
                                          controller:_confirmPasswordController,
                                          focusNode: confirmPasswordLoginFocusNode,
                                          obscureText:
                                              !passwordConfirmVisibility,
                                          decoration: InputDecoration(
                                            labelText: 'Şifreyi Onayla',
                                            hintText: 'Şifrenizi giriniz...',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor:
                                                Theme.of(context).cardColor,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 24),
                                            suffixIcon: InkWell(
                                              onTap: () => setState(
                                                () => passwordConfirmVisibility =
                                                    !passwordConfirmVisibility,
                                              ),
                                              focusNode: FocusNode(
                                                  skipTraversal: true),
                                              child: Icon(
                                                passwordConfirmVisibility
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: privacyPolicyChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          privacyPolicyChecked = value!;
                                        });
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, PrivacyPolicy.routeName);
                                      },
                                      child: Text(
                                        'Gizlilik Sözleşmesini Okudum ve Onaylıyorum',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      if (privacyPolicyChecked) {
                                        if (_passwordController.text !=
                                            _confirmPasswordController.text) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Şifreler eşleşmiyor.'),
                                            ),
                                          );
                                        } else {
                                          //Fdssa
                                          registerNewUser(context);
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Lütfen koşulları kabul edin.'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Hesap Oluştur',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size(140, 40),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(60, 1, 0, 0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        Navigator.pushNamed(
                                            context, LoginPage.routeName);
                                      },
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Giriş',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontFamily: 'Lexend',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0, right: 8),
                                                child: Icon(
                                                  Icons.arrow_back,
                                                  color: Color(0xFF1A1F24),
                                                  size: 24,
                                                ),
                                              ),
                                              Text(
                                                'Zaten hesabınız mı var?',
                                                style: TextStyle(
                                                  fontFamily: 'Lexend',
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
        ),
      ),
    );
  }
}
