import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessPaymentReport extends StatefulWidget {
  late List dealerList;
  late List employeeList;
  BusinessPaymentReport(
      {Key? key, required this.dealerList, required this.employeeList})
      : super(key: key);
  @override
  State<BusinessPaymentReport> createState() => _BusinessPaymentReportState();
}

class _BusinessPaymentReportState extends State<BusinessPaymentReport> {
  int _value1 = 0;
  int _value2 = 0;
  ValueNotifier<String> amountOfPayment = ValueNotifier("");

  dealerOfCompanyList() {
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List dealersOfCompany = widget.dealerList;
    for (var i = 0; i < dealersOfCompany.length + 1; i++) {
      if (i == 0) {
        dropdownItemList.add(
          DropdownMenuItem(
            child: Text(
              "Tüm Çay Ocakları",
              style: TextStyle(color: exColor),
            ),
            value: 0,
          ),
        );
      } else {
        dropdownItemList.add(
          DropdownMenuItem(
            child: Text(
              dealersOfCompany[i - 1]["name"].toString(),
              style: TextStyle(color: exColor),
            ),
            value: i,
          ),
        );
      }
    }
    print(dealersOfCompany);
    return dropdownItemList;
  }

  dealerOfEmployeeList(_value1) {
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List employeeOfCompany = widget.employeeList;
    print("asdaddadsasdasasd       ------ s$_value1");
    for (var i = 0; i < employeeOfCompany.length + 1; i++) {
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
        print(employeeOfCompany[i - 1]["nameSurname"].toString());
        dropdownItemList.add(
          DropdownMenuItem(
            child: Text(
              employeeOfCompany[i - 1]["nameSurname"].toString(),
              style: TextStyle(color: exColor),
            ),
            value: i,
          ),
        );
      }
    }
    print(employeeOfCompany);
    return dropdownItemList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: WidgetDrawer(
            drawerType: 2,
          ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: crimsonColor,
                  title: const Text("Tahsilatlar"),
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
                              items: dealerOfCompanyList(),
                              onChanged: (int? value) {
                                _value1 = value!;
                                setState(() {});
                              },
                              hint: const Text("Çay ocağı seçiniz")),
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
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: (BorderRadius.circular(12))),
                          child: DropdownButton(
                              isExpanded: true,
                              value: _value2,
                              items: dealerOfEmployeeList(_value1),
                              onChanged: (int? value) {
                                _value2 = value!;
                                setState(() {});
                              },
                              hint: const Text("Personel seçiniz")),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Material(
              color: lightGrey,
              child: FutureBuilder(
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
                  if (snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data as Map<String, dynamic>;
                  Map paymentInfo = data["data"];
                  double totalPayment =
                      paymentInfo["totalPayment"].runtimeType == int
                          ? paymentInfo["totalPayment"].toDouble()
                          : paymentInfo["totalPayment"];
                  double remainDebt =
                      paymentInfo["remainDebt"].runtimeType == int
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
                                child: Text("Toplam Borç:",
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
                                child: Text(
                                    "${totalPayment.toStringAsFixed(2)}₺",
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
                                child: Text("${remainDebt.toStringAsFixed(2)}₺",
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
                  List payments = data["data"]["payments"];

                  return Column(
                    children: [
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Toplam Alışveriş:",
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
                            child: Text("${remainDebt.toStringAsFixed(2)}₺",
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
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                    return crimsonColor;
                                  }),
                                  columns: const [
                                    DataColumn(
                                        label: Text(
                                      'Ödeme Yapan',
                                      style: TextStyle(color: Colors.white),
                                    )),
                                    DataColumn(
                                        label: Text('Ödeme Tarihi',
                                            style: TextStyle(
                                                color: Colors.white))),
                                    DataColumn(
                                        label: Text('Tutar',
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ],
                                  rows: List.generate(payments.length, (index) {
                                    final paymentEmployee = payments[index]
                                            ["employeeName"]
                                        .toString();
                                    double paymentPrice = payments[index]
                                                    ["price"]
                                                .runtimeType ==
                                            int
                                        ? payments[index]["price"].toDouble()
                                        : payments[index]["price"];
                                    final paymentDate = payments[index]
                                            ["paymentTime"]
                                        .toString();

                                    return DataRow(
                                        color: MaterialStateProperty
                                            .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
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
                                              child: Text(paymentDate.substring(
                                                  0, 10)))),
                                          DataCell(Container(
                                              width: 75,
                                              child: Text(
                                                  "${paymentPrice.toStringAsFixed(2).toString()} ₺"))),
                                        ]);
                                  }),
                                ),
                              )),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          )),
    );
  }

  Future getPaymentList(
    int dealerIndex,
    int employeeIndex,
  ) async {
    String dealerId = "";
    String employeeId = "";
    if (dealerIndex > 0 && employeeIndex > 0) {
      dealerId = widget.dealerList[dealerIndex - 1]["id"];
      employeeId = widget.employeeList[employeeIndex - 1]["id"];
    } else if (dealerIndex > 0 && employeeIndex == 0) {
      dealerId = widget.dealerList[dealerIndex - 1]["id"];
    } else if (dealerIndex == 0 && employeeIndex > 0) {
      employeeId = widget.employeeList[employeeIndex - 1]["id"];
    }
    print("şirket $dealerId     personel  $employeeId");
    try {
      var response = await Dio().post(AppUrl.companyPaymentList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"employeeId": employeeId, "dealerId": dealerId});
      print(
          "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr ${response}");
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.paymentList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "companyId": companyId,
          //         "employeeId": employeeId,
          //       });
          //   print(
          //       "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr ${response}");
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
