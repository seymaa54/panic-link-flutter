import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panic_link/complete_profile.dart';
import 'package:panic_link/login_page.dart';  // Oturum açma sayfası
import 'package:panic_link/verificationEmail.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Veri beklenirken yükleme göstergesi gösterilir.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hata durumunda hata mesajı gösterilir.
          else if (snapshot.hasError) {
            return const Center(child: Text("Hata"));
          }
          else {
            // Kullanıcı oturum açmamışsa LoginPage gösterilir.
            if (snapshot.data == null) {
              return const LoginPage();  // Kullanıcı oturum açmamışsa LoginPage'e yönlendiriyoruz
            }
            else {
              // Kullanıcının e-posta doğrulaması kontrol edilir.
              if (snapshot.data!.emailVerified == true) {
                return CompleteProfile(userId: snapshot.data!.uid);  // E-posta doğrulandıysa profil tamamlama ekranı
              }
              // E-posta doğrulanmamışsa veya zorunlu değilse doğrudan CompleteProfile sayfasına yönlendirilir.
              // Bu durumu yönetmek istemiyorsanız, doğrulama ekranı (VerificationScreen) gösterilebilir.
              return VerificationEmail();  // E-posta doğrulanmadıysa veya yönlendirme seçeneği tercih edilmediyse doğrulama ekranı
            }
          }
        },
      ),
    );
  }
}
