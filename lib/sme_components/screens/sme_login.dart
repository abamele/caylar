import 'dart:io';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/sme_components/models/phone_number_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SmeLogin extends StatefulWidget {
  SmeLogin({
    Key? key,
  }) : super(key: key);

  @override
  _SmeLoginState createState() => _SmeLoginState();
}

class _SmeLoginState extends State<SmeLogin> {
  late bool hidePassword = true;
  late String _userName = Hive.box("rememberbox").get("smeUserName") ?? "";
  late String _password = Hive.box("rememberbox").get("smePassword") ?? "";
  final ValueNotifier<Map> _smeLoginLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  final formKey = GlobalKey<FormState>();
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  bool? _rememberMe = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 80.0),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      LengthLimitingTextInputFormatter(10),
                      _phoneNumberFormatter
                    ],
                    initialValue: _userName,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: crimsonColor),
                      ),
                      hintText: "(5xx) xxx-xxxx",
                      labelText: "Telefon Numarası",
                      labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _userName = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Telefon numaranızı giriniz";
                      } else {
                        return (value).length == 14
                            ? null
                            : 'İstenilen formatta bilgi giriniz.';
                      }
                    },
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    initialValue: _password,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: crimsonColor),
                      ),
                      labelText: "Şifreniz",
                      labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Şifre veya kullanıcı adınızı giriniz";
                      } else {
                        return (value).length >= 6 ? null : '6 dan küçük';
                      }
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                        child: const Text("Şifremi Unuttum"),
                        onPressed: () =>
                            Navigator.pushNamed(context, "/forgotpassword")),
                  ),
                  CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        "Beni Hatırla",
                        style: TextStyle(
                          fontSize: 12.50,
                        ),
                      ),
                      value: _rememberMe,
                      onChanged: (value) => setState(() {
                            _rememberMe = value;
                          })),
                  LoginButton(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Material(
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: InkWell(
                            splashColor: Colors.black26,
                            onTap: () {},
                            child: Container(
                              child: Ink.image(
                                image: const AssetImage(
                                  'assets/Ekranq.png',
                                ),
                                height: 100,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget LoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: crimsonColor,
        minimumSize: const Size(350, 40),
      ),
      child: const Text("Giriş Yap"),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          loginRequest(
            _userName,
            _password,
          );
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Hata"),
                  content: const Text("Giriş bilgilerinizi hatalı"),
                  actions: [
                    MaterialButton(
                        child: const Text("Tamam"),
                        onPressed: () => Navigator.pop(context))
                  ],
                );
              });
        }
      },
    );
  }

  void loginRequest(
    String userName,
    String password,
  ) async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    String purePhone =
        "0${userName.substring(1, 4)}${userName.substring(6, 9)}${userName.substring(10, 14)}";
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;
    print("token-------------------------------------------- $osUserID");
    String deviceOS = Platform.isAndroid ? "Android" : "IOS";
    showSmeLoginDialog();
    try {
      var response = await Dio().post(AppUrl.login, data: {
        "userName": purePhone,
        "password": password,
        "deviceName": androidInfo.androidId,
        "deviceOS": deviceOS,
        "deviceToken": osUserID,
      }).then((value) {
        print("kayıt gerçekleşti. $value");
        if (value.data["errorCode"] == 0) {
          if (value.data["data"]["role"] == 1) {
            _smeLoginLoading.value = {"state": 1, "message": "Giriş Başarılı."};
            // Navigator.pushNamedAndRemoveUntil(
            //     context, "/smemenu", (Route<dynamic> route) => false);
            Hive.box("userbox").putAll({
              "isOpen": value.data["data"]["dealerSettings"]["isOpen"],
              "userType": value.data["data"]["role"],
              "token": value.data["data"]["token"],
              "kod": value.data["data"]["id"],
              "dealerName": value.data["data"]["companyName"],
              "dealerPhoto": value.data["data"]["photo"]
            });
            if (_rememberMe == true) {
              Hive.box("rememberbox")
                  .putAll({"smeUserName": userName, "smePassword": password});
            }
          } else {
            // showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title: const Text(
            //             "Çay Ocağı girişi yapamaya yetkiniz bulunmuyor."),
            //         actions: [
            //           TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               child: Text("Kapat"))
            //         ],
            //       );
            //     });
            _smeLoginLoading.value = {
              "state": 2,
              "message": "Çay Ocağı girişi yapamaya yetkiniz bulunmuyor."
            };
          }
        } else {
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: const Text("Beklenmeyen bir hata oluştu."),
          //         actions: [
          //           TextButton(
          //               onPressed: () {
          //                 Navigator.pop(context);
          //               },
          //               child: const Text("Kapat"))
          //         ],
          //       );
          //     });
          _smeLoginLoading.value = {
            "state": 2,
            "message": "Beklenmeyen bir hata oluştu."
          };
        }
      });
    } on DioError catch (e) {
      print("${e.response}");
      _smeLoginLoading.value = {
        "state": 2,
        "message": "${e.response!.data["message"]}"
      };
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text(e.response!.data["message"].toString()),
      //         actions: [
      //           TextButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //               },
      //               child: const Text("Kapat"))
      //         ],
      //       );
      //     });
    }
  }

  showSmeLoginDialog() {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _smeLoginLoading,
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
                      Future.delayed(Duration.zero, () {
                        Navigator.pushNamedAndRemoveUntil(context, "/smemenu",
                            (Route<dynamic> route) => false);
                      });
                      return WillPopScope(
                          child: Container(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          onWillPop: () async => false);
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
            })
        .then((value) => _smeLoginLoading.value = {"state": 0, "message": ""});
  }
}
