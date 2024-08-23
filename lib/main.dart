import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/connect_device.dart';
import 'package:panic_link/contact_form.dart';
import 'package:panic_link/my_profile_page.dart';
import 'package:panic_link/provider/bluetooth_service_provider.dart';
import 'package:panic_link/provider/contact_provider.dart'; // ContactProvider importu
import 'package:panic_link/device_status.dart';
import 'package:panic_link/edit_profile.dart';
import 'package:panic_link/forgot_password.dart';
import 'package:panic_link/home_page.dart';
import 'package:panic_link/auth/login_page.dart';
import 'package:panic_link/my_contacts.dart';
import 'package:panic_link/privacyPolicy.dart';
import 'package:panic_link/provider/device_provider.dart';
import 'package:panic_link/provider/help_request_provider.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:panic_link/real_time_tracking.dart';
import 'package:panic_link/auth/register_account.dart';
import 'package:panic_link/scan_device.dart';
import 'package:panic_link/auth/verificationEmail.dart';
import 'package:provider/provider.dart';
import 'change_password.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /*
  LayoutBuilder ve OrientationBuilder: Cihazın ekran boyutlarını ve yönünü algılamak için kullanılır.
   Bu yapı taşları, uygulamanızın responsive tasarımını cihazın ekran boyutlarına göre otomatik olarak ayarlamak için kullanılır.
MediaQuery: constraints.maxWidth ve constraints.maxHeight kullanarak cihazın gerçek ekran boyutlarını alır
ScreenUtilInit: Alınan ekran boyutlarını designSize olarak kullanır ve uygulamanın tüm widget'larının bu boyutlara göre dinamik hale gelmesini sağlar.
   */
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            Size screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            return ScreenUtilInit(
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => UserProvider(),
                    ),
                    ChangeNotifierProxyProvider<UserProvider, ContactProvider>(
                      create: (context) => ContactProvider(''),
                      update: (context, userProvider, contactProvider) =>
                          contactProvider!
                            ..updateUserId(userProvider.currentUser?.uid ?? ''),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => BluetoothServiceProvider(),
                    ),
                    ChangeNotifierProxyProvider<UserProvider, HelpRequestProvider>(
                      create: (context) => HelpRequestProvider(Provider.of<UserProvider>(context, listen: false),
                        context,
                      ),
                      update: (context, userProvider, previous) {
                        return previous ??
                            HelpRequestProvider(userProvider, context);
                      },
                    ),
                    // DeviceProvider'ı ekleyelim
                    ChangeNotifierProxyProvider<UserProvider, DeviceProvider>(
                      create: (context) => DeviceProvider(
                        Provider.of<UserProvider>(context, listen: false).userId,
                        Provider.of<BluetoothServiceProvider>(context, listen: false),
                      ),
                      update: (context, userProvider, previous) {
                        // Eğer previous var ve kullanıcı ID'si değişmemişse, aynı DeviceProvider'ı kullan
                        if (previous != null && previous.userId == userProvider.userId) {
                          return previous;
                        }

                        // Kullanıcı değişmişse yeni bir DeviceProvider oluştur
                        return DeviceProvider(
                          userProvider.userId,
                          Provider.of<BluetoothServiceProvider>(context, listen: false),
                        );
                      },
                    ),                  ],
                  child: MaterialApp(
                    initialRoute: '/',
                    routes: {
                      '/': (context) => LoginPage(),
                      ChangePassword.routeName: (context) => const ChangePassword(),
                      ConnectDevice.routeName: (context) => const ConnectDevice(),
                      ContactForm.routeName: (context) => const ContactForm(),
                      DeviceStatus.routeName: (context) => const DeviceStatus(),
                      EditProfile.routeName: (context) => const EditProfile(),
                      ForgotPassword.routeName: (context) => const ForgotPassword(),
                      HomePageAlt.routeName: (context) => const HomePageAlt(),
                      MyProfilePage.routeName: (context) => MyProfilePage(),
                      LoginPage.routeName: (context) => const LoginPage(),
                      MyContacts.routeName: (context) => const MyContacts(),
                      PrivacyPolicy.routeName: (context) => const PrivacyPolicy(),
                      RealTimeTracking.routeName: (context) => const RealTimeTracking(),
                      RegisterAccount.routeName: (context) => const RegisterAccount(),
                      ScanDevice.routeName: (context) => const ScanDevice(),
                      VerificationEmail.routeName: (context) => const VerificationEmail(),
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
