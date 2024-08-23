import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'model/help_request_model.dart';

class RealTimeTracking extends StatefulWidget {
  static const String routeName = '/realTimeTracking';

  const RealTimeTracking({Key? key}) : super(key: key);

  @override
  State<RealTimeTracking> createState() => _RealTimeTrackingState();
}

class _RealTimeTrackingState extends State<RealTimeTracking> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController;
  late FirebaseAuth _auth;
  late User? _currentUser;
  final LatLng _center = const LatLng(13.106061, -59.613158);
  late DatabaseReference _database;
  List<HelpCall> _helpCalls = []; // List to hold HelpCall objects
  LatLng? _currentPosition; // Mevcut konum, başlangıçta null olarak tanımlandı

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _currentUser = _auth.currentUser;
    _database = FirebaseDatabase.instance.reference();
    _loadHelpCalls(); // Load HelpCall data from Firebase
    _getCurrentLocation(); // Mevcut konumu al
  }

  Future<void> _getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      throw Exception('Konum servisi etkin değil');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Konum izni sürekli reddedildi, lütfen ayarlardan değiştirin');
    }

    // Konumu al ve _currentPosition değişkenini güncelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadHelpCalls() {
    if (_currentUser != null) {
      _database
          .child('users')
          .child(_currentUser!.uid)
          .child('helpCalls') // Firebase'deki doğru düğümü kontrol edin
          .get()
          .then((DataSnapshot dataSnapshot) {
        dynamic data = dataSnapshot.value;

        if (data != null && data.isNotEmpty) {
          setState(() {
            _helpCalls = (data as Map).values.map((helpCallData) {
              print('HelpCall Data: $helpCallData'); // Debug için ekleyin
              return HelpCall.fromMap(Map<String, dynamic>.from(helpCallData));
            }).toList();
          });
        } else {
          setState(() {
            _helpCalls = [];
          });
        }
      }).catchError((error) {
        print('HelpCall verileri alınırken hata oluştu: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor: Color(0xFFEEF1F5);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [],
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            top: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                  child: Text(
                    'Cihazın gerçek zamanlı konumunu izleyin.',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  child: _currentPosition != null
                      ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('currentPosition'),
                        position: _currentPosition!,
                        infoWindow: InfoWindow(
                          title: 'Mevcut Konum',
                          snippet: 'Buradasınız',
                        ),
                      ),
                    },
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                  child: Text(
                    'Alarm Geçmişi',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _helpCalls.length,
                  itemBuilder: (BuildContext context, int index) {
                    HelpCall helpCall = _helpCalls[index];
                    String formattedDate =
                    DateFormat('dd-MM-yyyy HH:mm').format(helpCall.timestamp);

                    return ListTile(
                      title: Text('Tarih: $formattedDate'),
                      subtitle: Text('Call ID: ${helpCall.callId ?? 'N/A'}'),
                      // Diğer bilgileri buraya ekleyebilirsiniz
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
