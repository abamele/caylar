import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/models/phone_number_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../all_widgets/drawer.dart';

class SmePaymentTake extends StatefulWidget {
  late List companyAndEmployeeList;
  SmePaymentTake({Key? key, required this.companyAndEmployeeList})
      : super(key: key);
  @override
  State<SmePaymentTake> createState() => _SmePaymentTake();
}

class _SmePaymentTake extends State<SmePaymentTake> {
  static List<String> items = ["Çay Seç/Tüm Rapor", "item2", "item3", "item4"];
  ValueNotifier<String> amountOfPayment = ValueNotifier("");
  String? value = items.first;
  final ValueNotifier<Map> _paymentTakeLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});
  final UsNumberTextInputFormatter _phoneNumberFormatter =
      UsNumberTextInputFormatter();
  final ValueNotifier<String> _searchTextNotify = ValueNotifier<String>("");
  int _value1 = 0;
  int _value2 = 0;
  final _formKey = GlobalKey<FormState>();

  companyOfDealerList() {
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List companyOfDealers = widget.companyAndEmployeeList;
    for (var i = 0; i < companyOfDealers.length + 1; i++) {
      if (i == 0) {
        dropdownItemList.add(
          DropdownMenuItem(
            child: Text(
              "Tüm Firmalar",
              style: TextStyle(color: exColor),
            ),
            value: 0,
          ),
        );
      } else {
        dropdownItemList.add(
          DropdownMenuItem(
            child: Text(
              companyOfDealers[i - 1]["name"].toString(),
              style: TextStyle(color: exColor),
            ),
            value: i,
          ),
        );
      }
    }
    print(dropdownItemList);
    return dropdownItemList;
  }

  companyOfEmployeeList() {
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List companyOfDealers = widget.companyAndEmployeeList;
    // List employeeOfCompany = widget.companyAndEmployeeList;
    if (_value1 == 0) {
      dropdownItemList.add(
        DropdownMenuItem(
          child: Text(
            "Tüm Personel",
            style: TextStyle(color: exColor),
          ),
          value: 0,
        ),
      );
    } else {
      for (var i = 0;
          i < companyOfDealers[_value1 - 1]["employees"].length + 1;
          i++) {
        if (i == 0) {
          dropdownItemList.add(
            DropdownMenuItem(
              child: Text(
                "Tüm Personel",
                style: TextStyle(color: exColor),
              ),
              value: 0,
            ),
          );
        } else {
          dropdownItemList.add(
            DropdownMenuItem(
              child: Text(
                companyOfDealers[_value1 - 1]["employees"][i - 1]["nameSurname"]
                    .toString(),
                style: TextStyle(color: exColor),
              ),
              value: i,
            ),
          );
        }
      }
    }

    print("sayf bakalım -------------------- $dropdownItemList");
    return dropdownItemList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: WidgetDrawer(
            drawerType: 1,
          ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: crimsonColor,
                  title: Column(
                    children: const [
                      Text("Tahislat"),
                    ],
                  ),
                ),
                SliverAppBar(
                  backgroundColor: lightGrey,
                  automaticallyImplyLeading: false,
                  title: Center(
                    child: Column(
                      children: [
                        Container(
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
                          child: DropdownButton(
                              isExpanded: true,
                              value: _value1,
                              items: companyOfDealerList(),
                              onChanged: (int? value) {
                                _value1 = value!;
                                if (_value1 == 0) {
                                  _value2 = 0;
                                }
                                setState(() {});
                              },
                              hint: const Text("Firma Seçiniz")),
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
                        Container(
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
                          child: DropdownButton(
                              isExpanded: true,
                              value: _value2,
                              items: companyOfEmployeeList(),
                              onChanged: (int? value) {
                                _value2 = value!;
                                setState(() {});
                              },
                              hint: const Text("Personel Seçiniz")),
                        ),
                      ],
                    ),
                  ),
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
                                  return "Lütfen Tahsilat Tutarını Belirleyiniz.";
                                }
                              },
                              onSaved: (value) {
                                amountOfPayment.value = value!;
                              },
                              decoration: const InputDecoration(
                                  constraints: BoxConstraints(maxHeight: 40),
                                  // focusedBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(color: crimsonColor),
                                  // ),
                                  hintText: "Tahsilat Tutarı",
                                  hintStyle: TextStyle(color: Color(0xFFBDBDBD))
                                  // labelText: "Tahsil Edilen Tutar",
                                  // labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                  // border: OutlineInputBorder(
                                  //     borderRadius:
                                  //         BorderRadius.circular(10.0))
                                  ),
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
                            valueListenable: amountOfPayment,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              return ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    if (_value2 > 0) {
                                      takePayment(_value1, _value2, value);
                                      showTakeLoadingDialog();
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Seçim Yapınız."),
                                              content: const Text(
                                                  "Tasilat gerçekleşecek personeli seçiniz."),
                                              actions: [
                                                MaterialButton(
                                                    child: const Text("Tamam"),
                                                    onPressed: () =>
                                                        Navigator.pop(context))
                                              ],
                                            );
                                          });
                                    }
                                  }
                                },
                                child: const Text("Tahsilat Ekle"),
                                style: ElevatedButton.styleFrom(
                                    primary: crimsonColor,
                                    fixedSize: Size(
                                        MediaQuery.of(context).size.width - 50,
                                        40),
                                    padding: const EdgeInsets.all(12)),
                              );
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
            body: FutureBuilder(
              future: getPaymentList(
                _value1,
                _value2,
              ),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return const Text('Bir şeyler yanlış gitti');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> data =
                    snapshot.data.data as Map<String, dynamic>;
                if (data["data"].isEmpty) {
                  return const Center(
                    child: Text("Henüz hiçbir bakiye tanımlaması bulunmuyor."),
                  );
                }
                Map paymentInfo = data["data"];
                double totalPayment =
                    paymentInfo["totalPayment"].runtimeType == int
                        ? paymentInfo["totalPayment"].toDouble()
                        : paymentInfo["totalPayment"];
                double remainDebt = paymentInfo["remainDebt"].runtimeType == int
                    ? paymentInfo["remainDebt"].toDouble()
                    : paymentInfo["remainDebt"];
                double totalDebt = paymentInfo["totalDebt"].runtimeType == int
                    ? paymentInfo["totalDebt"].toDouble()
                    : paymentInfo["totalDebt"];

                if (data["errorCode"] == 3203) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Toplam Alışveris:",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${totalDebt.toStringAsFixed(2)}₺",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 27)),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Toplam Tahsilat:",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${totalPayment.toStringAsFixed(2)}₺",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 27)),
                            )
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Kalan Borç:",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${remainDebt.toStringAsFixed(2)} ₺",
                                  style: TextStyle(
                                      color: crimsonColor, fontSize: 27)),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Geçmiş Tahsilatlar",
                            style: TextStyle(
                                color: crimsonColor,
                                fontSize: 27,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(data["message"]),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Toplam Alışveriş:",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${totalDebt.toStringAsFixed(2)}₺",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 27)),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Toplam Tahsilat:",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${totalPayment.toStringAsFixed(2)}₺",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 27)),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Kalan Borç:",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${remainDebt.toStringAsFixed(2)}₺",
                              style:
                                  TextStyle(color: crimsonColor, fontSize: 27)),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Geçmiş Tahsilatlar",
                        style: TextStyle(
                            color: crimsonColor,
                            fontSize: 27,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            color: whiteColor,
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                return crimsonColor;
                              }),
                              // columnSpacing: 38.0,
                              columns: const [
                                DataColumn(
                                    label: Text(
                                  'Tahislat Yapılan',
                                  style: TextStyle(color: Colors.white),
                                )),
                                DataColumn(
                                    label: Text('Tahislat Tarihi',
                                        style: TextStyle(color: Colors.white))),
                                DataColumn(
                                    label: Text('Tahislat Tutarı',
                                        style: TextStyle(color: Colors.white))),
                                DataColumn(
                                    label: Text('Sil',
                                        style: TextStyle(color: Colors.white))),
                              ],

                              rows: List.generate(
                                  paymentInfo["payments"].length, (index) {
                                final paymentEmployee = paymentInfo["payments"]
                                        [index]["employeeName"]
                                    .toString();
                                double price = paymentInfo["payments"][index]
                                                ["price"]
                                            .runtimeType ==
                                        int
                                    ? paymentInfo["payments"][index]["price"]
                                        .toDouble()
                                    : paymentInfo["payments"][index]["price"];
                                final paymentTime = paymentInfo["payments"]
                                        [index]["paymentTime"]
                                    .toString();
                                final int paymentId =
                                    paymentInfo["payments"][index]["id"];

                                return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                        Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08);
                                      }
                                      if (index % 2 == 0)
                                        return Colors.grey.withOpacity(0.3);
                                      return Colors
                                          .white; // Use default value for other states and odd rows.
                                    }),
                                    cells: [
                                      DataCell(Container(
                                          width: 80,
                                          child: Text(paymentEmployee))),
                                      DataCell(Container(
                                          width: 75,
                                          child: Text(
                                              paymentTime.substring(0, 10)))),
                                      DataCell(Container(
                                          width: 75,
                                          child: Text(
                                              "${price.toStringAsFixed(2).toString()} ₺"))),
                                      DataCell(Container(
                                          width: 40,
                                          child: TextButton(
                                            onPressed: () {
                                              paymentRemove(paymentId);
                                            },
                                            child: const Text("Sil"),
                                          ))),
                                    ]);
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )),
    );
  }

  Future getPaymentList(
    int companyIndex,
    int employeeIndex,
  ) async {
    String employeeId = "";
    String companyId = "";
    if (companyIndex > 0 && employeeIndex > 0) {
      employeeId = widget.companyAndEmployeeList[companyIndex - 1]["employees"]
          [employeeIndex - 1]["id"];
      companyId = widget.companyAndEmployeeList[companyIndex - 1]["id"];
    } else if (companyIndex > 0 && employeeIndex == 0) {
      companyId = widget.companyAndEmployeeList[companyIndex - 1]["id"];
    }
    print("$employeeId, sgsgsgss");
    try {
      var response = await Dio().post(AppUrl.dealerPaymentList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"companyId": companyId, "employeeId": employeeId});
      print("lagardaşşşşşşşşşşşşşşşşş $response");
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.dealerPaymentList,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"companyId": companyId, "employeeId": employeeId});
            print(response);
            return response;
          } on DioError catch (e) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("${e.response.toString()}"),
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

  Future takePayment(
      int companyIndex, int employeeIndex, String amountOfPayment) async {
    String companyId = "";
    String employeeId = "";
    double pureAmount = 0.0;
    if (amountOfPayment.contains(".")) {
      pureAmount = double.parse(amountOfPayment);
    } else {
      pureAmount = int.parse(amountOfPayment).toDouble();
    }
    if (companyIndex > 0 && employeeIndex > 0) {
      employeeId = widget.companyAndEmployeeList[companyIndex - 1]["employees"]
          [employeeIndex - 1]["id"];
      companyId = widget.companyAndEmployeeList[companyIndex - 1]["id"];
    } else if (companyIndex > 0 && employeeIndex == 0) {
      companyId = widget.companyAndEmployeeList[companyIndex - 1]["id"];
    }
    print(" iiiilllllllllllllaaaaaaaaaaaaaa  $employeeId");
    try {
      var response = await Dio().post(AppUrl.takePayment,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "companyId": companyId,
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
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.takePayment,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {
                  "companyId": companyId,
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

  Future paymentRemove(int paymentId) async {
    try {
      var response = await Dio().post(AppUrl.paymentRemove,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"paymentId": paymentId}).then((value) {
        _paymentTakeLoading.value = {"state": 1, "message": "Tahsilat Silindi"};
        setState(() {});
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.paymentRemove,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"paymentId": paymentId}).then((value) {
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
            })
        .then(
            (value) => _paymentTakeLoading.value = {"state": 0, "message": ""});
  }
}
