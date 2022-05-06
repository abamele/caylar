import 'dart:io';

import 'package:caylar/constants/apihttp.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future tokenUpdate(context) async {
  print("geldi");
  final status = await OneSignal.shared.getDeviceState();
  final String? osUserID = status?.userId;
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  String deviceOS = Platform.isAndroid ? "Android" : "IOS";
  print("ohaaaaaaaaaaaaaaaa");
  try {
    var response = await Dio().post(AppUrl.tokenUpdate,
        options: Options(headers: {
          "Authorization":
              "Bearer ${Hive.box("userbox").get("token").toString()}",
          "Content-Type": "application/json"
        }),
        data: {
          "deviceToken": osUserID,
          "deviceOS": deviceOS,
          "deviceName": androidInfo.androidId
        });
    print(response);
    return response;
  } on DioError catch (e) {
    Hive.box("userbox").clear();
    Navigator.of(context)
        .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
  }
}
