import 'package:flutter/material.dart';

class DeviceStatus extends StatefulWidget {
  static const String routeName = '/deviceStatus';

  const DeviceStatus({super.key});

  @override
  State<DeviceStatus> createState() => _DeviceStatusState();
}

class _DeviceStatusState extends State<DeviceStatus> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    backgroundColor: Color(0xFFEEF1F5);

    return Scaffold(
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
                title: 'Cihaz Bilgileri', content: Row()),
            ExpandableListContainer(
                title: 'Sensör Verileri', content: Row()),
            ExpandableListContainer(
                title: 'Pin Kodunu Değiştir', content: PinChangeForm(),),
          ],
        ),
      ),
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
class PinChangeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Mevcut Pin Kodu'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Yeni Pin Kodu'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Yeni Pin Kodu Onayla'),
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
              // Butona tıklandığında yapılacak işlemler
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
