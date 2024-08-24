import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panic_link/provider/device_provider.dart';
import 'package:panic_link/model/device_model.dart';
import 'package:panic_link/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DeviceStatus extends StatefulWidget {
  static const String routeName = '/deviceStatus';

  const DeviceStatus({super.key});

  @override
  State<DeviceStatus> createState() => _DeviceStatusState();
}

class _DeviceStatusState extends State<DeviceStatus> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _switchValue = false;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

      // Kullanıcı ID'sini güncelle
      deviceProvider.updateUserId(_currentUser.uid);

      // Mevcut cihaz bilgilerini almak için deviceProvider'ı kullanın
      final deviceId = deviceProvider.device?.deviceId;

      if (deviceId != null) {
        deviceProvider.fetchDevice(deviceId);
      } else {
        // Cihaz ID'si yoksa gerekli işlemleri yapın
        print("Kullanıcının bir deviceId'si yok.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        final device = deviceProvider.device;

        return Scaffold(
          backgroundColor: Color(0xFFEEF1F5),
          appBar: AppBar(
            title: Text('Cihaz Kontrolleri'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                NonExpandableListContainer(
                  title: 'Pil Seviyesi',
                  switchValue: _switchValue,
                  onSwitchChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
                ExpandableListContainer(
                  title: 'Cihaz Bilgileri',
                  content: device != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, // Metni sola hizalar
                        child: Text(
                          'Cihaz Adı: ${device.deviceName}',
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft, // Metni sola hizalar
                        child: Text(
                          'Bağlantı Durumu: ${device.isConnected ? 'Bağlı' : 'Bağlı Değil'}',
                        ),
                      ),
                      // Diğer cihaz bilgilerini buraya ekleyin
                    ],
                  )
                      : Text('Cihaz bilgisi bulunamadı.'),
                ),

                ExpandableListContainer(
                  title: 'Sensör Verileri',
                  content: Row(),
                ),
                ExpandableListContainer(
                  title: 'Pin Kodunu Değiştir',
                  content: device != null
                      ? PinChangeForm(deviceId: device.deviceId!) // deviceId'yi geçiyoruz
                      : Center(child: Text('Cihaz bilgisi bulunamadı.')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class NonExpandableListContainer extends StatelessWidget {
  final String title;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;

  const NonExpandableListContainer({
    required this.title,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18,),
                    ),
                  ),
                  SizedBox(height: 8),
                  Switch(
                    value: switchValue,
                    onChanged: onSwitchChanged,
                    activeColor: Colors.blue, // Aktif durumda renk

                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    width: 95.0,
                    height: 95.0,
                    child: CircularProgressIndicator(
                      value: 0.7,
                      strokeWidth: 9.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      semanticsLabel: 'Circular progress indicator',
                    ),
                  ),
                  Text(
                    '70%',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableListContainer extends StatelessWidget {
  final String title;
  final Widget content;

  const ExpandableListContainer({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              title,
              style: TextStyle(fontSize: 18,),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class PinChangeForm extends StatefulWidget {
  final String deviceId; // deviceId'yi burada tanımlayın

  const PinChangeForm({required this.deviceId, Key? key}) : super(key: key);

  @override
  _PinChangeFormState createState() => _PinChangeFormState();
}

class _PinChangeFormState extends State<PinChangeForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _currentPinController,
                decoration: InputDecoration(labelText: 'Mevcut Pin Kodu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mevcut Pin Kodunu giriniz';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _newPinController,
                decoration: InputDecoration(labelText: 'Yeni Pin Kodu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yeni Pin Kodunu giriniz';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _confirmPinController,
                decoration: InputDecoration(labelText: 'Yeni Pin Kodu Onayla'),
                obscureText: true,
                validator: (value) {
                  if (value != _newPinController.text) {
                    return 'Yeni Pin Kodları eşleşmiyor';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16), // Araya boşluk ekleyebilirsiniz
            ElevatedButton(
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Formu doğruladıktan sonra, DeviceProvider'ı kullanarak pin kodunu değiştirin
                  final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
                  final currentPin = _currentPinController.text;
                  final newPin = _newPinController.text;

                  // DeviceProvider'daki changePinCode metodunu çağırın
                  deviceProvider.changePinCode(widget.deviceId, currentPin, newPin);
                }
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

