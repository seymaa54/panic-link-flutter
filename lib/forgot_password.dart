import 'package:flutter/material.dart';

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
  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Şifre değiştir',
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          'Hesabınızla ilişkili e-postayı girin. Size bir doğrulama kodu göndereceğiz.',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: TextFormField(
                    controller: emailAddressTextController,
                    focusNode: emailAddressFocusNode,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    validator: validateEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your functionality here
                      print('Button-Login pressed ...');
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
