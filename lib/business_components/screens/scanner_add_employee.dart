import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class ScannerAddEmployee extends StatefulWidget {
  const ScannerAddEmployee({Key? key}) : super(key: key);

  @override
  _ScannerAddEmployeeState createState() => _ScannerAddEmployeeState();
}

class _ScannerAddEmployeeState extends State<ScannerAddEmployee> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final ValueNotifier<Map> _addDealerLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: 50,
            // left: MediaQuery.of(context).size.width*0.4,
            child: Center(
              child: (result != null)
                  ? ElevatedButton(
                      onPressed: () {
                        print("afanpfanfaawşfmai ${result!.code}");
                        addButton(result!.code.toString());
                        showAddDeelerDialog();
                      },
                      child: const Text("Personel Ekle"))
                  : const Text('Lütfen QR kodu Kameraya Okutun.'),
            ),
          )
        ],
      ),
    );
  }

  Future addButton(String employeeId) async {
    try {
      var response = await Dio().post(AppUrl.addEmployee,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "employeeId": employeeId,
          }).then((value) {
        _addDealerLoading.value = {"state": 1, "message": "Personel Eklendi."};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.addDealer,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "employeeId": employeeId,
                }).then((value) {
              _addDealerLoading.value = {
                "state": 1,
                "message": "Personel Eklendi."
              };
            });
          } on DioError catch (e) {
            _addDealerLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _addDealerLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  showAddDeelerDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _addDealerLoading,
              builder: (BuildContext context, Map value, Widget? child) {
                if (value["state"] == 0) {
                  return WillPopScope(
                      child: Container(
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      onWillPop: () async => false);
                } else if (value["state"] == 1) {
                  return AlertDialog(
                    title: Text(value["message"]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.pop(context);
                          },
                          child: const Text("Tamam"))
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: Text(value["message"]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Tamam"))
                    ],
                  );
                }
              });
        }).then((value) {
      _addDealerLoading.value = {"state": 0, "message": ""};
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/businessemployees", ModalRoute.withName("/smemenu"));
    });
  }
}
