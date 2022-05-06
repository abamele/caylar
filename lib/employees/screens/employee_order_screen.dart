import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/models/order_screen_counter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:line_icons/line_icons.dart';

import '../../all_widgets/drawer.dart';

class EmployeeOrderScreen extends StatefulWidget {
  late List dealerList;
  EmployeeOrderScreen({Key? key, required this.dealerList}) : super(key: key);

  @override
  _EmployeeOrderScreenState createState() => _EmployeeOrderScreenState();
}

class _EmployeeOrderScreenState extends State<EmployeeOrderScreen> {
  final ValueNotifier<double> totalPrice = ValueNotifier<double>(0.0);
  final ValueNotifier<String> _searchTextNotify = ValueNotifier<String>("");
  List<Map> orderList = List.generate(100, (int index) => {});
  TextEditingController orderNote = TextEditingController(text: "");
  int _value = 0;
  final ValueNotifier<Map> _orderLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  dealersOfPersonList() {
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List dealersOfPerson = widget.dealerList;
    for (var i = 0; i < dealersOfPerson.length; i++) {
      print("bababbabababab ${dealersOfPerson[i].toString()}");
      dropdownItemList.add(
        DropdownMenuItem(
          child: Text(
            dealersOfPerson[i]["name"].toString(),
            style: TextStyle(color: whiteColor),
          ),
          value: i,
        ),
      );
    }
    return dropdownItemList;
  }

  @override
  void initState() {
    // TODO: implement initState
    orderCounterNotify
        .onCleanOrderCounter(List<int>.generate(100, (int index) => 0));

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    orderCounterNotify
        .onCleanOrderCounter(List<int>.generate(100, (int index) => 0));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dealerList == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Sipariş Ver"),
          backgroundColor: crimsonColor,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        drawer: WidgetDrawer(drawerType: 3),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const Text(
                "Uygulamaya personel olarak kayıt yapmış olduğunuzdan sipariş vermek için firma yetkilileriyle iletişime geçiniz."),
          ),
        ),
      );
    } else {
      return Scaffold(
          // backgroundColor: Color(0xFFEFEFEF),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: crimsonColor,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh))
            ],
            title: DropdownButton(
                iconDisabledColor: whiteColor,
                iconEnabledColor: whiteColor,
                dropdownColor: crimsonColor,
                menuMaxHeight: 100,
                value: _value,
                items: dealersOfPersonList(),
                onChanged: (int? value) {
                  _value = value!;
                  orderCounterNotify.onCleanOrderCounter(
                      List<int>.generate(100, (int index) => 0));
                  totalPrice.value = 0;
                  setState(() {});
                },
                hint: const Text("Çay Ocağı Seçiniz")),
          ),
          drawer: WidgetDrawer(drawerType: 3),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Stack(children: [
                  Column(
                    children: [
                      Container(
                        height: 75,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: ((value) {
                              _searchTextNotify.value = value.toUpperCase();
                            }),
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'Arama',
                              hintStyle: TextStyle(
                                color: exColor,
                              ),
                              suffixIcon: Icon(
                                LineIcons.search,
                                color: exColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: constraints.maxHeight - 133,
                          child: FutureBuilder(
                              future: getProductList(widget.dealerList[_value]),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Bir şeyler yanlış gitti');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (widget.dealerList[_value]["dealerSettings"]
                                        ["isOpen"] ==
                                    false) {
                                  return const Center(
                                    child: Text(
                                        "Çay ocağı şuan kapalı olduğundan sipariş veremezsiniz."),
                                  );
                                }
                                if (snapshot.data == null) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                Map<String, dynamic> data =
                                    snapshot.data.data as Map<String, dynamic>;
                                List productList = data["data"]["productList"];
                                double balance =
                                    data["data"]["balance"].runtimeType == int
                                        ? data["data"]["balance"].toDouble()
                                        : data["data"]["balance"];
                                return ValueListenableBuilder(
                                    valueListenable: _searchTextNotify,
                                    builder: (BuildContext context,
                                        String value, Widget? child) {
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Kalan Bakiyeniz: ${balance.toStringAsFixed(2)} ₺",
                                              style: TextStyle(
                                                  fontSize: 22, color: exColor),
                                            ),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: productList.length,
                                                itemBuilder: (context, index) {
                                                  double prodPrice =
                                                      productList[index]
                                                                      ["price"]
                                                                  .runtimeType ==
                                                              int
                                                          ? productList[index]
                                                                  ["price"]
                                                              .toDouble()
                                                          : productList[index]
                                                              ["price"];
                                                  if (productList[index]
                                                          ["productName"]
                                                      .contains(value)) {
                                                    return AspectRatio(
                                                      aspectRatio: 7 / 2,
                                                      child: Card(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            AspectRatio(
                                                              aspectRatio:
                                                                  1 / 1,
                                                              child: Image.network(
                                                                  productList[
                                                                          index]
                                                                      [
                                                                      "photo"]),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      productList[
                                                                              index]
                                                                          [
                                                                          "productName"],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              'Roboto')),
                                                                  ValueListenableBuilder(
                                                                      valueListenable:
                                                                          orderCounterNotify,
                                                                      builder: (BuildContext context,
                                                                          OrderCounter
                                                                              counter,
                                                                          Widget?
                                                                              child) {
                                                                        return Row(
                                                                          children: [
                                                                            Container(
                                                                              width: 33.32,
                                                                              height: 33.34,
                                                                              child: FloatingActionButton(
                                                                                heroTag: "minus$index",
                                                                                backgroundColor: const Color(0xFF8C6F4B),
                                                                                onPressed: () {
                                                                                  double price = double.parse("${productList[index]['price']}");
                                                                                  if (counter.orderCounter[index] > 0) {
                                                                                    totalPrice.value = totalPrice.value - price;
                                                                                  }
                                                                                  orderCounterNotify.discrementCounter(index);
                                                                                  var pureTotalPrice = productList[index]["price"] * counter.orderCounter[index];
                                                                                  pureTotalPrice = pureTotalPrice.runtimeType == int ? pureTotalPrice.toDouble() : pureTotalPrice;
                                                                                  orderList[index] = {
                                                                                    "productId": productList[index]["id"],
                                                                                    "name": productList[index]["productName"],
                                                                                    "productQuantity": counter.orderCounter[index],
                                                                                    "price": productList[index]["price"],
                                                                                    "totalPrice": pureTotalPrice.toStringAsFixed(2)
                                                                                  };
                                                                                  print("son sefer $orderList");
                                                                                },
                                                                                tooltip: 'Increment',
                                                                                elevation: 0.0,
                                                                                child: const Icon(Icons.remove),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10.0,
                                                                            ),
                                                                            Text(
                                                                              "${counter.orderCounter[index]}",
                                                                              style: const TextStyle(color: Colors.grey, fontSize: 16.67, fontFamily: 'Roboto'),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10.0,
                                                                            ),
                                                                            Container(
                                                                              width: 33.32,
                                                                              height: 33.34,
                                                                              child: FloatingActionButton(
                                                                                heroTag: "plus$index",
                                                                                backgroundColor: const Color(0xFF8C6F4B),
                                                                                onPressed: () {
                                                                                  orderCounterNotify.incrementCounter(index);
                                                                                  var pureTotalPrice = productList[index]["price"] * counter.orderCounter[index];
                                                                                  pureTotalPrice = pureTotalPrice.runtimeType == int ? pureTotalPrice.toDouble() : pureTotalPrice;
                                                                                  orderList[index] = {
                                                                                    "productId": productList[index]["id"],
                                                                                    "name": productList[index]["productName"],
                                                                                    "productQuantity": counter.orderCounter[index],
                                                                                    "price": productList[index]["price"],
                                                                                    "totalPrice": pureTotalPrice.toStringAsFixed(2)
                                                                                  };
                                                                                  print("son sefer $orderList");
                                                                                  double price = double.parse("${productList[index]['price']}");
                                                                                  totalPrice.value = totalPrice.value + price;
                                                                                },
                                                                                tooltip: 'Increment',
                                                                                elevation: 0.0,
                                                                                child: const Icon(Icons.add),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                child: Text(
                                                                  "₺ ${prodPrice.toStringAsFixed(2).toString()}",
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xFF8C6F4B),
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'Roboto'),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                }),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              })),
                      ValueListenableBuilder(
                          valueListenable: totalPrice,
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20, top: 10),
                                    child: Text("Toplam",
                                        style: TextStyle(
                                          color: exColor,
                                          fontSize: 20,
                                          fontFamily: "Roboto",
                                        )),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 20, top: 10),
                                    child: Text(
                                      "₺ ${value.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: exColor,
                                          fontSize: 20,
                                          fontFamily: "Roboto"),
                                    ),
                                  )
                                ],
                              ),
                            );
                          })
                    ],
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.06,
                    left: MediaQuery.of(context).size.width * 0.20,
                    child: Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: const Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0))),
                            child: Text(
                              "Sipariş Notu",
                              style: TextStyle(
                                  fontSize: 13.33,
                                  fontFamily: 'Roboto',
                                  color: exColor),
                            ),
                            onPressed: () {
                              showAddOrderNote(orderNote);
                            }),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.06,
                      left: MediaQuery.of(context).size.width * 0.55,
                      child: Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: crimsonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14.0))),
                              child: const Text(
                                "Sipariş Ver",
                                style: TextStyle(
                                    fontSize: 13.33, fontFamily: 'Roboto'),
                              ),
                              onPressed: () {
                                List makeOrderList = [];
                                print("tam siparişten önce $orderList");
                                if (orderList != null) {
                                  for (var i = 0; i < orderList.length; i++) {
                                    print("dön yavrum dö $orderList");
                                    if (orderList[i]["productQuantity"] !=
                                            null &&
                                        orderList[i]["productQuantity"] != 0) {
                                      makeOrderList.add({
                                        "productId": orderList[i]["productId"],
                                        "productQuantity": orderList[i]
                                            ["productQuantity"]
                                      });
                                    }
                                    print(
                                        "aaaaaaaaaaasdffasfdsgdfshsgfjfjhjgfshfdgs$makeOrderList");
                                  }
                                  makeOrder(
                                      makeOrderList, widget.dealerList[_value]);
                                  showOrderDialog();
                                }
                              })
                        ],
                      ))
                ]),
              ),
            );
          }));
    }
  }

  showAddOrderNote(TextEditingController orderNote) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sipariş Notu Ekle"),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLength: 100,
                controller: orderNote,
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Kaydet"))
            ],
          );
        });
  }

  Future getProductList(dealerMap) async {
    String dealerId = dealerMap["id"].toString();
    try {
      var response = await Dio().post(AppUrl.prodList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "dealerId": dealerId,
            // "search": "string",
            // "normalizedSearch": "string"
          });
      print(
          "aaaaaaaaaaaaaanaafaşnanşaşL $response           teeeeeeeeeeeeeeeee");
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
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

  Future makeOrder(List makeOrderList, Map dealerMap) async {
    String dealerId = dealerMap["id"].toString();
    try {
      var response = await Dio().post(AppUrl.makeOrder,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "employeeId": Hive.box("userbox").get("kod").toString(),
            "dealerId": dealerId,
            "orderItems": makeOrderList,
            "note": orderNote.text
          }).then((value) {
        totalPrice.value = 0;
        orderNote.text = "";
        orderList = List.generate(100, (int index) => {});
        orderCounterNotify
            .onCleanOrderCounter(List<int>.generate(100, (int index) => 0));
        _orderLoading.value = {"state": 1, "message": "Sipariş verildi."};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.makeOrder,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "employeeId": Hive.box("userbox").get("kod").toString(),
                  "dealerId": dealerId,
                  "orderItems": makeOrderList,
                  "note": orderNote.text
                }).then((value) {
              totalPrice.value = 0;
              orderNote.text = "";
              orderList = List.generate(100, (int index) => {});
              orderCounterNotify.onCleanOrderCounter(
                  List<int>.generate(100, (int index) => 0));
              _orderLoading.value = {"state": 1, "message": "Sipariş verildi."};
            });
          } on DioError catch (e) {
            _orderLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _orderLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showOrderDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _orderLoading,
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
      _orderLoading.value = {"state": 0, "message": ""};
      setState(() {});
    });
  }
}
