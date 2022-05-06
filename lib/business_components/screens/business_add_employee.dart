import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessAddEmployee extends StatefulWidget {
  const BusinessAddEmployee({Key? key}) : super(key: key);

  @override
  State<BusinessAddEmployee> createState() => _BusinessAddEmployeeState();
}

class _BusinessAddEmployeeState extends State<BusinessAddEmployee> {
  String? employeeId;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
        title: const Text(
          "Personel Ekle",
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, color: Colors.white),
        ),
      ),
      drawer: WidgetDrawer(drawerType: 2),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                onChanged: (value) {
                  employeeId = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Lütfen bir personel ID'si giriniz.";
                  }
                },
                onSaved: (value) {
                  employeeId = value!;
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  labelText: "Personel ID'sini yazınız.",
                  labelStyle: const TextStyle(
                      color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                margin: const EdgeInsets.only(left: 55.0, right: 30.0),
                child: const Text(
                  "Firmanızın bünyesine eklemek istediğiniz personelin ID'sini giriniz. Personel ID'si için personelinizden hesabına giriş yapmasını ve ana sayfada bulunan ID'yi size söylemesini isteyiniz.",
                  style: TextStyle(
                      fontSize: 13.37,
                      fontFamily: 'Roboto',
                      color: Color(0xFF9E9E9E)),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              addButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addButton() {
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
              print("aifmjaşjnfnaşvşamvaim $value");
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Personel Firmanıza Eklendi."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Kapat"))
                      ],
                    );
                  });
            });
          } on DioError catch (e) {
            if (e.response!.data["errorCode"] == 2023) {
              tokenUpdate(context).then((value) async {
                Hive.box("userbox").put("token", value.data["data"]);
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
                    print("aifmjaşjnfnaşvşamvaim $value");
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Personel Firmanıza Eklendi."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Kapat"))
                            ],
                          );
                        });
                  });
                } on DioError catch (e) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("${e.response!.data["message"]}"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Kapat"))
                          ],
                        );
                      });
                }
              });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("${e.response!.data["message"]}"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Kapat"))
                      ],
                    );
                  });
            }
          }
        }
      },
    );
  }
}
