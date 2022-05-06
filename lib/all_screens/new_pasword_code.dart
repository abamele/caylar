import 'package:caylar/constants/apihttp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class NewPassCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPassCode();
  }
}

class _NewPassCode extends State {
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(16.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  late bool hidePassword = true;
  String? _password;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Color(0xFFEB0029),
          title: const Text(
            "Telefon Aktivasyonu",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Form(
          key: formKey,
          child: Center(
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
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
                      labelText: "Yeni Şifre",
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
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFEB0029),
                        minimumSize: Size(350, 45)),
                    onPressed: () async {
                      print(_pinPutController.text);
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        var response =
                            await Dio().post(AppUrl.updatePassword, data: {
                          "code": _pinPutController.text,
                          "password": _password,
                          "phone": arg["phone"],
                        }).then((value) {
                          print("kayıt gerçekleşti. $value");
                          Navigator.pushNamed(context, "/confirm");
                        });
                      }
                    },
                    child: const Text("Onayla"))
              ],
            ),
          ),
        ));
  }
}
