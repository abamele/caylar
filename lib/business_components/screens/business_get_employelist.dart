import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/business_components/screens/business_balance.dart';
import 'package:caylar/business_components/screens/business_pay_report.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessGetEmployeeList extends StatefulWidget {
  late bool isBalancePage;
  BusinessGetEmployeeList({Key? key, required this.isBalancePage})
      : super(key: key);

  @override
  State<BusinessGetEmployeeList> createState() =>
      _BusinessGetEmployeeListState();
}

class _BusinessGetEmployeeListState extends State<BusinessGetEmployeeList> {
  final ValueNotifier<Map> _updateIsBalance =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return widget.isBalancePage
        ? Scaffold(
            drawer: WidgetDrawer(
              drawerType: 2,
            ),
            body: FutureBuilder(
                future: getIsBalance(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Bir şeyler yanlış gitti.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data as Map<String, dynamic>;
                  int isBalanceNum = data["data"]["paymentSetting"];
                  bool isBalance = isBalanceNum == 2 ? true : false;
                  if (isBalance == false) {
                    return notBalance();
                  } else {
                    return FutureBuilder(
                      future: getEmployeeList(),
                      builder: (context, AsyncSnapshot snapshot) {
                        print("object");
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Bir şeyler yanlış gitti.'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        Map<String, dynamic> data2 =
                            snapshot.data.data as Map<String, dynamic>;
                        if (data2["data"] == null) {
                          return BusinessBalance(
                            employeeList: [],
                          );
                          // return Text("$data1  dddddddddddddddddddddddddddddd  $data2");
                        }
                        List employeeList = data2["data"];
                        return BusinessBalance(
                          employeeList: employeeList,
                        );
                      },
                    );
                  }
                }))
        : Scaffold(
            body: FutureBuilder(
                future: getDealerList(),
                builder: (context, AsyncSnapshot snapshot) {
                  print("object");
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Bir şeyler yanlış gitti.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data as Map<String, dynamic>;
                  if (data["data"] == null) {
                    return BusinessPaymentReport(
                      employeeList: [],
                      dealerList: [],
                    );
                  }
                  List dealerList = data["data"];
                  return FutureBuilder(
                    future: getEmployeeList(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Bir şeyler yanlış gitti.'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      Map<String, dynamic> data2 =
                          snapshot.data.data as Map<String, dynamic>;
                      print("$data  dddddddddddddddddddddddddddddd  $data2");

                      if (data2["data"] == null) {
                        return BusinessPaymentReport(
                          employeeList: [],
                          dealerList: dealerList,
                        );
                      }
                      List employeeList = data2["data"];
                      return BusinessPaymentReport(
                        employeeList: employeeList,
                        dealerList: dealerList,
                      );
                    },
                  );
                }));
  }

  Future getIsBalance() async {
    try {
      var response = await Dio().post(AppUrl.companySettingsInfo,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {});
      print(response);
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
                title: Text("${e.response!}"),
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

  Future getDealerList() async {
    try {
      var response = await Dio().post(AppUrl.dealerList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "companyId": Hive.box("userbox").get("companyId").toString(),
          });
      print(response);
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
                title: Text("${e.response!}"),
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

  Widget notBalance() {
    return SafeArea(
      child: Column(
        children: [
          Container(
              color: crimsonColor,
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Center(
                child: Text(
                  "Tahsilat Sistemi Nedir?",
                  style: TextStyle(color: whiteColor, fontSize: 25),
                ),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.4 - 40,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tahsilat sistemi, firma yöneticisi ve firma personellerinin çay ocağına borçlandığı sistemdir. Bu sistemde firma yetkilisi ve firma personelleri önce alışverişlerini yapar sonrasında biriken borçları için çay ocağına ödeme yaparlar. Çay ocağına yapılan ödemenin sistemdeki borç miktarından düşmesi için çay ocağı hesabının menüsünde bulunan 'Tahsilat' bölümünden tahsilat eklenmesi gerekir. Çay ocağı tahsilat eklerken firma ve personel seçimi yapmalıdır. ",
                style: TextStyle(color: exColor),
              ),
            )),
          ),
          Container(
              color: crimsonColor,
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Center(
                child: Text(
                  "Bakiye Sistemi Nedir?",
                  style: TextStyle(color: whiteColor, fontSize: 25),
                ),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.4 - 40,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bakiye sistemi, firma personellerinin çay ocağından yapacakları alışverişlerin limitinin firma yetkilisi tarafından kontrol edilmesini sağlar. Bu sistemde firma yetkilisi, firma personellerinin hesabına periyodik olarak yüklenecek olan bir limit tanımlar. Periyodik olarak tanımlanacak limit şahıslara özel belirlenebilir ve aynı zamanda yükleme periyodu belirlenebilir. Periyodik yüklemenin dışında firma yetkilisi, firma personellerinin hesabına ekstra yüklemelerde yapabilir. Bu sistemde borçlanma sistemi yoktur ve yetersiz bakiyesi olan firma personeli sipariş vermemektedir. Ayrıca firmanın yetkili ve personellerinin toplam alışverişi çay ocağına firma üzerinden ödenecektir. Ödeme çay ocağı menü ekranında bulunan 'Tahsilatlar' sayfasından sisteme kaydedilecektir ve sadece firma adına tahsilat yapılacaktır.",
                style: TextStyle(color: exColor),
              ),
            )),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: crimsonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              onPressed: () {
                showBalanceSystem();
              },
              child: const Text("Bakiye Sistemini Aktif Et"))
        ],
      ),
    );
  }

  Future paymentSetting() async {
    try {
      var response = await Dio().post(AppUrl.setCompanySettings,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"balance": 0, "paymentSetting": 2}).then((value) {
        _updateIsBalance.value = {
          "state": 1,
          "message": "Artık uygulama içi ödeme yönteminiz bakiye sistemidir."
        };
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.setCompanySettings,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"balance": 0, "paymentSetting": 2}).then((value) {
              _updateIsBalance.value = {
                "state": 1,
                "message":
                    "Artık uygulama içi ödeme yönteminiz bakiye sistemidir."
              };
            });
          } on DioError catch (e) {
            print(e.response);
            _updateIsBalance.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        print(e.response);
        _updateIsBalance.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showUpdateIsBalanceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _updateIsBalance,
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
      _updateIsBalance.value = {"state": 0, "message": ""};
      setState(() {});
    });
  }

  Future getEmployeeList() async {
    try {
      var response = await Dio().post(AppUrl.employeeList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            // "companyId": Hive.box("userbox").get("companyId").toString(),
          });
      print("hanimiş perosneller $response");
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
                title: Text("${e.response!}"),
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

  showBalanceSystem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Emin misiniz?"),
            content: const Text(
                "Bakiye sistemine geçmek istediğinize emin misiniz?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    paymentSetting();
                    showUpdateIsBalanceDialog();
                  },
                  child: const Text("Evet")),
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
