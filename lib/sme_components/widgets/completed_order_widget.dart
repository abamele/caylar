import 'dart:convert';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WidgetCompletedOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetCompletedOrder();
  }
}

class _WidgetCompletedOrder extends State {
  List orderTime = ["15 dk", "30 dk", "60 dk", "1 gün", "1 hafta"];
  final ValueNotifier<int> selectButton = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      fitreOrderWidget(1, orderTime[0]),
                      fitreOrderWidget(2, orderTime[1]),
                      fitreOrderWidget(3, orderTime[2]),
                      fitreOrderWidget(4, orderTime[3]),
                      fitreOrderWidget(5, orderTime[4]),
                    ],
                  )),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text("Sipariş Veren"),
                  Text("Ürün Adı"),
                  Text("Adet")
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder(
                  valueListenable: selectButton,
                  builder: (BuildContext context, int value, Widget? child) {
                    int lastminute = 1440;
                    if (value == 0) {
                      lastminute = 1440;
                    } else if (value == 1) {
                      lastminute = 15;
                    } else if (value == 2) {
                      lastminute = 30;
                    } else if (value == 3) {
                      lastminute = 60;
                    } else if (value == 4) {
                      lastminute = 1440;
                    } else if (value == 5) {
                      lastminute = 10080;
                    } else {
                      lastminute = 1440;
                    }
                    return FutureBuilder(
                        future: orderHistoryRequest(lastminute),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                          Map compOrders = data["data"];
                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: compOrders["orders"].length,
                              itemBuilder: (BuildContext context, index) {
                                return buildDataTable(
                                    compOrders["orders"][index], index);
                              });
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget fitreOrderWidget(int index, String orderTime) {
    return ValueListenableBuilder(
      valueListenable: selectButton,
      builder: (BuildContext context, int value, Widget? child) {
        return Padding(
          padding: EdgeInsets.all(4),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 15,
                  primary: value == index ? exColor : whiteColor,
                  minimumSize: Size(20, 35)),
              onPressed: () {
                selectButton.value = index;
                print(selectButton);
                setState(() {});
              },
              child: Text(
                orderTime,
                style: TextStyle(color: value == index ? whiteColor : exColor),
              )),
        );
      },
    );
  }

  Widget buildDataTable(Map orderInfo, index) {
    List ordersDetails = orderInfo["orderDetails"];
    double orderPrice = orderInfo["orderPrice"].runtimeType == int
        ? orderInfo["orderPrice"].toDouble()
        : orderInfo["orderPrice"];
    return
        // Dismissible(
        //   background: Container(
        //     color: Colors.white,
        //     child: const Icon(
        //       Icons.delete,
        //       color: Colors.red,
        //     ),
        //     alignment: Alignment.centerLeft,
        //   ),
        //   direction: DismissDirection.startToEnd,
        //   key: Key(index.toString()),
        //   onDismissed: (direction) {
        //     // sil
        //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //         content: ListTile(
        //       title: Text("Duyuru Silindi!", style: TextStyle(color: Colors.red)),
        //       // trailing: TextButton(
        //       //   onPressed: () {},
        //       //   child: Text("Geri Al"),
        //       // ),
        //     )));
        //   },
        Card(
            elevation: 10,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    height: 56 + (ordersDetails.length * 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Hive.box("userbox").get("dealerName").toString()),
                        Text(orderInfo["employeeName"].toString())
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ordersDetails.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(ordersDetails[index]["productName"]
                                          .toString()),
                                      Text(ordersDetails[index]["quantity"]
                                          .toString())
                                    ],
                                  ),
                                  const Divider(),
                                ],
                              );
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Toplam Tutar:"),
                            const SizedBox(
                              width: 5,
                            ),
                            Text("₺ ${orderPrice.toStringAsFixed(2)}")
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ));
  }

  Future orderHistoryRequest(lastMinutes) async {
    try {
      var response = await Dio().post(AppUrl.orderHistory,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"lastMinutes": lastMinutes, "status": 2});
      print(response);
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.orderHistory,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {"lastMinutes": lastMinutes, "status": 2});
          //   print(response);
          //   return response;
          // } on DioError catch (e) {
          //   showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text("${e.response!.data}"),
          //         );
          //       });
          // }
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("${e.response!.data}"),
              );
            });
      }
    }
  }
}
