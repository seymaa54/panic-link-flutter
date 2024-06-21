import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/complete_profile.dart';
import 'package:panic_link/connect_device.dart';
import 'package:panic_link/contact_form.dart';
import 'package:panic_link/provider/contact_provider.dart'; // ContactProvider importu
import 'package:panic_link/device_status.dart';
import 'package:panic_link/edit_profile.dart';
import 'package:panic_link/forgot_password.dart';
import 'package:panic_link/home_page_alt.dart';
import 'package:panic_link/login_page.dart';
import 'package:panic_link/my_contacts.dart';
import 'package:panic_link/privacyPolicy.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:panic_link/real_time_tracking.dart';
import 'package:panic_link/register_account.dart';
import 'package:panic_link/scan_device.dart';
import 'package:provider/provider.dart';
import 'change_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        if (currentUser != null)
          ChangeNotifierProvider(
            create: (context) => ContactProvider(currentUser.uid),
          ),
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(), // Ana sayfa route'u
          ChangePassword.routeName: (context) => const ChangePassword(),
          ConnectDevice.routeName: (context) => const ConnectDevice(),
          ContactForm.routeName: (context) => const ContactForm(),
          DeviceStatus.routeName: (context) => const DeviceStatus(),
          EditProfile.routeName: (context) => const EditProfile(),
          ForgotPassword.routeName: (context) => const ForgotPassword(),
          HomePageAlt.routeName: (context) => const HomePageAlt(),
          LoginPage.routeName: (context) => const LoginPage(),
          MyContacts.routeName: (context) => const MyContacts(),
          PrivacyPolicy.routeName: (context) => const PrivacyPolicy(),
          RealTimeTracking.routeName: (context) => const RealTimeTracking(),
          RegisterAccount.routeName: (context) => const RegisterAccount(),
          ScanDevice.routeName: (context) => const ScanDevice(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, LoginPage.routeName);
          },
          child: const Text('Şifreyi Değiştir'),
        ),
      ),
    );
  }
}
