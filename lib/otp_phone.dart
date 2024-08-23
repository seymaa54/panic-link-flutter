import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/home_page.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key, required this.verificationId, required this.onVerified}) : super(key: key);
  final String verificationId;
  final VoidCallback onVerified;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Telefonunuza bir doğrulama kodu gönderdik. Lütfen doğrulayın",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                fillColor: Colors.grey.withOpacity(0.25),
                filled: true,
                hintText: "Doğrulama Kodunu Girin",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  final cred = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: otpController.text,

                  );
                  print(otpController.text);
                  await FirebaseAuth.instance.signInWithCredential(cred);

                  widget.onVerified();
                } catch (e) {
                  log(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("OTP doğrulama başarısız."),
                    ),
                  );
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text(
                "Doğrula",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}