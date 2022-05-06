import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AwaitAndCancelOrders extends StatefulWidget {
  late int UserType;
  AwaitAndCancelOrders({Key? key, required this.UserType}) : super(key: key);

  @override
  State<AwaitAndCancelOrders> createState() => _AwaitAndCancelOrdersState();
}

class _AwaitAndCancelOrdersState extends State<AwaitAndCancelOrders> {
  final ValueNotifier<Map> _orderCancelLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Siparişlerim"),
        backgroundColor: crimsonColor,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: WidgetDrawer(drawerType: widget.UserType),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    color: crimsonColor,
                    child: Center(
                      child: Text(
                        "Bekleyen Siparişlerim",
                        style: TextStyle(color: whiteColor, fontSize: 20),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45 - 40,
                  child: FutureBuilder(
                      future: getAwaitOrderList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Bir şeyler yanlış gitti');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        Map<String, dynamic> data =
                            snapshot.data.data as Map<String, dynamic>;
                        if (data["data"] == null) {
                          return const Center(
                            child: Text(
                                "Son 24 saat içerisinde bekleyen siparişiniz bulunmuyor."),
                          );
                        }
                        List awaitOrders = data["data"]["orders"];
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: awaitOrders.length,
                          itemBuilder: (BuildContext context, int index) {
                            List awaitOrderDetails =
                                data["data"]["orders"][index]["orderDetails"];
                            return Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: exColor, width: 2),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                      height: 20,
                                      color: exColor,
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "${data["data"]["orders"][index]["dealerName"]}",
                                            style: TextStyle(color: whiteColor),
                                          ),
                                          Text(
                                            "${data["data"]["orders"][index]["orderPrice"]} ₺",
                                            style: TextStyle(color: whiteColor),
                                          ),
                                        ],
                                      )),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: awaitOrderDetails.length,
                                    itemBuilder:
                                        (BuildContext context, int index2) {
                                      return ListTile(
                                        title: Text(awaitOrderDetails[index2]
                                            ["productName"]),
                                        trailing: TextButton(
                                            onPressed: awaitOrderDetails[index2]
                                                        ["status"] ==
                                                    3
                                                ? null
                                                : () {
                                                    orderCancelRequest(
                                                        awaitOrderDetails[
                                                                index2]
                                                            ["orderDetailId"]);
                                                    showOrderCancelDialog();
                                                  },
                                            child: Text(
                                                awaitOrderDetails[index2]
                                                            ["status"] ==
                                                        3
                                                    ? "İptal Talebi Oluşturuldu"
                                                    : "İptal Talebi Oluştur")),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                )
              ],
            )),
            Container(
                child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    color: crimsonColor,
                    child: Center(
                      child: Text(
                        "İptal Edilen Siparişlerim",
                        style: TextStyle(color: whiteColor, fontSize: 20),
                      ),
                    )),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: const Center(child: Text("Ürün"))),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Center(child: Text("Adet")),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Center(child: Text("Sipariş Saati")),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Center(child: Text("İptal Saati")),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40 - 40,
                  child: FutureBuilder(
                      future: getCancelOrderList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Bir şeyler yanlış gitti');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        Map<String, dynamic> data =
                            snapshot.data.data as Map<String, dynamic>;
                        if (data["data"] == null) {
                          return const Center(
                            child: Text(
                                "Son 24 saat içerisinde iptal edilen siparişiniz bulunmuyor."),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: data["data"]["reports"].length,
                          itemBuilder: (BuildContext context, int index) {
                            print(data["data"]["reports"].length.toString());
                            return Card(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    child: Center(
                                      child: Text(data["data"]["reports"][index]
                                          ["productName"]),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    child: Center(
                                      child: Text(data["data"]["reports"][index]
                                              ["quantity"]
                                          .toString()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    child: Center(
                                      child: Text(data["data"]["reports"][index]
                                              ["orderDate"]
                                          .toString()
                                          .substring(11, 16)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    child: Center(
                                      child: Text(data["data"]["reports"][index]
                                              ["canceledOn"]
                                          .toString()
                                          .substring(11, 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                          },
                        );
                      }),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future getAwaitOrderList() async {
    try {
      var response = await Dio().post(AppUrl.waitingOrders,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {});
      print(
          "aaaaaaaaaaaaaanaafaşnanşaşL $response           teeeeeeeeeeeeeeeee");
      return response;
    } on DioError catch (e) {
      print(e.response!.data);
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

  Future getCancelOrderList() async {
    try {
      var response = await Dio().post(AppUrl.canceledOrders,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {});
      print(
          "aaaaaaaaaaaaaanaafaşnanşaşL $response           teeeeeeeeeeeeeeeee");
      return response;
    } on DioError catch (e) {
      print(e.response!.data);
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

  Future orderCancelRequest(int orderDetailId) async {
    try {
      var response = await Dio().post(AppUrl.orderCancelRequest,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"orderDetailId": orderDetailId}).then((value) {
        _orderCancelLoading.value = {
          "state": 1,
          "message": "İptal Talebi Oluşturuldu"
        };
      });
    } on DioError catch (e) {
      print(e.response!.data);
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.orderCancelRequest,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"orderDetailId": orderDetailId}).then((value) {
              _orderCancelLoading.value = {
                "state": 1,
                "message": "İptal Talebi Oluşturuldu"
              };
            });
          } on DioError catch (e) {
            _orderCancelLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _orderCancelLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showOrderCancelDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _orderCancelLoading,
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
      _orderCancelLoading.value = {"state": 0, "message": ""};
      setState(() {});
    });
  }
}
