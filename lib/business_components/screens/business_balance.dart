import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/models/phone_number_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessBalance extends StatefulWidget {
  late List employeeList;
  BusinessBalance({Key? key, required this.employeeList}) : super(key: key);
  @override
  State<BusinessBalance> createState() => _BusinessBalance();
}

class _BusinessBalance extends State<BusinessBalance> {
  static List<String> items = ["Çay Seç/Tüm Rapor", "item2", "item3", "item4"];
  ValueNotifier<String> amountOfPayment = ValueNotifier("");
  String? value = items.first;
  final ValueNotifier<Map> _paymentTakeLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  final ValueNotifier<String> _searchTextNotify = ValueNotifier<String>("");
  final ValueNotifier<int> _selectEmployeeIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _fakeSelectEmployeeIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> _periodBalance = ValueNotifier<bool>(false);
  ValueNotifier<DateTime?> dateTime1 =
      ValueNotifier<DateTime?>(DateTime.now().add(const Duration(days: -30)));
  ValueNotifier<DateTime?> dateTime2 = ValueNotifier<DateTime?>(DateTime.now());
  String startDate =
      DateTime.now().add(const Duration(days: -7)).toString().substring(0, 10);
  String endDate = DateTime.now().toString().substring(0, 10);
  // List<PlatformFile>? file;
  // DateTime? dateTime1;
  // DateTime? dateTime2;
  // int _value2 = 0;
  final _formKey = GlobalKey<FormState>();

  // companyOfEmployeeList() {
  //   List<DropdownMenuItem<int>> dropdownItemList = [];
  //   List dealersOfCompany = widget.employeeList;
  //   for (var i = 0; i < dealersOfCompany.length + 1; i++) {
  //     if (i == 0) {
  //       dropdownItemList.add(
  //         DropdownMenuItem(
  //           child: Text(
  //             "Tüm Personel",
  //             style: TextStyle(color: exColor),
  //           ),
  //           value: 0,
  //         ),
  //       );
  //     } else {
  //       dropdownItemList.add(
  //         DropdownMenuItem(
  //           child: Text(
  //             dealersOfCompany[i - 1]["nameSurname"].toString(),
  //             style: TextStyle(color: exColor),
  //           ),
  //           value: i,
  //         ),
  //       );
  //     }
  //   }
  //   print("sayf bakalım -------------------- $dropdownItemList");
  //   return dropdownItemList;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: WidgetDrawer(drawerType: 2),
          // floatingActionButton: FloatingActionButton(
          //   elevation: 30,
          //   onPressed: () {},
          //   child: Container(
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(50),
          //         image: const DecorationImage(
          //           fit: BoxFit.fill,
          //           image: AssetImage("assets/excel.png"),
          //         ),
          //         color: crimsonColor),
          //   ),
          // ),
          body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: crimsonColor,
                    title: const Text("Bakiye Tanımlama"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh)),
                      IconButton(
                          onPressed: () {
                            showPaymentSetting();
                          },
                          icon: const Icon(
                            Icons.settings,
                          ))
                    ],
                  ),
                  SliverAppBar(
                    backgroundColor: lightGrey,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 75,
                    centerTitle: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: _selectEmployeeIndex,
                            builder: (BuildContext context, int employee,
                                Widget? child) {
                              if (employee == 0) {
                                return Text(
                                  "Tüm Personeller",
                                  style: TextStyle(color: exColor),
                                );
                              }
                              return Text(
                                widget.employeeList[employee - 1]
                                    ["nameSurname"],
                                style: TextStyle(color: exColor),
                              );
                            }),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: crimsonColor,
                            size: 40,
                          ),
                          onPressed: () {
                            showFiltre();
                          },
                        ),
                      ],
                    ),
                    // actions: [
                    //   Padding(
                    //     padding: const EdgeInsets.only(right: 20),
                    //     child: IconButton(
                    //       icon: Icon(
                    //         Icons.filter_list,
                    //         color: crimsonColor,
                    //         size: 40,
                    //       ),
                    //       onPressed: () {
                    //         showFiltre();
                    //       },
                    //     ),
                    //   ),
                    // ],
                  ),
                  SliverAppBar(
                    backgroundColor: lightGrey,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 75,
                    title: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                color: whiteColor,
                                border: Border.all(
                                  color: whiteColor,
                                ),
                                borderRadius: (BorderRadius.circular(12))),
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                                ],
                                onChanged: (value) {
                                  amountOfPayment.value = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Lütfen Bakiye Miktarı Belirleyiniz.";
                                  }
                                },
                                onSaved: (value) {
                                  amountOfPayment.value = value!;
                                },
                                decoration: const InputDecoration(
                                    constraints: BoxConstraints(maxHeight: 40),
                                    hintText: "Yüklenecek Bakiye Tutarı",
                                    hintStyle:
                                        TextStyle(color: Color(0xFFBDBDBD))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverAppBar(
                    backgroundColor: lightGrey,
                    automaticallyImplyLeading: false,
                    title: Center(
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _selectEmployeeIndex,
                              builder: (BuildContext context,
                                  int selectEmployee, Widget? child) {
                                return ValueListenableBuilder(
                                    valueListenable: amountOfPayment,
                                    builder: (BuildContext context,
                                        String value, Widget? child) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            if (selectEmployee > 0) {
                                              addBalance(selectEmployee, value);
                                              showTakeLoadingDialog();
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Seçim Yapınız."),
                                                      content: const Text(
                                                          "Bakiye tanımlaması gerçekleşecek personeli seçiniz."),
                                                      actions: [
                                                        MaterialButton(
                                                            child: const Text(
                                                                "Tamam"),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context))
                                                      ],
                                                    );
                                                  });
                                            }
                                          }
                                        },
                                        child: const Text("Bakiye Tanımla"),
                                        style: ElevatedButton.styleFrom(
                                            primary: crimsonColor,
                                            fixedSize: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50,
                                                40),
                                            padding: const EdgeInsets.all(12)),
                                      );
                                    });
                              })
                        ],
                      ),
                    ),
                  ),
                  // SliverPersistentHeader(
                  //   delegate: Delegate(),
                  // ),
                  // SliverList(delegate: delegate)
                ];
              },
              body: ValueListenableBuilder(
                  valueListenable: _periodBalance,
                  builder:
                      (BuildContext context, bool isperiod, Widget? child) {
                    return ValueListenableBuilder(
                        valueListenable: _selectEmployeeIndex,
                        builder: (BuildContext context, int searchEmployee,
                            Widget? child) {
                          return FutureBuilder(
                            future: getPaymentList(
                                searchEmployee, isperiod, startDate, endDate),
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
                              if (data["data"].isEmpty) {
                                return const Center(
                                  child: Text(
                                      "Henüz hiçbir bakiye tanımlaması bulunmuyor."),
                                );
                              }
                              List paymentInfo = data["data"];
                              return Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            Container(
                                              color: whiteColor,
                                              child: DataTable(
                                                headingRowColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                            (Set<MaterialState>
                                                                states) {
                                                  return crimsonColor;
                                                }),
                                                // columnSpacing: 38.0,
                                                columns: const [
                                                  DataColumn(
                                                      label: Text(
                                                    'Bakiye Tanımlanan',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                                  DataColumn(
                                                      label: Text(
                                                          'Tanımlama Tarihi',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                  DataColumn(
                                                      label: Text(
                                                          'Bakiye Tutarı',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                  DataColumn(
                                                      label: Text('Sil',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                ],

                                                rows: List.generate(
                                                    paymentInfo.length,
                                                    (index) {
                                                  final paymentEmployee =
                                                      paymentInfo[index]
                                                              ["employeeName"]
                                                          .toString();
                                                  double amount = paymentInfo[
                                                                      index]
                                                                  ["amount"]
                                                              .runtimeType ==
                                                          int
                                                      ? paymentInfo[index]
                                                              ["amount"]
                                                          .toDouble()
                                                      : paymentInfo[index]
                                                          ["amount"];
                                                  final paymentDate =
                                                      paymentInfo[index][
                                                              "balanceDateTime"]
                                                          .toString();
                                                  final int balanceId =
                                                      paymentInfo[index]
                                                          ["balanceId"];

                                                  return DataRow(
                                                      color: MaterialStateProperty
                                                          .resolveWith<
                                                              Color>((Set<
                                                                  MaterialState>
                                                              states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .selected)) {
                                                          return Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .primary
                                                              .withOpacity(
                                                                  0.08);
                                                        }
                                                        if (index % 2 == 0) {
                                                          return Colors.grey
                                                              .withOpacity(0.3);
                                                        }
                                                        return Colors
                                                            .white; // Use default value for other states and odd rows.
                                                      }),
                                                      cells: [
                                                        DataCell(Container(
                                                            width: 80,
                                                            child: Text(
                                                                paymentEmployee))),
                                                        DataCell(Container(
                                                            width: 75,
                                                            child: Text(
                                                                paymentDate
                                                                    .substring(
                                                                        0,
                                                                        10)))),
                                                        DataCell(Container(
                                                            width: 75,
                                                            child: Text(
                                                                "${amount.toStringAsFixed(2).toString()} ₺"))),
                                                        DataCell(Container(
                                                            width: 40,
                                                            child: TextButton(
                                                              onPressed: () {
                                                                paymentRemove(
                                                                    balanceId);
                                                              },
                                                              child: const Text(
                                                                  "Sil"),
                                                            ))),
                                                      ]);
                                                }),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 70,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        });
                  }))),
    );
  }

  Future getPaymentList(
      int employeeIndex, bool onlyExtra, startDate, endDate) async {
    String employeeId = "";
    // // if (dealerIndex > 0 && employeeIndex > 0) {
    // //   employeeId = widget.employeeList[employeeIndex - 1]["id"];
    // //   dealerId = widget.dealerList[dealerIndex - 1]["id"];
    // // } else if (dealerIndex > 0 && employeeIndex == 0) {
    // //   dealerId = widget.dealerList[dealerIndex - 1]["id"];
    // // } else
    if (employeeIndex > 0) {
      employeeId = widget.employeeList[employeeIndex - 1]["id"];
    }
    print("$employeeId, sgsgsgss");
    try {
      var response = await Dio().post(AppUrl.balanceHistory,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "employeeId": employeeId,
            "startDate": startDate,
            "endDate": endDate,
            "onlyExtra": true
          });
      print(response);
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });

          // try {
          //   var response = await Dio().post(AppUrl.balanceHistory,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "employeeId": employeeId,
          //       });
          //   print(response);
          //   return response;
          // } on DioError catch (e) {
          //   showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text("${e.response.toString()}"),
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
                title: Text(e.response.toString()),
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

  Future addBalance(int employeeIndex, String amountOfPayment) async {
    String employeeId = "";
    double pureAmount = 0.0;
    if (amountOfPayment.contains(".")) {
      pureAmount = double.parse(amountOfPayment);
    } else {
      pureAmount = int.parse(amountOfPayment).toDouble();
    }
    if (employeeIndex > 0) {
      //   companyId = widget.dealerList[companyIndex - 1]["id"];
      employeeId = widget.employeeList[employeeIndex - 1]["id"];
    }
    //else if (companyIndex > 0 && employeeIndex == 0) {
    //   companyId = widget.dealerList[companyIndex - 1]["id"];
    // }
    print(" iiiilllllllllllllaaaaaaaaaaaaaa  $employeeId");
    try {
      var response = await Dio().post(AppUrl.addBalance,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"employeeId": employeeId, "amount": pureAmount}).then((value) {
        _paymentTakeLoading.value = {
          "state": 1,
          "message": "Bakiye Tanımlandı."
        };
        setState(() {});
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.addBalance,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "employeeId": employeeId,
                  "amountOfPayment": pureAmount
                }).then((value) {
              _paymentTakeLoading.value = {
                "state": 1,
                "message": "Bakiye Tanımlandı."
              };
              setState(() {});
            });
          } on DioError catch (e) {
            _paymentTakeLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _paymentTakeLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  Future paymentRemove(int balanceId) async {
    try {
      var response = await Dio().post(AppUrl.balanceRemove,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"balanceId": balanceId}).then((value) {
        _paymentTakeLoading.value = {"state": 1, "message": "Tahsilat Silindi"};
        setState(() {});
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.balanceRemove,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"balanceId": balanceId}).then((value) {
              _paymentTakeLoading.value = {
                "state": 1,
                "message": "Bakiye Tanımlama Silindi."
              };
              setState(() {});
            });
          } on DioError catch (e) {
            _paymentTakeLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _paymentTakeLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showTakeLoadingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _paymentTakeLoading,
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
      _paymentTakeLoading.value = {"state": 0, "message": ""};
    });
  }

  showFiltre() {
    List filtre = List.generate(5, (int index) {
      if (index == 0) {
        return false;
      } else if (index == 1) {
        return "false";
      } else if (index == 2) {
        return "false";
      } else if (index == 3) {
        return 0;
      }
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: crimsonColor,
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: ListTile(
                        title: Text(
                          "Filtreleme",
                          style: TextStyle(color: whiteColor, fontSize: 25),
                        ),
                        trailing: TextButton(
                            child: const Text("Filtrele"),
                            onPressed: () {
                              Navigator.pop(context, true);
                            }),
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _searchTextNotify,
                      builder: (BuildContext context, String searchText,
                          Widget? child) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Periyodik yükleme gösterilsin mi?"),
                                ValueListenableBuilder(
                                    valueListenable: _periodBalance,
                                    builder: (BuildContext context,
                                        bool isPeriod, Widget? child) {
                                      return TextButton(
                                          onPressed: () {
                                            // _periodBalance.value = !isPeriod;
                                            filtre[0] = !isPeriod;
                                          },
                                          child: Text(
                                              isPeriod ? "Evet" : "Hayır"));
                                    })
                              ],
                            ),
                            ValueListenableBuilder(
                                valueListenable: dateTime1,
                                builder: (BuildContext context,
                                    DateTime? dateTimevalue1, Widget? child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Başlangıç Tarihi"),
                                      OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: whiteColor,
                                            side: BorderSide(color: exColor),
                                          ),
                                          onPressed: () {
                                            _openDatePicker1(context);
                                          },
                                          child: dateTimevalue1 == null
                                              ? Text(
                                                  "Başlangıç Tarihi",
                                                  style:
                                                      TextStyle(color: exColor),
                                                )
                                              : Text(
                                                  dateTimevalue1
                                                      .toString()
                                                      .substring(0, 10),
                                                  style:
                                                      TextStyle(color: exColor),
                                                ))
                                    ],
                                  );
                                }),
                            ValueListenableBuilder(
                                valueListenable: dateTime2,
                                builder: (BuildContext context,
                                    DateTime? dateTimevalue2, Widget? child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Bitiş Tarihi"),
                                      OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              backgroundColor: whiteColor,
                                              side: BorderSide(color: exColor)),
                                          onPressed: () {
                                            _openDatePicker2(context);
                                          },
                                          child: dateTimevalue2 == null
                                              ? Text(
                                                  "Bitiş Tarihi",
                                                  style:
                                                      TextStyle(color: exColor),
                                                )
                                              : Text(
                                                  dateTimevalue2
                                                      .toString()
                                                      .substring(0, 10),
                                                  style:
                                                      TextStyle(color: exColor),
                                                )),
                                    ],
                                  );
                                }),
                            Container(
                              height: 70,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  border: Border.all(
                                    color: whiteColor,
                                  ),
                                  borderRadius: (BorderRadius.circular(12))),
                              child: Form(
                                // key: _formKey,
                                child: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                    LengthLimitingTextInputFormatter(10),
                                    _phoneNumberFormatter
                                  ],
                                  onChanged: ((value) {
                                    if (value.isNotEmpty && value.length <= 4) {
                                      _searchTextNotify.value =
                                          value.substring(1, value.length);
                                      print(value.substring(1, value.length));
                                    } else if (value.length > 4 &&
                                        value.length <= 9) {
                                      _searchTextNotify.value =
                                          value.substring(1, 4) +
                                              value.substring(6, value.length);
                                      print(
                                          "${value.substring(1, 4)}${value.substring(6, value.length)}");
                                    } else if (value.length > 9 &&
                                        value.length <= 14) {
                                      _searchTextNotify.value =
                                          value.substring(1, 4) +
                                              value.substring(6, 9) +
                                              value.substring(10, value.length);
                                      print(
                                          "${value.substring(1, 4)}${value.substring(6, 9)}${value.substring(10, value.length)}");
                                    } else {
                                      _searchTextNotify.value = value;
                                      print(value);
                                    }
                                  }),
                                  // validator: (value) {
                                  //   if (value!.isEmpty) {
                                  //     return "Lütfen Bakiye Miktarı Belirleyiniz.";
                                  //   }
                                  // },
                                  // onSaved: (value) {
                                  //   amountOfPayment.value = value!;
                                  // },
                                  decoration: const InputDecoration(
                                      constraints:
                                          BoxConstraints(maxHeight: 40),
                                      hintText:
                                          "Telefon numarası ile personel arama",
                                      hintStyle:
                                          TextStyle(color: Color(0xFFBDBDBD))),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _fakeSelectEmployeeIndex,
                                builder: (BuildContext context,
                                    int searchEmployee, Widget? child) {
                                  return Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    child: ListView.builder(
                                        itemCount:
                                            widget.employeeList.length + 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          print(
                                              "adfsaddadasdadasdad 0$searchText");
                                          List dealersOfCompany =
                                              widget.employeeList;
                                          if (index == 0) {
                                            return ListTile(
                                              selected: searchEmployee == index
                                                  ? true
                                                  : false,
                                              selectedColor: Colors.blue,
                                              onTap: () {
                                                _fakeSelectEmployeeIndex.value =
                                                    index;
                                                filtre[3] = index;
                                              },
                                              title:
                                                  const Text("Tüm Personeller"),
                                            );
                                          }
                                          if (index > 0 &&
                                              dealersOfCompany[index - 1]
                                                      ["userName"]
                                                  .contains("0$searchText")) {
                                            return ListTile(
                                              selected: filtre[3] == index
                                                  ? true
                                                  : false,
                                              selectedColor: Colors.blue,
                                              onTap: () {
                                                _fakeSelectEmployeeIndex.value =
                                                    index;
                                                filtre[3] = index;
                                              },
                                              title: Text(
                                                  dealersOfCompany[index - 1]
                                                      ["nameSurname"]),
                                              trailing: Text(
                                                  dealersOfCompany[index - 1]
                                                      ["userName"]),
                                            );
                                          }
                                          return Container();
                                        }),
                                  );
                                }),
                          ],
                        );
                      })
                ],
              ),
            ),
          );
        }).then((value) {
      if (value == true) {
        _periodBalance.value = filtre[0];
        _selectEmployeeIndex.value = filtre[3];
        startDate = dateTime1.value.toString().substring(0, 10);
        endDate = dateTime2.value.toString().substring(0, 10);
        print(startDate);
        _searchTextNotify.value = "";
        setState(() {});
      }
    });
  }

  Future<void> _openDatePicker1(BuildContext context) async {
    dateTime1.value = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2025),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: crimsonColor, // header background color
                onPrimary: whiteColor, // header text color
                onSurface: exColor, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: crimsonColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
  }

  Future<void> _openDatePicker2(BuildContext context) async {
    dateTime2.value = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2025),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: crimsonColor, // header background color
                onPrimary: whiteColor, // header text color
                onSurface: exColor, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: crimsonColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
  }

  showPaymentSetting() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Emin misiniz?"),
            content: const Text(
                "Ödeme sisteminizi bakiye sisteminden tahsilat sistemine geçirmek üzeresiniz."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    paymentSetting();
                    showTakeLoadingDialog();
                  },
                  child: const Text("Tahsilat Sistemi")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Kapat"))
            ],
          );
        });
  }

  Future paymentSetting() async {
    try {
      var response = await Dio().post(AppUrl.setCompanySettings,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"balance": 0, "paymentSetting": 1}).then((value) {
        // _paymentTakeLoading.value = {
        //   "state": 1,
        //   "message": "Artık uygulama içi ödeme yönteminiz tahsilat sistemidir."
        // };
        Navigator.of(context).pushNamedAndRemoveUntil(
            "/businessbalance", ModalRoute.withName("/businessmenu"));
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
              // _paymentTakeLoading.value = {
              //   "state": 1,
              //   "message":
              //       "Artık uygulama içi ödeme yönteminiz tahsilat sistemidir."
              // };
              Navigator.of(context).pushNamedAndRemoveUntil(
                  "/businessbalance", ModalRoute.withName("/businessmenu"));
            });
          } on DioError catch (e) {
            print(e.response);
            _paymentTakeLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        print(e.response);
        _paymentTakeLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }
}
