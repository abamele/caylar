import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/models/orderFilter.dart';
import 'package:caylar/sme_components/models/show_order.dart';
import 'package:caylar/sme_components/models/view_size.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WidgetOrder extends StatefulWidget {
  Map waitOrders;
  int selectIndex;
  WidgetOrder({Key? key, required this.waitOrders, required this.selectIndex})
      : super(key: key);

  @override
  _WidgetOrderState createState() => _WidgetOrderState();
}

class _WidgetOrderState extends State<WidgetOrder>
    with TickerProviderStateMixin {
  List orderTime = ["15 dk", "30 dk", "60 dk", "1 gün", "1 hafta"];
  final ValueNotifier<bool> _isShowCancelRequest = ValueNotifier<bool>(false);
  bool deleteOrder = true;
  final ValueNotifier<Map> _orderLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  final scrollControllerList =
      List.generate(1000, (int index) => ScrollController(), growable: true);
  final scrollControllerList2 =
      List.generate(1000, (int index) => ScrollController(), growable: true);
  final keyList =
      List.generate(1000, (int index) => GlobalKey(), growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            buildDataTable(widget.waitOrders)
          ],
        ),
      ),
    );
  }

  Widget fitreOrderWidget(int index, String orderTime) {
    return ValueListenableBuilder(
      valueListenable: waitOrderNotify,
      builder: (BuildContext context, WaitOrder value, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 15,
                  primary: value.selectIndex == index ? exColor : whiteColor,
                  minimumSize: const Size(20, 35)),
              onPressed: () {
                waitOrderNotify.onSelectFilter(index);
              },
              child: Text(
                orderTime,
                style: TextStyle(
                    color: value.selectIndex == index ? whiteColor : exColor),
              )),
        );
      },
    );
  }

  Widget buildDataTable(Map waitOrders) {
    List orders = waitOrders["orders"];

    return Column(
      children: [
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
            valueListenable: _isShowCancelRequest,
            builder:
                (BuildContext context, bool isShowCancelValue, Widget? child) {
              if (waitOrders["anyCancelRequested"]) {
                return InkWell(
                  onTap: () {
                    _isShowCancelRequest.value = !isShowCancelValue;
                  },
                  child: Card(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: MediaQuery.of(context).size.width - 10,
                        height: isShowCancelValue == true ? 400 : 60,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                color: crimsonColor,
                                height: 30,
                                width: MediaQuery.of(context).size.width - 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "İptal Talebi Oluşturulan Siparişler",
                                      style: TextStyle(color: whiteColor),
                                    ),
                                  ),
                                ),
                              ),
                              Icon(isShowCancelValue
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down),
                              const Divider(),
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder: (BuildContext context, index) {
                                    List ordersDetails =
                                        orders[index]["orderDetails"];

                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: ordersDetails.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        if (ordersDetails[index]["status"] !=
                                            3) {
                                          return Container();
                                        } else {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Ürün: ${ordersDetails[index]["productName"].toString()}",
                                                    style: TextStyle(
                                                        color: ordersDetails[
                                                                        index][
                                                                    "status"] ==
                                                                3
                                                            ? crimsonColor
                                                            : Colors.black),
                                                  ),
                                                  Text(
                                                      "Adet: ${ordersDetails[index]["quantity"].toString()}",
                                                      style: TextStyle(
                                                          color: ordersDetails[
                                                                          index]
                                                                      [
                                                                      "status"] ==
                                                                  3
                                                              ? crimsonColor
                                                              : Colors.black)),
                                                  TextButton(
                                                      onPressed: () {
                                                        okProdCancelRequest(
                                                            ordersDetails[index]
                                                                [
                                                                "orderDetailId"]);
                                                        showOrderDialog();
                                                      },
                                                      child: const Text(
                                                          "İptali Onayla"))
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  })
                            ],
                          ),
                        )),
                  ),
                );
              } else {
                return Container();
              }
            }),
        Container(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) {
              List orderDetailIds = [];
              List ordersDetails = orders[index]["orderDetails"];
              print(orders);
              return SingleChildScrollView(
                child: ValueListenableBuilder(
                    valueListenable: showOrderNotify,
                    builder: (BuildContext context, ShowOrder isOrderComplete,
                        Widget? child) {
                      return Dismissible(
                        background: Container(
                          padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.cancel,
                            color: whiteColor,
                          ),
                          color: crimsonColor,
                        ),
                        direction: DismissDirection.startToEnd,
                        key: Key(orders[index]["orderId"].toString()),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            showCancelSelect(orders[index]);
                          }
                        },
                        child: InkWell(
                          onTap: () {
                            if (isOrderComplete.showOrderIndex == null) {
                              print("birinci");
                              showOrderNotify.onShowOrderComplete(index, true);
                              showOrderNotify.onOrderIndex(index);
                            } else if (isOrderComplete
                                    .showOrderComplete[index] ==
                                true) {
                              print("ikinci");
                              showOrderNotify.onShowOrderComplete(index, false);
                              showOrderNotify.onResetSelectedOrderComplete();
                              orderDetailIds = [];
                            } else if (isOrderComplete.showOrderIndex != null) {
                              print("üçüncü");
                              showOrderNotify.onShowOrderComplete(
                                  isOrderComplete.showOrderIndex, false);
                              showOrderNotify.onResetSelectedOrderComplete();
                              orderDetailIds = [];
                              showOrderNotify.onShowOrderComplete(index, true);
                              showOrderNotify.onOrderIndex(index);
                            }
                          },
                          child: Card(
                            elevation: 10,
                            child: Column(
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: showOrderNotify,
                                    builder: (BuildContext context,
                                        ShowOrder value, Widget? child) {
                                      return AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 600),
                                        child: value.showOrder[index]
                                            ? prodCard(orders[index], index,
                                                value.showOrder[index])
                                            : prodTDec(orders[index]["note"],
                                                index, value.showOrder[index]),
                                      );
                                    }),
                                Icon(isOrderComplete.showOrderComplete[index]
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down),
                                AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    height:
                                        isOrderComplete.showOrderComplete[index]
                                            ? 400
                                            : 0,
                                    child: Scrollbar(
                                      controller: scrollControllerList[index],
                                      child: SingleChildScrollView(
                                        controller: scrollControllerList[index],
                                        child: Column(
                                          children: [
                                            Text(
                                              "Seç ve Tamamla.",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25,
                                                  color: crimsonColor),
                                            ),
                                            const Divider(),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25,
                                              child: Scrollbar(
                                                controller:
                                                    scrollControllerList2[
                                                        index],
                                                isAlwaysShown: true,
                                                child: ListView.builder(
                                                    controller:
                                                        scrollControllerList2[
                                                            index],
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        ordersDetails.length,
                                                    itemBuilder:
                                                        (context, index2) {
                                                      return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5.0,
                                                                  horizontal:
                                                                      40),
                                                          child:
                                                              CheckboxListTile(
                                                                  controlAffinity:
                                                                      ListTileControlAffinity
                                                                          .leading,
                                                                  title: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        ordersDetails[index2]["productName"]
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                13),
                                                                      ),
                                                                      Text(
                                                                        ordersDetails[index2]["quantity"]
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  value: isOrderComplete
                                                                          .selectedOrderComplete[
                                                                      index2],
                                                                  onChanged:
                                                                      (value1) {
                                                                    print(
                                                                        "hayırlı ugurlu olsun  ${ordersDetails[index2]["orderDetailId"]}");
                                                                    if (value1 ==
                                                                            true &&
                                                                        orderDetailIds.contains(ordersDetails[index2]["orderDetailId"]) ==
                                                                            false) {
                                                                      print(
                                                                          "burada neler oluyor ${orderDetailIds}");
                                                                      orderDetailIds.add(
                                                                          ordersDetails[index2]
                                                                              [
                                                                              "orderDetailId"]);
                                                                    } else if (value1 ==
                                                                            false &&
                                                                        orderDetailIds.contains(ordersDetails[index2]["orderDetailId"]) ==
                                                                            true) {
                                                                      orderDetailIds.remove(
                                                                          ordersDetails[index2]
                                                                              [
                                                                              "orderDetailId"]);
                                                                    }
                                                                    print(
                                                                        value1);
                                                                    print(
                                                                        orderDetailIds);
                                                                    showOrderNotify
                                                                        .onSelectedOrderComplete(
                                                                            index2,
                                                                            value1!);
                                                                    ;
                                                                  })
                                                          // ElevatedButton(
                                                          //     style: ElevatedButton.styleFrom(
                                                          //         primary: exColor),
                                                          //     onPressed: () {
                                                          //       okProdRequest(ordersDetails[index]
                                                          //           ["orderDetailId"]);
                                                          //       showOrderNotify
                                                          //           .onResetShowOrderComplete();

                                                          //       setState(() {});
                                                          //     },
                                                          //     child: Row(
                                                          //       mainAxisAlignment:
                                                          //           MainAxisAlignment.spaceBetween,
                                                          //       children: [
                                                          //         Text(ordersDetails[index]["productName"]
                                                          //             .toString()),
                                                          //         Text(ordersDetails[index]["quantity"]
                                                          //             .toString()),
                                                          //       ],
                                                          //     )),
                                                          );
                                                    }),
                                              ),
                                            ),
                                            const Divider(),
                                            orders[index]["note"].isEmpty
                                                ? Container()
                                                : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            "Sipariş Notu: ${orders[index]["note"]}"),
                                                      ),
                                                      const Divider(),
                                                    ],
                                                  ),
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    primary: exColor),
                                                onPressed: () {
                                                  if (orderDetailIds.isEmpty) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Tamamlamadan önce lütfen ürün seçimi yapın."),
                                                            actions: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      "Tamam"))
                                                            ],
                                                          );
                                                        });
                                                  } else {
                                                    okProdsRequest(
                                                        orderDetailIds);
                                                    showOrderDialog();
                                                    showOrderNotify
                                                        .onResetShowOrderComplete();
                                                    showOrderNotify
                                                        .onResetSelectedOrderComplete();
                                                  }
                                                },
                                                child: const Text(
                                                  "Tamamla",
                                                  style:
                                                      TextStyle(fontSize: 25),
                                                )),
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    primary: exColor),
                                                onPressed: () {
                                                  okOrderRequest(
                                                      orders[index]["orderId"]);
                                                  showOrderDialog();
                                                  showOrderNotify
                                                      .onResetShowOrderComplete();
                                                },
                                                child: const Text(
                                                    "Tümünü Tamamla"))
                                          ],
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            },
          ),
        )
      ],
    );
  }

//   Widget __transitionBuilder() {
//   final rotateAnim = Tween(begin: pi, end: 0.0).animate(CurvedAnimation(
//     parent: ,
//     curve: Interval(
//       0.125, 0.250,
//       curve: Curves.ease,
//     ),
//   ));
//   return AnimatedBuilder(
//     animation: rotateAnim,
//     child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 600),
//                 child: showFrontSide ? prodCard() : prodTDec(),
//               ),
//     builder: (context, widget) {
//       return Transform(
//         transform: Matrix4.rotationY(50),
//         child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 600),
//                 child: showFrontSide ? prodCard() : prodTDec(),
//               ),
//         alignment: Alignment.center,
//       );
//     },
//   );
// }

  Widget prodCard(Map order, int orderIndex, showOrderValue) {
    List ordersDetails = order["orderDetails"];
    double orderPrice = order["orderPrice"].runtimeType == int
        ? order["orderPrice"].toDouble()
        : order["orderPrice"];
    return Stack(
      children: [
        Container(
            key: keyList[orderIndex],
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
                        Text(order["employeeName"])
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
                          itemBuilder: (BuildContext context, index) {
                            // order["orderDetails"][index]["price"];
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ordersDetails[index]["productName"]
                                          .toString(),
                                      style: TextStyle(
                                          color: ordersDetails[index]
                                                      ["status"] ==
                                                  3
                                              ? crimsonColor
                                              : Colors.black),
                                    ),
                                    Text(
                                        ordersDetails[index]["quantity"]
                                            .toString(),
                                        style: TextStyle(
                                            color: ordersDetails[index]
                                                        ["status"] ==
                                                    3
                                                ? crimsonColor
                                                : Colors.black))
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
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
            )),
        Positioned(
          top: 0,
          right: 0,
          child: order["note"] == ""
              ? Container()
              : IconButton(
                  onPressed: showOrderValue == false
                      ? null
                      : () {
                          showOrderNotify.onShowOrder(orderIndex, false);
                          keyListNotify.onKeyList(
                              keyList[orderIndex].currentContext!.size!,
                              orderIndex);
                        },
                  icon: Icon(
                    Icons.chat,
                    color: crimsonColor,
                  )),
        ),
      ],
    );
  }

  Widget prodTDec(String note, int index, showOrderValue) {
    return ValueListenableBuilder(
        valueListenable: keyListNotify,
        builder: (BuildContext context, KeyList value, Widget? child) {
          return Container(
            height: value.viewSizeList[index].height,
            width: value.viewSizeList[index].width,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                      onPressed: () {
                        showOrderNotify.onShowOrder(index, true);
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: crimsonColor,
                      )),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      note,
                      style: TextStyle(color: crimsonColor),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future okProdsRequest(List orderDetailIds) async {
    try {
      var response = await Dio().post(AppUrl.orderCheck,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"orderDetailIds": orderDetailIds}).then((value) {
        _orderLoading.value = {
          "state": 1,
          "message": "Seçili ürünler tamamlandı."
        };
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.orderCheck,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"orderDetailIds": orderDetailIds}).then((value) {
              _orderLoading.value = {
                "state": 1,
                "message": "Seçili ürünler tamamlandı."
              };
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

  Future okProdRequest(int orderDetailId) async {
    print("şah batur ${orderDetailId}");
    try {
      var response = await Dio().post(AppUrl.orderCheck,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"orderDetailId": orderDetailId}).then((value) {
        _orderLoading.value = {"state": 1, "message": "Ürün Tamamlandı."};
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.orderCheck,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"orderDetailId": orderDetailId}).then((value) {
              _orderLoading.value = {
                "state": 1,
                "message": "Ürün Tamamlandı.."
              };
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

  Future okOrderRequest(int orderId) async {
    try {
      var response = await Dio().post(AppUrl.orderCheck,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"orderId": orderId}).then((value) {
        _orderLoading.value = {"state": 1, "message": "Sipariş Tamamlandı."};
      });
    } on DioError catch (e) {
      _orderLoading.value = {
        "state": 2,
        "message": "${e.response!.data["message"]}"
      };
    }
  }

  Future okProdCancelRequest(int orderDetailId) async {
    try {
      var response = await Dio().post(AppUrl.orderCancel,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"orderDetailId": orderDetailId}).then((value) {
        _orderLoading.value = {"state": 1, "message": "Sipariş iptal edildi."};
      });
    } on DioError catch (e) {
      print(e.response!.data);
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.orderCancel,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"orderDetailId": orderDetailId}).then((value) {
              _orderLoading.value = {
                "state": 1,
                "message": "Sipariş iptal edildi."
              };
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

  showCancelSelect(Map order) {
    List orderDetails = order["orderDetails"];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.25,
                horizontal: 50),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Ürün İptal et.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: crimsonColor),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: orderDetails.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: exColor),
                              onPressed: () {
                                okProdCancelRequest(
                                    orderDetails[index]["orderDetailId"]);
                                Navigator.pop(context);
                                showOrderDialog();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(orderDetails[index]["productName"]
                                      .toString()),
                                  Text(orderDetails[index]["quantity"]
                                      .toString()),
                                ],
                              )),
                        );
                      }),
                ),
                // const Divider(),
                // order["note"].isEmpty
                //     ? Container()
                //     : Column(
                //         children: [
                //           Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Text("Sipariş Notu: ${order["note"]}"),
                //           ),
                //           const Divider(),
                //         ],
                //       ),
                // TextButton(
                //     style: TextButton.styleFrom(primary: exColor),
                //     onPressed: () {
                //       okOrderRequest(order["orderId"]);
                //       // setState(() {});
                //       Navigator.pop(context);
                //     },
                //     child: const Text("Tümünü Tamamla"))
              ],
            ),
          );
        });
    // .then((value) => Navigator.of(
    //     context)
    // .pushNamedAndRemoveUntil(
    //     "/smeorders", ModalRoute.withName("/smemenu")));
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
      waitOrderNotify.onSelectFilter(widget.selectIndex);
    });
  }
}



  // showCompletedSelect(Map order) {
  //   List orderDetails = order["orderDetails"];

  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Dialog(
  //           insetPadding: EdgeInsets.symmetric(
  //               vertical: MediaQuery.of(context).size.height * 0.25,
  //               horizontal: 50),
  //           child: Column(
  //             children: [
  //               Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8),
  //                   child: Align(
  //                     alignment: Alignment.center,
  //                     child: Text(
  //                       "Ürünü Veya Tümünü Tamamla.",
  //                       style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 25,
  //                           color: crimsonColor),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const Divider(),
  //               SizedBox(
  //                 height: MediaQuery.of(context).size.height * 0.25,
  //                 child: ListView.builder(
  //                     shrinkWrap: true,
  //                     itemCount: orderDetails.length,
  //                     itemBuilder: (context, index) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 5.0, horizontal: 40),
  //                         child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(primary: exColor),
  //                             onPressed: () {
  //                               okProdRequest(
  //                                   orderDetails[index]["orderDetailId"]);
  //                               // setState(() {});
  //                               Navigator.pop(context);
  //                             },
  //                             child: Row(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Text(orderDetails[index]["productName"]
  //                                     .toString()),
  //                                 Text(orderDetails[index]["quantity"]
  //                                     .toString()),
  //                               ],
  //                             )),
  //                       );
  //                     }),
  //               ),
  //               const Divider(),
  //               order["note"].isEmpty
  //                   ? Container()
  //                   : Column(
  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text("Sipariş Notu: ${order["note"]}"),
  //                         ),
  //                         const Divider(),
  //                       ],
  //                     ),
  //               TextButton(
  //                   style: TextButton.styleFrom(primary: exColor),
  //                   onPressed: () {
  //                     okOrderRequest(order["orderId"]);
  //                     // setState(() {});
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text("Tümünü Tamamla"))
  //             ],
  //           ),
  //         );
  //       }).then((value) => Navigator.of(
  //           context)
  //       .pushNamedAndRemoveUntil(
  //           "/smeorders", ModalRoute.withName("/smemenu")));
  // }



    // showCompleOrder(order) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text(
  //               "Siparişinizi tamamalamak istediğinize emin misiniz?"),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   int orderDetailId =
  //                       order["orderDetails"][0]["orderDetailId"];
  //                   okOrderRequest(orderDetailId);
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("Evet")),
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("Hayır")),
  //           ],
  //         );
  //       });
  // }

