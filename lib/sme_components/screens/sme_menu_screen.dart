import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'dart:convert';
import 'dart:io' as Io;

class SmeMenuScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SmeMenuScreenState();
  }
}

class _SmeMenuScreenState extends State {
  TextEditingController name = TextEditingController(
      text: Hive.box("userbox").get("dealerName").toString());
  PickedFile? imageFile;
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<Map> _dealerInfoLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  bool? isSwitched = Hive.box("userbox").get("isOpen");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: crimsonColor,
        body: SafeArea(
          child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/backgroudimage.png"),
                    alignment: Alignment.bottomCenter),
              ),
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(top: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: Stack(
                        children: [
                          CircleAvatar(
                              radius: 70.0,
                              backgroundColor: whiteColor,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Hive.box("userbox").get("dealerName").toString(),
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
                            updateKobiName(name);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "İşyeri Aç/Kapa",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          Hive.box("userbox").get("isOpen") ? "Açık" : "Kapalı",
                          style: const TextStyle(
                              color: Colors.yellowAccent, fontSize: 25),
                        ),
                        Switch(
                            value: isSwitched!,
                            onChanged: (value) {
                              setState(() {
                                isOpenUpdate(value);
                                showSmeInfoDialog(true);
                                isSwitched = value;
                                print(isSwitched);
                              });
                            })
                      ],
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Siparişler",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, "/smeorders");
                      },
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
                      onTap: () => Navigator.pushNamed(context, "/smeqr"),
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Kendi Ürününü Ekle",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/smeaddproduct"),
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Sabit Ürünlerden Ekle",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/smeproductphotos"),
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Menü",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/product_edit"),
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
                      onTap: () => Navigator.pushNamed(context, "/smereports"),
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Tahsilat",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/smepaymenttake"),
                    ),
                    ListTile(
                      title: const Center(
                        child: Text(
                          "Müşteriler",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.98,
                              color: Colors.white),
                        ),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/smecostumers"),
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
                      },
                    ),
                  ],
                ),
              )),
        ));
  }

  profilePhoto() {
    if (imageFile == null && Hive.box("userbox").get("dealerPhoto") != null) {
      return NetworkImage(Hive.box("userbox").get("dealerPhoto").toString());
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
    showSmeInfoDialog(false);
    setState(() {
      imageFile = pickedFile;
    });
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
                  label: const Text("Galleri"))
            ],
          )
        ],
      ),
    );
  }

  updateKobiName(TextEditingController name) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text("Çay Ocağı Adı Güncelle")),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: name,
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  onPressed: () async {
                    Navigator.pop(context);
                    showSmeInfoDialog(false);
                    try {
                      var response = await Dio().post(AppUrl.setSettings,
                          options: Options(headers: {
                            "Authorization":
                                "Bearer ${Hive.box("userbox").get("token").toString()}",
                            "Content-Type": "application/json"
                          }),
                          data: {
                            "companyName": name.text.toString()
                          }).then((value) {
                        setState(() {});
                        _dealerInfoLoading.value = {
                          "state": 1,
                          "message": "Çay ocağınızın ismi güncellenmiştir."
                        };
                        Hive.box("userbox").put("dealerName", name.text);
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
                                data: {
                                  "companyName": name.text.toString()
                                }).then((value) {
                              setState(() {});
                              _dealerInfoLoading.value = {
                                "state": 1,
                                "message":
                                    "Çay ocağınızın ismi güncellenmiştir."
                              };
                              Hive.box("userbox").put("dealerName", name.text);
                            });
                          } on DioError catch (e) {
                            _dealerInfoLoading.value = {
                              "state": 2,
                              "message": "${e.response!.data["message"]}"
                            };
                          }
                        });
                      } else {
                        _dealerInfoLoading.value = {
                          "state": 2,
                          "message": "${e.response!.data["message"]}"
                        };
                      }
                    }
                  },
                  child: const Text(
                    "Kaydet",
                  ))
            ],
          );
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
            _dealerInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _dealerInfoLoading.value = {
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
        _dealerInfoLoading.value = {
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
              _dealerInfoLoading.value = {
                "state": 1,
                "message": "Profil resmi güncellendi."
              };
            });
          } on DioError catch (e) {
            _dealerInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _dealerInfoLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Future isOpenUpdate(bool isOpen) async {
    try {
      var response = await Dio().post(AppUrl.setDealerSettings,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"isOpen": isOpen}).then((value) {
        isOpenFonk();
        _dealerInfoLoading.value = {"state": 1, "message": "İşlem Başarılı"};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.setDealerSettings,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"isOpen": isOpen}).then((value) {
              _dealerInfoLoading.value = {
                "state": 1,
                "message": "İşlem Başarılı"
              };
            });
          } on DioError catch (e) {
            _dealerInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _dealerInfoLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Future isOpenFonk() async {
    try {
      var response = await Dio().post(AppUrl.dealerSettingsInfo,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {}).then((value) {
        print(value);
        Hive.box("userbox").put("isOpen", value.data["data"]["isOpen"]);
        print(Hive.box("userbox").get("isOpen"));
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.dealerSettingsInfo,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {}).then((value) {
              Hive.box("userbox").put("isOpen", value.data["data"]["isOpen"]);
            });
          } on DioError catch (e) {
            _dealerInfoLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _dealerInfoLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showSmeInfoDialog(bool isPopup) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _dealerInfoLoading,
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
                  //   Future.delayed(Duration.zero, () {
                  //     Navigator.pop(context);
                  //   });
                  //   return WillPopScope(
                  //       child: Container(
                  //         child: const Center(
                  //           child: CircularProgressIndicator(),
                  //         ),
                  //       ),
                  //       onWillPop: () async => false);
                  // } else if (value["state"] == 1 && isPopup == true) {
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
        }).then((value) {
      _dealerInfoLoading.value = {"state": 0, "message": ""};
      if (isPopup == true) {
        setState(() {});
      }
    });
  }
}
