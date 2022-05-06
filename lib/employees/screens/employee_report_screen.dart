import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../all_widgets/drawer.dart';

class EmployeeReportScreen extends StatefulWidget {
  late List dealerList;
  EmployeeReportScreen({Key? key, required this.dealerList}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _EmployeeReportScreen();
}

class _EmployeeReportScreen extends State<EmployeeReportScreen> {
  int? _value;
  DateTime selectedDate = DateTime.now();
  DateTime? dateTime1;
  DateTime? dateTime2;
  String reportStart =
      DateTime.now().add(const Duration(days: -7)).toString().substring(0, 10);
  String reportEnd = DateTime.now().toString().substring(0, 10);

  companyOfDealerList() {
    print(widget.dealerList);
    List<DropdownMenuItem<int>> dropdownItemList = [];
    List dealersOfCompany = widget.dealerList;
    for (var i = 0; i < dealersOfCompany.length; i++) {
      dropdownItemList.add(
        DropdownMenuItem(
          child: Text(
            dealersOfCompany[i]["name"].toString(),
            style: TextStyle(color: exColor),
          ),
          value: i,
        ),
      );
    }
    return dropdownItemList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: WidgetDrawer(
            drawerType: 3,
          ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: crimsonColor,
                  title: const Text("Raporlar"),
                  actions: [
                    IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh))
                  ],
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
                              value: _value,
                              items: companyOfDealerList(),
                              onChanged: (int? value) {
                                _value = value!;
                                setState(() {});
                              },
                              hint: const Text("Çay ocağı seçiniz.")),
                        ),
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
            body: Material(
              color: whiteColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: whiteColor,
                            side: BorderSide(color: exColor),
                          ),
                          onPressed: () {
                            _openDatePicker1(context);
                          },
                          child: dateTime1 == null
                              ? Text(
                                  "Başlangıç Tarihi",
                                  style: TextStyle(color: exColor),
                                )
                              : Text(
                                  dateTime1.toString().substring(0, 10),
                                  style: TextStyle(color: exColor),
                                )),
                      const SizedBox(
                        width: 7,
                      ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: whiteColor,
                            side: BorderSide(color: exColor),
                          ),
                          onPressed: () {
                            _openDatePicker2(context);
                          },
                          child: dateTime2 == null
                              ? Text(
                                  "Bitiş Tarihi",
                                  style: TextStyle(color: exColor),
                                )
                              : Text(
                                  dateTime2.toString().substring(0, 10),
                                  style: TextStyle(color: exColor),
                                )),
                      const SizedBox(
                        width: 7,
                      ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: whiteColor,
                            side: BorderSide(color: exColor),
                          ),
                          onPressed: () {
                            if (dateTime1 == null) {
                            } else if (dateTime2 == null) {
                              // reportStart =
                              //     dateTime1.toString().substring(0, 10);
                              // reportEnd =
                              //     DateTime.now().toString().substring(0, 10);
                              // setState(() {});
                            } else {
                              reportStart =
                                  dateTime1.toString().substring(0, 10);
                              reportEnd = dateTime2.toString().substring(0, 10);
                              setState(() {});
                            }
                          },
                          child: Text(
                            "Filtrele",
                            style: TextStyle(color: exColor),
                          ))
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: FutureBuilder(
                            future: getReport(_value, reportStart, reportEnd),
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
                              if (data["errorCode"] != 0) {
                                return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child:
                                        Center(child: Text(data["message"])));
                              }
                              if (data["data"]["reports"] == null) {
                                print(data.toString());
                                return Text(data.toString());
                              }
                              List _reports = data["data"]["reports"];

                              return DataTable(
                                // columnSpacing: 38.0,
                                columns: const [
                                  DataColumn(label: Text('Sipariş Veren')),
                                  DataColumn(label: Text('Ürün Adı')),
                                  DataColumn(label: Text('Adet')),
                                  DataColumn(label: Text('Tutar')),
                                  DataColumn(label: Text('Kalan Bakiye')),
                                  DataColumn(label: Text('Tarih')),
                                ],
                                rows: List.generate(_reports.length, (index) {
                                  final persOrder =
                                      _reports[index]["nameSurname"].toString();
                                  final productName =
                                      _reports[index]["productName"].toString();
                                  final quantity =
                                      _reports[index]["quantity"].toString();
                                  double productPrice = _reports[index]
                                                  ["productPrice"]
                                              .runtimeType ==
                                          int
                                      ? _reports[index]["productPrice"]
                                          .toDouble()
                                      : _reports[index]["productPrice"];
                                  final remainingBalance = _reports[index]
                                          ["remainingBalance"]
                                      .toString();
                                  final orderDate =
                                      _reports[index]["orderDate"].toString();

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
                                            width: 80, child: Text(persOrder))),
                                        DataCell(Container(
                                            width: 80,
                                            child: Text(productName))),
                                        DataCell(Container(
                                            width: 40, child: Text(quantity))),
                                        DataCell(Container(
                                            width: 75,
                                            child: Text(
                                                "${productPrice.toStringAsFixed(2)} ₺"))),
                                        DataCell(Container(
                                            width: 75,
                                            child:
                                                Text("$remainingBalance ₺"))),
                                        DataCell(Container(
                                            width: 75, child: Text(orderDate)))
                                      ]);
                                }),
                              );
                            },
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<void> _openDatePicker1(BuildContext context) async {
    dateTime1 = await showDatePicker(
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
    dateTime2 = await showDatePicker(
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

  Future getReport(int? index, String reportStart, String reportEnd) async {
    String dealerId = "";
    if (index != null) {
      dealerId = widget.dealerList[index]["id"];
    }
    try {
      var response = await Dio().post(AppUrl.employeeReport,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            "dealerId": dealerId,
            "reportStart": reportStart,
            "reportEnd": reportEnd
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
          //   var response = await Dio().post(AppUrl.employeeReport,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "dealerId": dealerId,
          //         "reportStart": reportStart,
          //         "reportEnd": reportEnd
          //       });
          //   print(response);
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
