import 'dart:async';

import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../all_widgets/drawer.dart';

class EditSmeProduct extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditSmeProduct();
  }
}

class _EditSmeProduct extends State {
  final ValueNotifier<String> _searchTextNotify = ValueNotifier<String>("");
  final ValueNotifier<Map> _sortingUpdate =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   label: Container(
      //       width: MediaQuery.of(context).size.width * 0.6,
      //       child: const Center(
      //           child: Text(
      //         "Ürün Ekle",
      //         style: TextStyle(fontSize: 17),
      //       ))),
      //   onPressed: () {
      //   },
      //   // shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //   backgroundColor: crimsonColor,
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
        title: const Text(
          "Menü Düzenle",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: 'Roboto'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: WidgetDrawer(
        drawerType: 1,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20.0),
        height: MediaQuery.of(context).size.height * 1.3,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  elevation: 8,
                  child: Container(
                    height: 50.0,
                    width: 380,
                    child: TextField(
                      onChanged: ((value) {
                        _searchTextNotify.value = value;
                      }),
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Ürünleri sola kaydırarak ürün düzeltme ve ürün silme özelliklerine ulaşabilirsiniz. Ayrıca ürünlerin üzerine basılı tutarak ürün sırasını değiştirebilirsiniz bu sayede kullanıcılarınız ürünlerinizi sizin istediğiniz sırada görecektir.",
                    style: TextStyle(color: crimsonColor),
                  ),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 10.0, right: 10.0),
                  child: FutureBuilder(
                      future: getProductList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Bir şeyler yanlış gitti');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.data == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        Map<String, dynamic> data =
                            snapshot.data.data as Map<String, dynamic>;
                        if (data["data"] == null) {
                          return Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: const Center(
                                child: Text(
                                    "Menünüzde hiç ürün bulunmuyor. Menünüze ürünlerinizi eklemek için ana sayfadaki ürün ekle sayfasına gidiniz."),
                              ));
                        }
                        List productList = data["data"]["productList"];
                        return ValueListenableBuilder(
                            valueListenable: _searchTextNotify,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              if (value != "" && value != null) {
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: productList.length,
                                  itemBuilder: (context, index) {
                                    double orderPrice = productList[index]
                                                    ["price"]
                                                .runtimeType ==
                                            int
                                        ? productList[index]["price"].toDouble()
                                        : productList[index]["price"];
                                    if (productList[index]["productName"]
                                        .contains(value.toUpperCase())) {
                                      print(productList[index]);
                                      return buildProductList(
                                          productList[index]["id"],
                                          productList[index]["photo"],
                                          productList[index]["productName"],
                                          orderPrice,
                                          productList[index]["sorting"]);
                                    } else {
                                      return Container();
                                    }
                                  },
                                );
                              }
                              return ValueListenableBuilder(
                                  valueListenable: _sortingUpdate,
                                  builder: (BuildContext context,
                                      Map updateLoading, Widget? child) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      child: ReorderableListView.builder(
                                        // physics: NeverScrollableScrollPhysics(),
                                        // shrinkWrap: true,
                                        onReorder:
                                            (int oldIndex, int newIndex) {
                                          int newsort =
                                              productList[newIndex]["sorting"];
                                          int prodId =
                                              productList[oldIndex]["id"];
                                          productSortUpdate(newsort, prodId);
                                          showSortingUpdateDialog();
                                          print("burdaydı00");
                                          print(updateLoading["state"]);
                                          Timer(const Duration(seconds: 1), () {
                                            if (updateLoading["state"] == 0) {
                                              print(
                                                  "geldiiiiiiiiiiiiiiiiiiiii");
                                              setState(() {});
                                              _sortingUpdate.value = {
                                                "state": 1,
                                                "message":
                                                    "Ürün sıralaması güncellendi."
                                              };
                                            }
                                          });
                                        },
                                        itemCount: productList.length,
                                        itemBuilder: (context, index) {
                                          double orderPrice = productList[index]
                                                          ["price"]
                                                      .runtimeType ==
                                                  int
                                              ? productList[index]["price"]
                                                  .toDouble()
                                              : productList[index]["price"];
                                          return buildProductList(
                                              productList[index]["id"],
                                              productList[index]["photo"] ??
                                                  "https://www.technopat.net/sosyal/eklenti/images-14-jpeg.816802/",
                                              productList[index]["productName"],
                                              orderPrice,
                                              productList[index]["sorting"]);
                                        },
                                      ),
                                    );
                                  });
                            });
                      }),
                )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                )
              ]),
        ),
      ),
    );
  }

  Widget buildProductList(
      int id, String imageUrl, String productName, double price, int sorting) {
    return Slidable(
      key: Key(id.toString()),
      endActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
          onPressed: (BuildContext context) {
            showProdEdit(
              id,
              productName,
              price,
              "",
            );
          },
          icon: Icons.edit,
          backgroundColor: exColor,
        ),
        SlidableAction(
          onPressed: (BuildContext context) {
            productDelete(id);
            showSortingUpdateDialog();
          },
          icon: Icons.cancel,
          backgroundColor: crimsonColor,
        ),
      ]),
      child: Card(
        key: ValueKey(id.toString()),
        child: Row(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.3,
                child: Image.network(imageUrl)),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              margin: const EdgeInsets.only(top: 5.0, left: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(productName,
                      style:
                          const TextStyle(fontSize: 20, fontFamily: 'Roboto')),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Text(
                    "₺ ${price.toStringAsFixed(2).toString()}",
                    style: const TextStyle(
                        color: Color(0xFF654B2A),
                        fontSize: 20,
                        fontFamily: 'Roboto'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showSortingUpdateDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _sortingUpdate,
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
        }).then((value) {
      setState(() {});
      _sortingUpdate.value = {"state": 0, "message": ""};
    });
  }

  Future getProductList() async {
    try {
      var response = await Dio().post(AppUrl.prodList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            // "dealerId": "Musa'nın yeri",
            // "search": "string",
            // "normalizedSearch": "string"
          });
      print(response);
      return response;
    } on DioError catch (e) {
      print(e.response!.data);
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          print("Burdayım $value");
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.prodList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "dealerId": "Musa'nın yeri",
          //         // "search": "string",
          //         // "normalizedSearch": "string"
          //       });
          //   print("buradayım 2");
          //   print(response);
          //   setState(() {});
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

  showProdEdit(int id, String productName, double price, String photo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _controller1 =
              TextEditingController(text: productName);
          TextEditingController _controller2 =
              TextEditingController(text: price.toStringAsFixed(2).toString());
          return AlertDialog(
            title: Column(
              children: [
                const Text("Ürün Güncelle"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controller1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,2}'))
                    ],
                    // initialValue: price.toString(),
                    controller: _controller2,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    productEdit(id, _controller1.text,
                        double.parse(_controller2.text), "", price);
                    Navigator.pop(context);
                  },
                  child: const Text("Kaydet"))
            ],
          );
        });
  }

  // showProdDel(int id, int sorting) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           actionsPadding: EdgeInsets.zero,
  //           title: const Text("Ürün Sil"),
  //           content:
  //               Text("Ürünü silmek istediğinize emin misiniz? $id $sorting"),
  //           actions: [
  //             ElevatedButton(
  //                 onPressed: () {
  //                   productDelete(
  //                     id,
  //                   );
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("Sil")),
  //             ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("Kapat")),
  //           ],
  //         );
  //       });
  // }

  Future productEdit(int id, String productName, double price, String photo,
      double afterPrice) async {
    print(
        "tokennnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ${Hive.box("userbox").get("kod").toString()}");
    try {
      var response = await Dio().post(AppUrl.prodEdit,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "productId": id,
            "productName": productName,
            // "photo": photo,
            "price": price,
            "discount": 0,
            "isDiscounted": false,
          });
      print(response);
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.prodEdit,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "productId": id,
                  "productName": productName,
                  // "photo": photo,
                  "price": price,
                  "discount": 0,
                  "isDiscounted": false,
                });
            print(response);
            return response;
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

  Future productDelete(int productId) async {
    try {
      var response = await Dio().post(AppUrl.prodRemove,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "dealerId": Hive.box("userbox").get("kod"),
            "productId": productId
          }).then((value) {
        _sortingUpdate.value = {"state": "1", "message": "Ürün Silindi."};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.prodRemove,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "dealerId": Hive.box("userbox").get("kod"),
                  "productId": productId
                }).then((value) {
              _sortingUpdate.value = {"state": "1", "message": "Ürün Silindi."};
            });
          } on DioError catch (e) {
            _sortingUpdate.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _sortingUpdate.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Future productSortUpdate(int sort, int productId) async {
    try {
      var response = await Dio().post(AppUrl.productSortUpdate,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "dealerId": Hive.box("userbox").get("kod").toString(),
            "productId": productId,
            "sort": sort,
            "isGonnaPush": true
          }).then((value) => print(value));
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.productSortUpdate,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "dealerId": Hive.box("userbox").get("kod").toString(),
                  "productId": productId,
                  "sort": sort,
                  "isGonnaPush": true
                }).then((value) => print(value));
          } on DioError catch (e) {
            _sortingUpdate.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _sortingUpdate.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }
}
