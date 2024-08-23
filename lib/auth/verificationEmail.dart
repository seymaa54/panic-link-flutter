import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:panic_link/wrapper.dart';

class VerificationEmail extends StatefulWidget {
  static const String routeName = '/verificationEmail';

  const VerificationEmail({Key? key}) : super(key: key);

  @override
  _VerificationEmailState createState() => _VerificationEmailState();
}

class _VerificationEmailState extends State<VerificationEmail> {
  final _auth = UserProvider();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _auth.sendEmailVerificationLink();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Wrapper(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor: Color(0xFFEEF1F5); // Hex kodunu burada kullanıyoruz

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Doğrulama için bir e-posta gönderdik. Eğer e-postayı almadıysanız, doğrulama e-postasını yeniden göndermek için aşağıdaki butona tıklayın veya spam klasörünüzü kontrol edin.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {},
              child: Text(
                'E-postayı yeniden gönder',
                style: TextStyle(
                  fontFamily: 'Lexend',
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(240, 50),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
