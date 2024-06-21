import 'package:flutter/material.dart';
import 'connect_device.dart';


class ScanDevice extends StatefulWidget {
  static const String routeName = '/scanDevice';

  const ScanDevice({Key? key}) : super(key: key);

  @override
  State<ScanDevice> createState() => _ScanDeviceState();
}

class _ScanDeviceState extends State<ScanDevice> {
  // PageController değişkeni başlangıç değeriyle tanımlandı
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // initState içinde tanımlama yapmaya gerek kalmadı
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.979,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: PageView(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Row(
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
                                          fontFamily: 'Lexend',
                                          fontSize: 30,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 60.0),
                                      child: Container(
                                        width: 240,
                                        height: 240,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/images/vnimc_1.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: Text(
                                    'Giyilebilir Cihaz Seç',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 36,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Acil durumlarda hızlıca yardım çağrısı yapmak için cihazınızı eklemeye başlayın. ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'Lexend',
                                      fontSize: 16,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, ConnectDevice.routeName);
                                  },
                                  style: ElevatedButton.styleFrom(

                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Cihazınızı Bağlayın',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 17,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 20.0),
                                      child: Image.asset(
                                        'assets/images/fin_onboarding_2@2x.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Keep Track of Spending',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Easily add transactions and as...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                                      child: Image.asset(
                                        'assets/images/fin_onboarding_3@2x.png',
                                        width: 300,
                                        height: 250,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Budget Analysis',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Know where your budgets are an...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      letterSpacing: 0,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
