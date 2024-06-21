import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'forgot_password.dart';
import 'register_account.dart';
import 'home_page_alt.dart';
import 'package:panic_link/provider/user_provider.dart'; // UserProvider sınıfını içeri aktarın


class LoginPage extends StatefulWidget {
  static const String routeName = '/loginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  late UserProvider _userProvider; // _userProvider değişkenini tanımlayın

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false); // _userProvider'ı başlatın
  }

  final _formKey = GlobalKey<FormState>();

  final emailAddressLoginFocusNode = FocusNode();
  final passwordLoginFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool passwordCreateVisibility = false;
  final Connectivity _connectivity = Connectivity();

  final _auth = FirebaseAuth.instance;

  Future<void> checkIfNetworkIsAvailable() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Bağlantı Sorunu'),
          content: Text('İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.'),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      // Internet connection available
      signIn();
    }
  }

  void signIn() async {
    try {
      await _userProvider.loginUser(_emailController.text.trim(), _passwordController.text.trim());
      Navigator.pushNamed(context, HomePageAlt.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı Bulunamadı.'),
          duration: Duration(seconds: 2),
        ),
      );
      print(e);
    }
  }
  @override
  void dispose() {
    emailAddressLoginFocusNode.dispose();
    passwordLoginFocusNode.dispose();
    _emailController.dispose();
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi girin';
    }
    if (value.length < 6) {
      return 'Şifreniz en az 6 veya daha fazla karakterden oluşmalıdır';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/createAccount_bg@2x.png'),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/780e0e64d323aad2cdd5.png',
                      width: 170,
                      height: 95,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Panic Link',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 30,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 13, 28, 25),
                      child: Text(
                        'Hesabınıza erişmek için aşağıdaki alanları doldurun.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                fillColor: Theme.of(context).cardColor,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    20, 24, 20, 24),
                              ),
                              validator: validateEmail,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 9, 0, 0),
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: passwordLoginFocusNode,
                              obscureText: !passwordCreateVisibility,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                hintText: 'Şifrenizi giriniz...',
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
                                fillColor: Theme.of(context).cardColor,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    20, 24, 20, 24),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                        () => passwordCreateVisibility =
                                    !passwordCreateVisibility,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    passwordCreateVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: validatePassword,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, ForgotPassword.routeName);
                                  },
                                  child: Text(
                                    'Parolanızı mı unuttunuz?',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    _formKey.currentState?.save();
                                    checkIfNetworkIsAvailable();
                                  }
                                },
                                child: Text(
                                  'Giriş',
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(120, 50),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: InkWell(
                              onTap: () async {
                                Navigator.pushNamed(
                                    context, RegisterAccount.routeName);
                              },
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Hesabınız yok mu?',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Color(0xFF1A1F24),
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        'Oluştur',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontFamily: 'Lexend',
                                        ),
                                      ),
                                    ],
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
