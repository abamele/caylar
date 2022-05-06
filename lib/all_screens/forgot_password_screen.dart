import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/sme_components/models/phone_number_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPassword();
  }
}

class _ForgotPassword extends State {
  final formKey = GlobalKey<FormState>();
  String? phoneNum;
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  final ValueNotifier<Map> _forgotLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: crimsonColor,
        elevation: 0.0,
        title: const Text("Şifremi Unuttum!"),
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  LengthLimitingTextInputFormatter(10),
                  _phoneNumberFormatter
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "(5xx) xxx-xxxx",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  labelText: "Telefon Numaranız",
                  labelStyle: const TextStyle(
                      color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    borderSide: BorderSide(color: whiteColor),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Telefon numaranızı giriniz.";
                  } else {
                    return (value).length == 14
                        ? null
                        : 'Lütfen telefon numaranızı formata uygun giriniz.';
                  }
                },
                onSaved: (value) {
                  phoneNum = value!;
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                margin: const EdgeInsets.only(left: 55.0, right: 30.0),
                child: const Text(
                  "Sistemde kayıtlı telefon numarasını giriniz.",
                  style: TextStyle(
                      fontSize: 13.37,
                      fontFamily: 'Roboto',
                      color: Color(0xFF9E9E9E)),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: crimsonColor,
                  minimumSize: const Size(318, 43.38),
                ),
                child: const Text(
                  "Şifre Gönder",
                  style: TextStyle(fontSize: 13.33),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    print(phoneNum);
                    String purePhone =
                        "0${phoneNum!.substring(1, 4)}${phoneNum!.substring(6, 9)}${phoneNum!.substring(10, 14)}";
                    showForgotDialog(purePhone);
                    try {
                      var response =
                          await Dio().post(AppUrl.forgotPassword, data: {
                        "phone": purePhone,
                      }).then((value) {
                        _forgotLoading.value = {
                          "state": 1,
                          "message": "İşlem Başarılı"
                        };
                        // if (value.data["errorCode"] == 0) {
                        //   Navigator.pushNamed(context, "/newpasscode",
                        //       arguments: {"phone": purePhone});
                        // }
                      });
                    } on DioError catch (e) {
                      _forgotLoading.value = {
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
                      //               child: const Text("Kapat"))
                      //         ],
                      //       );
                      //     });
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  showForgotDialog(String purePhone) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _forgotLoading,
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
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/newpasscode",
                        arguments: {"phone": purePhone});
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
        }).then((value) => _forgotLoading.value = {"state": 0, "message": ""});
  }
}
