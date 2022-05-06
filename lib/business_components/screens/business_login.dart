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

class BusinessLogin extends StatefulWidget {
  BusinessLogin({Key? key}) : super(key: key);

  @override
  _BusinessLoginState createState() => _BusinessLoginState();
}

class _BusinessLoginState extends State<BusinessLogin> {
  late bool hidePassword = true;
  late String _userName = Hive.box("rememberbox").get("businessUserName") ?? "";
  late String _password = Hive.box("rememberbox").get("businessPassword") ?? "";
  bool? _rememberMe = false;
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  final ValueNotifier<Map> _businessLoginLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  final formKey = GlobalKey<FormState>();

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

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
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 80.0),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEB0029)),
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
                            onPressed: () => Navigator.pushNamed(
                                context, "/forgotpassword")),
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
          ],
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
    String deviceOS = Platform.isAndroid ? "Android" : "IOS";
    showBusinessLoginDialog();
    try {
      var response = await Dio().post(AppUrl.login, data: {
        "userName": purePhone,
        "password": password,
        "deviceName": androidInfo.androidId,
        "deviceOS": deviceOS,
        "deviceToken": osUserID
      }).then((value) {
        print("okeyyyyyyyyyyyy $value");
        if (value.data["errorCode"] == 0) {
          if (value.data["data"]["role"] == 2) {
            _businessLoginLoading.value = {
              "state": 1,
              "message": "Giriş Başarılı."
            };
            Hive.box("userbox").putAll({
              "token": value.data["data"]["token"],
              "companyId": value.data["data"]["id"],
              "userType": value.data["data"]["role"],
              "companyName": value.data["data"]["companyName"],
              "officialName": value.data["data"]["nameSurname"],
              "companyPhoto": value.data["data"]["photo"],
              "paymentSystem": 0
            });
            if (_rememberMe == true) {
              Hive.box("rememberbox").putAll(
                  {"businessUserName": userName, "businessPassword": password});
            }
            // Navigator.pushNamedAndRemoveUntil(
            //     context, "/businessmenu", (Route<dynamic> route) => false);
          } else {
            _businessLoginLoading.value = {
              "state": 2,
              "message": "Firma girişi yapmaya yetkiniz bulunmuyor."
            };
            // showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title:
            //             const Text("Firma girişi yapmaya yetkiniz bulunmuyor."),
            //         actions: [
            //           TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               child: Text("Kapat"))
            //         ],
            //       );
            //     });
          }
        } else {
          _businessLoginLoading.value = {
            "state": 2,
            "message": "Beklenmeyen bir hata oluştu."
          };
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: Text("Beklenmeyen bir hata oluştu.."),
          //         actions: [
          //           TextButton(
          //               onPressed: () {
          //                 Navigator.pop(context);
          //               },
          //               child: Text("Kapat"))
          //         ],
          //       );
          //     });
        }
      });
    } on DioError catch (e) {
      _businessLoginLoading.value = {
        "state": 2,
        "message": "${e.response!.data["message"]}"
      };
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text("${e.response!.data["message"]}"),
      //         actions: [
      //           TextButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //               },
      //               child: Text("Kapat"))
      //         ],
      //       );
      //     });
    }
  }

  showBusinessLoginDialog() {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _businessLoginLoading,
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
                        Navigator.pushNamedAndRemoveUntil(context,
                            "/businessmenu", (Route<dynamic> route) => false);
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
        .then((value) =>
            _businessLoginLoading.value = {"state": 0, "message": ""});
  }
}
