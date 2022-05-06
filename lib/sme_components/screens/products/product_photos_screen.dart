import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../all_widgets/drawer.dart';
import '../../../constants/colors.dart';

class ProductPhoto extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductPhotoState();
  }
}

class _ProductPhotoState extends State {
  PickedFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<String> _searchTextNotify = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
        title: const Text("Ürünlerim"),
      ),
      drawer: WidgetDrawer(
        drawerType: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                height: 50.0,
                width: 380,
                child: Material(
                  elevation: 8,
                  child: TextField(
                    onChanged: ((value) {
                      _searchTextNotify.value = value.trim().toUpperCase();
                      print("text nedir $value");
                    }),
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Arama',
                      hintStyle: TextStyle(
                        color: exColor,
                      ),
                      suffixIcon: Icon(
                        Icons.search,
                        color: exColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder(
                  future: getProductImageGallery(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Bir şeyler yanlış gitti');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    Map<String, dynamic> data =
                        snapshot.data.data as Map<String, dynamic>;
                    if (data["data"] == null) {
                      return Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: const Center(
                            child: Text(
                                "Şuan ürün fotoğrafı desteği verememekteyiz. Lütfen daha sonra tekrar deneyiniz."),
                          ));
                    }
                    List prodPhotoAndName = data["data"];
                    return ValueListenableBuilder(
                        valueListenable: _searchTextNotify,
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          print("değişkene atanan text nedir? $value");
                          if (value == "" || value == null) {
                            return GridView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemCount: prodPhotoAndName.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    showProd(
                                        prodPhotoAndName[index]["imageUrl"],
                                        prodPhotoAndName[index]["imageName"]
                                            .toUpperCase());
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: Image(
                                          image: NetworkImage(
                                              prodPhotoAndName[index]
                                                  ["imageUrl"]),
                                        ),
                                        color: Colors.black12,
                                      ),
                                      Text(prodPhotoAndName[index]["imageName"]
                                          .toUpperCase())
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: prodPhotoAndName.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (prodPhotoAndName[index]["imageName"]
                                      .toString()
                                      .toUpperCase()
                                      .contains(value)) {
                                    return Card(
                                      child: ListTile(
                                        onTap: () {
                                          showProd(
                                              prodPhotoAndName[index]
                                                  ["imageUrl"],
                                              prodPhotoAndName[index]
                                                      ["imageName"]
                                                  .toUpperCase());
                                        },
                                        leading: Image(
                                          image: NetworkImage(
                                              prodPhotoAndName[index]
                                                  ["imageUrl"]),
                                        ),
                                        title: Text(prodPhotoAndName[index]
                                                ["imageName"]
                                            .toUpperCase()),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                });
                          }
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }

  showProd(String photo, String name) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Image(
              image: NetworkImage(photo),
            ),
            content: Text(name, textAlign: TextAlign.center),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        "/smeaddproduct", ModalRoute.withName("/smemenu"),
                        arguments: {"photo": photo, "name": name});
                  },
                  child: const Text("Ürünü Menüye Ekle")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Kapat")),
            ],
          );
        });
  }

  Future getProductImageGallery() async {
    try {
      var response = await Dio().post(AppUrl.getProductImageGallery,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {});
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.getProductImageGallery,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {});
          //   return response;
          // } on DioError catch (e) {
          //   showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text("${e.response!.data["message"]}"),
          //           actions: [
          //             TextButton(
          //                 onPressed: () {
          //                   Navigator.pop(context);
          //                 },
          //                 child: const Text("Kapat"))
          //           ],
          //         );
          //       });
          // }
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
}
