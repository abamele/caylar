import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TeaShopPasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeaShopPasswordScreen();
  }
}

class _TeaShopPasswordScreen extends State {
  String? dealerCode;
  final formKey = GlobalKey<FormState>();
  final ValueNotifier<Map> _addDealerLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: crimsonColor,
          elevation: 0.0,
          title: const Text("Kod ile Ekle"),
        ),
        resizeToAvoidBottomInset: false,
        body: Form(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: crimsonColor),
                      ),
                      labelText: "Kodu yazınız",
                      labelStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        dealerCode = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Lütfen kod giriniz.";
                      }
                    },
                    onSaved: (value) {
                      dealerCode = value!;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 55.0, right: 30.0),
                  child: const Text(
                    "Eklemek istediğiniz çay ocağının size vermiş olduğu kodu giriniz",
                    style: TextStyle(
                        fontSize: 13.37,
                        fontFamily: 'Roboto',
                        color: Color(0xFF9E9E9E)),
                  ),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                addButton(dealerCode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addButton(String? dealerId) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: crimsonColor,
        minimumSize: const Size(318, 43.38),
      ),
      child: const Text(
        "Ekle",
        style: TextStyle(fontSize: 13.33),
      ),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          showAddDeelerDialog();
          try {
            var response = await Dio().post(AppUrl.addDealer,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "dealerId": dealerId,
                }).then((value) {
              _addDealerLoading.value = {
                "state": 1,
                "message": "Çay Ocağı Eklendi."
              };
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
                        "dealerId": dealerId,
                      }).then((value) {
                    _addDealerLoading.value = {
                      "state": 1,
                      "message": "Çay Ocağı Eklendi."
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
      },
    );
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
            })
        .then((value) => _addDealerLoading.value = {"state": 0, "message": ""});
  }
}
