import 'dart:convert';
import 'dart:io' as Io;

import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../all_widgets/drawer.dart';
import '../../../constants/colors.dart';

class AddProduct extends StatefulWidget {
  AddProduct({
    Key? key,
  }) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productName = TextEditingController(text: "");
  TextEditingController productPrice = TextEditingController();
  final ValueNotifier<Map> _addProdLoading = ValueNotifier<Map>({"state": 0, "message": ""});
  String imageUrl = "";
  final formKey = GlobalKey<FormState>();
  PickedFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    Map? arg = ModalRoute.of(context)!.settings.arguments as Map?;
    if (productName.text == "" && arg != null) {
      productName.text = arg == null ? productName.text : arg["name"];
      imageUrl = arg == null ? "" : arg["photo"];
    }
    print(productName);
    return Form(
      key: formKey,
      child: Scaffold(
          // floatingActionButton: FloatingActionButton.extended(
          //   label: Container(
          //       width: MediaQuery.of(context).size.width * 0.6,
          //       child: const Center(
          //           child: Text(
          //         "Ürün Ekle",
          //         style: TextStyle(fontSize: 17),
          //       ))),
          //   onPressed: () async {
          //     if (formKey.currentState!.validate()) {
          //       if (imageFile != null) {
          //         final bytes = Io.File(imageFile!.path).readAsBytesSync();
          //         String img64 = base64Encode(bytes);
          //         print(img64);
          //         addProductList(productName.text.trim().toUpperCase(),
          //             productPrice.text.trim().toUpperCase(), img64);
          //         showAddProdDialog();
          //       } else if (imageUrl != "" && imageUrl != null) {
          //         addProductList(productName.text.trim().toUpperCase(),
          //             productPrice.text.trim().toUpperCase(), imageUrl);
          //         showAddProdDialog();
          //       } else {
          //         showDialog(
          //             context: context,
          //             builder: (BuildContext context) {
          //               return AlertDialog(
          //                 title: const Text(
          //                     "Lütfen ürün için bir fotoğraf yükleyiniz."),
          //                 actions: [
          //                   TextButton(
          //                       onPressed: () {
          //                         Navigator.pop(context);
          //                       },
          //                       child: const Text("Kapat"))
          //                 ],
          //               );
          //             });
          //       }
          //     }
          //   },
          //   backgroundColor: crimsonColor,
          // ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            title: const Text("Ürün Ekle"),
            elevation: 0.0,
            backgroundColor: crimsonColor,
          ),
          drawer: WidgetDrawer(
            drawerType: 1,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: (() {
                      showModalBottomSheet(
                          context: context,
                          builder: (builder) => bottomSheet());
                    }),
                    child: const Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.add_a_photo,
                          size: 35,
                        )),
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(image: decorationImage())),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 10.0),
                  child: TextFormField(
                    controller: productName,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: crimsonColor),
                      ),
                      labelText: "Ürünün Adı",
                      labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Lütfen ürün adı giriniz";
                      }
                    },
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 10.0),
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,2}'))
                    ],
                    controller: productPrice,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: crimsonColor),
                        ),
                        labelText: "Ürünün Fiyatı",
                        labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Lütfen ürün fiyatı giriniz";
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: crimsonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (imageFile != null) {
                        final bytes =
                            Io.File(imageFile!.path).readAsBytesSync();
                        String img64 = base64Encode(bytes);
                        print(img64);
                        addProductList(productName.text.trim().toUpperCase(),
                            productPrice.text.trim().toUpperCase(), img64);
                        showAddProdDialog();
                      } else if (imageUrl != "" && imageUrl != null) {
                        addProductList(productName.text.trim().toUpperCase(),
                            productPrice.text.trim().toUpperCase(), imageUrl);
                        showAddProdDialog();
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    "Lütfen ürün için bir fotoğraf yükleyiniz."),
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
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: const Center(
                          child: Text(
                        "Ürün Ekle",
                        style: TextStyle(fontSize: 17),
                      ))),
                )
                // FloatingActionButton.extended(
                //   label: Container(
                //       width: MediaQuery.of(context).size.width * 0.6,
                //       child: const Center(
                //           child: Text(
                //         "Ürün Ekle",
                //         style: TextStyle(fontSize: 17),
                //       ))),
                //   ,
                //   backgroundColor: crimsonColor,
                // ),
              ],
            ),
          )),
    );
  }

  Future addProductList(productName, productPrice, imageUrl) async {
    try {
      var response = await Dio().post(AppUrl.addProd,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "productName": productName,
            "photo": imageUrl,
            "price": productPrice,
            "discount": 0,
            "isDiscounted": true
          }).then((value) {
        _addProdLoading.value = {"state": 1, "message": "Ürün kaydedildi"};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.addProd,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "productName": productName,
                  "photo": imageUrl,
                  "price": productPrice,
                  "discount": 0,
                  "isDiscounted": true
                }).then((value) {
              _addProdLoading.value = {
                "state": 1,
                "message": "Ürün kaydedildi"
              };
            });
          } on DioError catch (e) {
            _addProdLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _addProdLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  ImageProvider<Object> decorationImage() {
    if (imageFile != null) {
      return FileImage(Io.File(imageFile!.path)) as ImageProvider;
    } else if (imageUrl != null && imageUrl != "") {
      return NetworkImage(imageUrl);
    } else {
      return const AssetImage("assets/indir.jpg");
    }
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      imageFile = pickedFile!;
    });
  }

  Widget bottomSheet() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text("Ürün fotoğrafı için seçin."),
          const SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera")),
              ElevatedButton.icon(
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Telefon Galerisi")),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, "/smeproductphotos");
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Uygulama Galerisi")),
            ],
          )
        ],
      ),
    );
  }

  showAddProdDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _addProdLoading,
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
        }).then((value) => _addProdLoading.value = {"state": 0, "message": ""});
  }
}
