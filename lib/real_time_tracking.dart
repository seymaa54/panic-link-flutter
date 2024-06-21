import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class RealTimeTracking extends StatefulWidget {
  static const String routeName = '/realTimeTracking';

  const RealTimeTracking({Key? key}) : super(key: key);

  @override
  State<RealTimeTracking> createState() => _RealTimeTrackingState();
}

class _RealTimeTrackingState extends State<RealTimeTracking> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(13.106061, -59.613158);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 8),
                    child: Text(
                      'Cihazın gerçek zamanlı konumunu izleyin.',
                      style: TextStyle(
                        color: Colors.black38,
                      ) ,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                    child: Container(
                      width: 390,
                      height: 230,
                      decoration: BoxDecoration(),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 14.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 8),
                    child: Text(
                      'Alarm Geçmişi',
                      style:TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                  ),
                  ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      // List items go here
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
