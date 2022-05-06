import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/models/orderFilter.dart';
import 'package:caylar/sme_components/widgets/completed_order_widget.dart';
import 'package:caylar/sme_components/widgets/order_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WaitedAndCompletedScreen extends StatefulWidget {
  const WaitedAndCompletedScreen({Key? key}) : super(key: key);

  @override
  _WaitedAndCompletedScreenState createState() =>
      _WaitedAndCompletedScreenState();
}

class _WaitedAndCompletedScreenState extends State<WaitedAndCompletedScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: ValueListenableBuilder(
            valueListenable: waitOrderNotify,
            builder: (BuildContext context, WaitOrder value, Widget? child) {
              return FutureBuilder(
                future: orderHistoryRequest(value.lastminute, context),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Bir şeyler yanlış gitti');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snapshot.data == null) {
                    return Scaffold(
                        backgroundColor: whiteColor,
                        resizeToAvoidBottomInset: false,
                        appBar: AppBar(
                          backgroundColor: crimsonColor,
                          title: const Text("Siparişler"),
                          actions: [
                            IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh))
                          ],
                          bottom: TabBar(
                            controller: _tabController,
                            tabs: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Tab(
                                    text: "Bekleyen",
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    0.toString(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  )
                                ],
                              ),
                              const Tab(
                                text: "Tamamlanan",
                              ),
                            ],
                            indicatorColor: Colors.white,
                            indicatorWeight: 6.0,
                          ),
                        ),
                        drawer: WidgetDrawer(
                          drawerType: 1,
                        ),
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            WidgetOrder(
                                waitOrders: {"orders": []},
                                selectIndex: value.selectIndex),
                            WidgetCompletedOrder(),
                          ],
                        ));
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data as Map<String, dynamic>;
                  Map waitOrders = data["data"];
                  List waitOrdersList = waitOrders["orders"];
                  return Scaffold(
                      backgroundColor: whiteColor,
                      resizeToAvoidBottomInset: false,
                      appBar: AppBar(
                        backgroundColor: crimsonColor,
                        title: const Text("Siparişler"),
                        actions: [
                          IconButton(
                              onPressed: () {
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh))
                        ],
                        bottom: TabBar(
                          controller: _tabController,
                          tabs: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Tab(
                                  text: "Bekleyen",
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  waitOrdersList.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                )
                              ],
                            ),
                            const Tab(
                              text: "Tamamlanan",
                            ),
                          ],
                          indicatorColor: Colors.white,
                          indicatorWeight: 6.0,
                        ),
                      ),
                      drawer: WidgetDrawer(
                        drawerType: 1,
                      ),
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          WidgetOrder(
                              waitOrders: waitOrders,
                              selectIndex: value.selectIndex),
                          WidgetCompletedOrder(),
                        ],
                      ));
                },
              );
            }));
  }

  Future orderHistoryRequest(int lastMinutes, context) async {
    try {
      var response = await Dio().post(AppUrl.orderHistory,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"lastMinutes": lastMinutes, "status": 1});
      print("abc$response");
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          print("tokenlendiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
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
          //       data: {"lastMinutes": lastMinutes, "status": 1});
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
