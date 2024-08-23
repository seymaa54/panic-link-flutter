import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panic_link/provider/user_provider.dart';

class ChangePassword extends StatefulWidget {
  static const String routeName = '/changePassword';
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool currentPasswordVisibility = false;
  bool newPasswordVisibility = false;
  bool confirmPasswordVisibility = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi girin';
    }
    if (value.length < 6) {
      return 'Şifreniz en az 6 karakterden oluşmalıdır';
    }
    return null;
  }

  Future<void> _updatePassword() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Şifrelerin doğrulanması
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifreler eşleşmiyor')),
      );
      return;
    }

    // Mevcut şifrenin doğrulanması
    final isPasswordCorrect = await userProvider.validateCurrentPassword(
        currentPassword);
    if (!isPasswordCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mevcut şifre hatalı')),
      );
      return;
    }


    final success = await userProvider.updateUserPassword(newPassword);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre başarıyla güncellendi')),
        );
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context); // 1 saniye sonra sayfayı kapat
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre güncellenirken bir hata oluştu'),
          ),
        );
      }
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
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
            'Şifre Değiştir',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 24,
              letterSpacing: 0,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: 600,
                  height: 60,
                  child: TextFormField(
                    controller: currentPasswordController,
                    obscureText: !currentPasswordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Şifre',
                      hintText: 'Mevcut şifrenizi giriniz...',
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
                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                          10, 20, 10, 16),
                      suffixIcon: InkWell(
                        onTap: () =>
                            setState(
                                  () =>
                              currentPasswordVisibility =
                              !currentPasswordVisibility,
                            ),
                        child: Icon(
                          currentPasswordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 600,
                  height: 60,
                  child: TextFormField(
                    controller: newPasswordController,
                    obscureText: !newPasswordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      hintText: 'Yeni şifrenizi giriniz...',
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
                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                          10, 20, 10, 16),
                      suffixIcon: InkWell(
                        onTap: () =>
                            setState(
                                  () =>
                              newPasswordVisibility = !newPasswordVisibility,
                            ),
                        child: Icon(
                          newPasswordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 500,
                  height: 60,
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !confirmPasswordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifreyi Onayla',
                      hintText: 'Yeni şifrenizi tekrar giriniz...',
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
                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                          10, 20, 10, 16),
                      suffixIcon: InkWell(
                        onTap: () =>
                            setState(
                                  () =>
                              confirmPasswordVisibility =
                              !confirmPasswordVisibility,
                            ),
                        child: Icon(
                          confirmPasswordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updatePassword,
                  child: const Text('Şifreyi Güncelle'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(130, 40),
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
        ),
      );
    }
  }
