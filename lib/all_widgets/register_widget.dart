import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/sme_components/models/phone_number_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/scheduler.dart';

class WidgetRegister extends StatefulWidget {
  late int userType;
  WidgetRegister({Key? key, required this.userType}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WidgetRegister();
  }
}

class _WidgetRegister extends State<WidgetRegister> {
  // Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);
  String? txtUsernameOrPhone;
  // var txtUsernameOrPhone = TextEditingController();
  String? txtPassword;
  String? txtPasswordConfirm;
  var txtEmail = TextEditingController();
  var txtCompanyName = TextEditingController();
  var txtName = TextEditingController();
  var txtSurname = TextEditingController();
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  final ValueNotifier<Map> _registerLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  bool? _kvkk = false;
  bool _kvkkSelect = true;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: whiteColor,
      child: Container(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: crimsonColor)),
                      labelText: "Telefon Numaranız",
                      labelStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        txtUsernameOrPhone = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Telefon numaranızı giriniz.";
                      } else {
                        return (value).length == 14
                            ? null
                            : 'Lütfen telefon numaranızı formata uygun giriniz.';
                      }
                    },
                    onSaved: (value) {},
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        txtPassword = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Şifre Belirleyiniz.";
                      } else {
                        return (value).length >= 6
                            ? null
                            : 'Lütfen 6 haneden uzun bir şifre belirleyiniz.';
                      }
                    },
                    onSaved: (value) {
                      txtPassword = value;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: crimsonColor)),
                      labelText: "Şifre",
                      labelStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        txtPasswordConfirm = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Belirlenen şifreyi tekrar giriniz.";
                      } else {
                        return value == txtPassword
                            ? null
                            : 'Şifreler uyuşmuyor.';
                      }
                    },
                    onSaved: (value) {
                      txtPasswordConfirm = value;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: crimsonColor)),
                      labelText: "Şifre Tekrar",
                      labelStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  // TextFormField(
                  //   controller: txtEmail,
                  //   //onSaved: (value) => email = value!,
                  //   decoration: const InputDecoration(
                  //     focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(color: Color(0xFFEB0029))),
                  //     labelText: "E-Posta",
                  //     labelStyle: TextStyle(
                  //         color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 5.0,
                  // ),
                  userTypeWidget(widget.userType),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    controller: txtName,
                    //onSaved: (value) => nameSurname = value!,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEB0029))),
                      labelText: "Adınız",
                      labelStyle: TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    controller: txtSurname,
                    //onSaved: (value) => nameSurname = value!,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: crimsonColor)),
                      labelText: "Soyadınız",
                      labelStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        "Kullanıcı Sözleşmesini Okudum ve Kabul Ediyorum",
                        style: TextStyle(
                            fontSize: 12.50,
                            color: _kvkkSelect == false
                                ? crimsonColor
                                : Colors.black),
                      ),
                      value: _kvkk,
                      onChanged: (value) => setState(() {
                            _kvkk = value;
                            if (value == true) {
                              _kvkkSelect = true;
                            }
                          })),
                  const SizedBox(
                    height: 5.0,
                  ),
                  // auth.loggedInStatus==Status.Authenticating?loading:
                  ElevatedButton(
                    child: Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        fontSize: 15,
                        color: whiteColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: crimsonColor,
                      minimumSize: const Size(318, 43.38),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        var usernameOrPhone = txtUsernameOrPhone!;
                        var password = txtPassword;
                        var passeordConfirm = txtPasswordConfirm;
                        var email = txtEmail.text;
                        var companyName = txtCompanyName.text;
                        var name = txtName.text;
                        var surname = txtSurname.text;
                        if (_kvkk != true) {
                          _kvkkSelect = false;
                          setState(() {});
                        } else {
                          if (widget.userType == 1) {
                            registerDeiler(
                                context,
                                widget.userType,
                                usernameOrPhone,
                                password!,
                                passeordConfirm!,
                                email,
                                companyName,
                                name,
                                surname);
                            showRegisterDialog(usernameOrPhone, 1);
                            // Navigator.pushNamed(context, "/activation",
                            //     arguments: {
                            //       "userName": usernameOrPhone,
                            //       "phone": usernameOrPhone,
                            //       "userType": 1
                            //     });
                          } else if (widget.userType == 2) {
                            registerCompany(
                                context,
                                widget.userType,
                                usernameOrPhone,
                                password!,
                                passeordConfirm!,
                                email,
                                companyName,
                                name,
                                surname);
                            showRegisterDialog(usernameOrPhone, 2);
                            // Navigator.pushNamed(context, "/activation",
                            //     arguments: {
                            //       "userName": usernameOrPhone,
                            //       "phone": usernameOrPhone,
                            //       "userType": 1
                            //     });
                          } else if (widget.userType == 3) {
                            registerPerson(
                                context,
                                widget.userType,
                                usernameOrPhone,
                                password!,
                                passeordConfirm!,
                                email,
                                name,
                                surname);
                            showRegisterDialog(usernameOrPhone, 3);
                            // Navigator.pushNamed(context, "/activation",
                            //     arguments: {
                            //       "userName": usernameOrPhone,
                            //       "phone": usernameOrPhone,
                            //       "userType": 1
                            //     });
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  userTypeWidget(int userType) {
    if (userType == 1) {
      return TextFormField(
        controller: txtCompanyName,
        //onSaved: (value) => businessName = value!,
        decoration: const InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEB0029))),
          labelText: "Kobi Adı",
          labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
          border: OutlineInputBorder(),
        ),
      );
    } else if (userType == 2) {
      return TextFormField(
        controller: txtCompanyName,
        //onSaved: (value) => businessName = value!,
        decoration: const InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEB0029))),
          labelText: "Firma Adı",
          labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
          border: OutlineInputBorder(),
        ),
      );
    } else if (userType == 3) {
      return TextFormField(
        controller: txtCompanyName,
        //onSaved: (value) => businessName = value!,
        decoration: InputDecoration(
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: crimsonColor)),
          labelText: "Firma Kodu",
          labelStyle:
              const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
          border: const OutlineInputBorder(),
        ),
      );
    }
  }

  showRegisterDialog(String usernameOrPhone, int userType) {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _registerLoading,
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
                        Navigator.pushNamed(context, "/activation", arguments: {
                          "userName": usernameOrPhone,
                          "phone": usernameOrPhone,
                          "userType": userType
                        });
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
        .then((value) => _registerLoading.value = {"state": 0, "message": ""});
  }

  Future registerDeiler(
      BuildContext context,
      int userType,
      String usernameOrPhone,
      String password,
      String passeordConfirm,
      String email,
      String companyName,
      String name,
      String surname) async {
    String purePhone =
        "0${usernameOrPhone.substring(1, 4)}${usernameOrPhone.substring(6, 9)}${usernameOrPhone.substring(10, 14)}";
    try {
      var response = await Dio().post(AppUrl.register, data: {
        "password": password,
        // "email": email,
        "userName": purePhone, //phone
        "phoneNumber": purePhone,
        "name": name,
        "surname": surname,
        "companyName": companyName, //çay ocagı ismi ve firma ismi
        // "companyId": "string", // firma kodu
        "role": 1,
      }).then((value) {
        _registerLoading.value = {
          "state": 1,
          "message": "Kaydınız Çay Ocağı Olarak Başarılıyla Gerçekleşti."
        };
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text(
        //             "Kaydınız Çay Ocağı Olarak Başarılıyla Gerçekleşti."),
        //         actions: [
        //           TextButton(
        //               onPressed: () {
        //                 Navigator.pop(context);
        //               },
        //               child: const Text("Kapat"))
        //         ],
        //       );
        //     });
      });
    } on DioError catch (e) {
      _registerLoading.value = {
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

  Future registerCompany(
      BuildContext context,
      int userType,
      String usernameOrPhone,
      String password,
      String passeordConfirm,
      String email,
      String companyName,
      String name,
      String surname) async {
    String purePhone =
        "0${usernameOrPhone.substring(1, 4)}${usernameOrPhone.substring(6, 9)}${usernameOrPhone.substring(10, 14)}";
    try {
      var response = await Dio().post(AppUrl.register, data: {
        "password": password,
        // "email": email,
        "userName": purePhone,
        "phoneNumber": purePhone,
        "name": name,
        "surname": surname,
        "companyName": companyName,
        // "deviceOS": "string",
        // "deviceName": "string",
        // "deviceToken": "string",
        "role": 2,
      }).then((value) {
        _registerLoading.value = {
          "state": 1,
          "message": "Kaydınız Çay Ocağı Olarak Başarılıyla Gerçekleşti."
        };

        //   showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: Text("Kaydınız Firma Olarak Başarılıyla Gerçekleşti."),
        //           actions: [
        //             TextButton(
        //                 onPressed: () {
        //                   Navigator.pop(context);
        //                 },
        //                 child: Text("Kapat"))
        //           ],
        //         );
        //       });
      });
    } on DioError catch (e) {
      _registerLoading.value = {
        "state": 2,
        "message": "${e.response!.data["message"]}"
      };
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
                    child: Text("Kapat"))
              ],
            );
          });
    }
  }

  Future registerPerson(
      BuildContext context,
      int userType,
      String usernameOrPhone,
      String password,
      String passeordConfirm,
      String email,
      String name,
      String surname) async {
    String purePhone =
        "0${usernameOrPhone.substring(1, 4)}${usernameOrPhone.substring(6, 9)}${usernameOrPhone.substring(10, 14)}";
    try {
      var response = await Dio().post(AppUrl.register, data: {
        "password": password,
        // "email": email,
        "userName": purePhone,
        "phoneNumber": purePhone,
        "name": name,
        "surname": surname,
        "companyId": "8hOjHKei",
        // "deviceOS": "string",
        // "deviceName": "string",
        // "deviceToken": "string",
        "role": 3,
      }).then((value) {
        _registerLoading.value = {
          "state": 1,
          "message": "Kaydınız Çay Ocağı Olarak Başarılıyla Gerçekleşti."
        };

        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text(
        //             "Kaydınız Personel Olarak Başarılıyla Gerçekleşti."),
        //         actions: [
        //           TextButton(
        //               onPressed: () {
        //                 Navigator.pop(context);
        //               },
        //               child: Text("Kapat"))
        //         ],
        //       );
        //     });
      });
    } on DioError catch (e) {
      _registerLoading.value = {
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
}
