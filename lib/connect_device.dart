import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:panic_link/ble_controller.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

class ConnectDevice extends StatefulWidget {
  static const String routeName = '/connectDevice';

  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("BLE SCANNER"),
          ),
          body: GetBuilder<BleController>(
            init: BleController(),
            builder: (BleController controller) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<List<ScanResult>>(
                        stream: controller.scanResults,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final data = snapshot.data![index];
                                    return Card(
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(data.device.name),
                                        subtitle: Text(data.device.id.id),
                                        trailing: Text(data.rssi.toString()),
                                        onTap: () => controller
                                            .connectToDevice(data.device),
                                      ),
                                    );
                                  }),
                            );
                          } else {
                            return Center(
                              child: Text("No Device Found"),
                            );
                          }
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          controller.scanDevices();
                          // await controller.disconnectDevice();
                        },
                        child: Text("SCAN")),
                  ],
                ),
              );
            },
          )),
    );
  }
}
