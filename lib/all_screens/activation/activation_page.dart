import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class ActivationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActivationPage();
  }
}

class _ActivationPage extends State {
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(16.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: crimsonColor,
          title: const Text(
            "Telefon Aktivasyonu",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lütfen kodu giriniz...",
                style: TextStyle(
                    color: Color(0xFF212121),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 19.98),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 36.0, right: 36.0),
                  child: const Text(
                    "Telefonunuza gelen altı haneli kodu aşağıdaki alana giriniz ve onaylayınız",
                    style: TextStyle(
                        fontSize: 13.32,
                        fontFamily: 'Roboto',
                        color: Color(0xFF212121)),
                  )),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: PinPut(
                  fieldsCount: 6,
                  withCursor: true,
                  textStyle:
                      const TextStyle(fontSize: 25.0, color: Colors.white),
                  eachFieldWidth: 55.0,
                  eachFieldHeight: 55.0,
                  // onSubmit: (String pin) => _showSnackBar(pin),
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedFieldDecoration: pinPutDecoration,
                  selectedFieldDecoration: pinPutDecoration,
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: crimsonColor, minimumSize: const Size(350, 45)),
                  onPressed: () async {
                    try {
                      var response = await Dio().post(AppUrl.active, data: {
                        "userId": arg["userName"],
                        "code": _pinPutController.text,
                        "phone": arg["phone"]
                      }).then((value) {
                        Navigator.pushNamed(context, "/confirm",
                            arguments: {"userType": arg["userType"]});
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
                  },
                  child: const Text("Onayla"))
            ],
          ),
        ),
      ),
    );
  }
}
