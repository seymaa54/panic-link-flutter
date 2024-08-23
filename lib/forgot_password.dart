import 'package:flutter/material.dart';
import 'package:panic_link/provider/user_provider.dart';

class ForgotPassword extends StatefulWidget {
  static const String routeName = '/forgotPassword';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController emailAddressTextController = TextEditingController();
  final FocusNode emailAddressFocusNode = FocusNode();
  final _auth = UserProvider();

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

  Future<void> sendPasswordResetLink() async {
    try {
      await _auth.sendPasswordResetEmail(email:emailAddressTextController.text);

      // Eğer başarılıysa, bir mesaj göster ve login sayfasına yönlendir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'),
        ),
      );

      // Login sayfasına yönlendirme
      Navigator.of(context).pushReplacementNamed('/loginPage');
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Şifre sıfırlama bağlantısı gönderilirken bir hata oluştu.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFEEF1F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF1F5),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey,
            size: 32,
          ),
        ),
        title: const Text(
          '',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 24,
            letterSpacing: 0,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          'Hesabınızla ilişkili e-postayı girin. Size bir şifre sıfırlama bağlantısı göndereceğiz.',
                          style: TextStyle(
                            color: Colors.black45,
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: TextFormField(
                    controller: emailAddressTextController,
                    focusNode: emailAddressFocusNode,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'E-posta Adresi',
                      hintText: 'E-postanızı giriniz...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      contentPadding: EdgeInsetsDirectional.fromSTEB(10, 20, 10, 16),
                    ),
                    validator: validateEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (validateEmail(emailAddressTextController.text) == null) {
                        await sendPasswordResetLink();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Geçerli bir e-posta adresi giriniz.')),
                        );
                      }
                    },
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
                    child: const Text(
                      'Sıfırlama Bağlantısı Gönder',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
