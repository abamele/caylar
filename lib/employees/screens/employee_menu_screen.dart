import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'dart:convert';
import 'dart:io' as Io;

class EmployeeMenuScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmployeeMenuScreen();
  }
}

class _EmployeeMenuScreen extends State {
  TextEditingController name = TextEditingController(text: "");
  TextEditingController surName = TextEditingController(text: "");
  PickedFile? imageFile;
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<Map> _employeeInfoLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crimsonColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/backgroudimage.png"),
                alignment: Alignment.bottomCenter),
          ),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      CircleAvatar(
                          radius: 70.0,
                          backgroundColor: Colors.white,
                          backgroundImage: profilePhoto()),
                      Positioned(
                          bottom: 13,
                          right: 56,
                          child: InkWell(
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.teal,
                              size: 38,
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (builder) => bottomSheet());
                            },
                          ))
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Hive.box("userbox").get("personName").toString(),
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 19.98,
                                color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(
                              LineIcons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              updateEmployeeName(name);
                            },
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       "Personel ID: ${Hive.box("userbox").get("personId").toString()}",
                      //       style: const TextStyle(
                      //           fontFamily: 'Roboto',
                      //           fontSize: 19.98,
                      //           color: Colors.white),
                      //     ),
                      //     IconButton(
                      //         onPressed: () {
                      //           Clipboard.setData(ClipboardData(
                      //               text: Hive.box("userbox")
                      //                   .get("personId")
                      //                   .toString()));
                      //         },
                      //         icon: Icon(
                      //           Icons.paste,
                      //           color: whiteColor,
                      //           semanticLabel: "Kopyala",
                      //         ))
                      //   ],
                      // ),
                      ListTile(
                        title: const Center(
                          child: Text(
                            "Sipariş Ver",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16.98,
                                color: Colors.white),
                          ),
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, "/employeeorder"),
                      ),
                      ListTile(
                        title: const Center(
                          child: Text(
                            "Kod Paylaş",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16.98,
                                color: Colors.white),
                          ),
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, "/employeeqr"),
                      ),
                      ListTile(
                        title: const Center(
                          child: Text(
                            "Siparişlerim",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16.98,
                                color: Colors.white),
                          ),
                        ),
                        onTap: () => Navigator.pushNamed(
                            context, "/employeeawaitandcancel"),
                      ),
                      ListTile(
                        title: const Center(
                          child: Text(
                            "Raporlar",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16.98,
                                color: Colors.white),
                          ),
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, "/employeereports"),
                      ),
                      ListTile(
                          title: const Center(
                            child: Text(
                              "Çıkış",
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16.98,
                                  color: Colors.white),
                            ),
                          ),
                          onTap: () {
                            Hive.box("userbox").clear();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                "/home", (Route<dynamic> route) => false);
                          }),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  profilePhoto() {
    if (imageFile == null && Hive.box("userbox").get("employeePhoto") != null) {
      return NetworkImage(Hive.box("userbox").get("employeePhoto").toString());
    } else if (imageFile != null) {
      return FileImage(Io.File(imageFile!.path)) as ImageProvider;
    } else {
      return const AssetImage("assets/cayimg.png");
    }
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    final bytes = Io.File(pickedFile!.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    userProfilePhotoAdd(img64);
    showBusinessInfoDialog(true);
    setState(() {
      imageFile = pickedFile;
    });
  }

  Future userProfilePhotoAdd(img64) async {
    try {
      var response = await Dio().post(AppUrl.userProfilePhotoAdd,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"imageData": img64}).then((value) {
        return updateProfileURL(value.data["data"]);
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.userProfilePhotoAdd,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"imageData": img64}).then((value) {
              return updateProfileURL(value.data["data"]);
            });
          } on DioError catch (e) {
            _employeeInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _employeeInfoLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Future updateProfileURL(imageURL) async {
    try {
      var response = await Dio().post(AppUrl.setSettings,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"profilePhoto": "$imageURL"}).then((value) {
        _employeeInfoLoading.value = {
          "state": 1,
          "message": "Profil resmi güncellendi."
        };
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.setSettings,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"profilePhoto": "$imageURL"}).then((value) {
              _employeeInfoLoading.value = {
                "state": 1,
                "message": "Profil resmi güncellendi."
              };
            });
          } on DioError catch (e) {
            _employeeInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _employeeInfoLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text("Profil fotoğrafı eklemek için seçiniz."),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera")),
              TextButton.icon(
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Galeri"))
            ],
          )
        ],
      ),
    );
  }

  updateEmployeeName(TextEditingController name) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 300,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Center(
                        child: Text(
                      "Personel Adı Güncelle",
                      style: TextStyle(fontSize: 20),
                    )),
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        hintText: "İsim",
                      ),
                    ),
                    TextFormField(
                      controller: surName,
                      decoration: const InputDecoration(
                        hintText: "Soyisim",
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        onPressed: () async {
                          Navigator.pop(context);
                          showBusinessInfoDialog(true);
                          try {
                            var response = await Dio().post(AppUrl.setSettings,
                                options: Options(headers: {
                                  "Authorization":
                                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                                  "Content-Type": "application/json"
                                }),
                                data: {
                                  "name": name.text.toString(),
                                  "surname": surName.text.toString()
                                }).then((value) {
                              setState(() {});
                              _employeeInfoLoading.value = {
                                "state": 1,
                                "message": "İsminiz güncellenmiştir."
                              };
                              Hive.box("userbox").put("personName",
                                  "${name.text.toString()} ${surName.text.toString()}");
                            });
                          } on DioError catch (e) {
                            if (e.response!.data["errorCode"] == 2023) {
                              tokenUpdate(context).then((value) async {
                                Hive.box("userbox")
                                    .put("token", value.data["data"]);
                                try {
                                  var response = await Dio().post(
                                      AppUrl.setSettings,
                                      options: Options(headers: {
                                        "Authorization":
                                            "Bearer ${Hive.box("userbox").get("token").toString()}",
                                        "Content-Type": "application/json"
                                      }),
                                      data: {
                                        "name": name.text.toString(),
                                        "surname": surName.text.toString()
                                      }).then((value) {
                                    setState(() {});
                                    _employeeInfoLoading.value = {
                                      "state": 1,
                                      "message": "İsminiz güncellenmiştir."
                                    };
                                    Hive.box("userbox").put("personName",
                                        "${name.text.toString()} ${surName.text.toString()}");
                                  });
                                } on DioError catch (e) {
                                  _employeeInfoLoading.value = {
                                    "state": 2,
                                    "message": "${e.response!.data["message"]}"
                                  };
                                }
                              });
                            } else {
                              _employeeInfoLoading.value = {
                                "state": 2,
                                "message": "${e.response!.data["message"]}"
                              };
                            }
                          }
                        },
                        child: const Text("Kaydet"))
                  ],
                ),
              ),
            ),
          );
        });
  }

  showBusinessInfoDialog(bool isPopup) {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _employeeInfoLoading,
                  builder: (BuildContext context, Map value, Widget? child) {
                    if (value["state"] == 0) {
                      return WillPopScope(
                          child: Container(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          onWillPop: () async => false);
                    } else if (value["state"] == 1 && isPopup == false) {
                      Future.delayed(Duration.zero, () {
                        Navigator.pop(context);
                      });
                      return WillPopScope(
                          child: Container(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          onWillPop: () async => false);
                    } else if (value["state"] == 1 && isPopup == true) {
                      return AlertDialog(
                        title: Text(value["message"]),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {});
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
        .then((value) =>
            _employeeInfoLoading.value = {"state": 0, "message": ""});
  }
}
