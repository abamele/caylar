import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../all_widgets/drawer.dart';

class MyCostumer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyCostumerState();
  }
}

class _MyCostumerState extends State {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: crimsonColor,
          title: const Text(
            "Müşterilerim",
            style: TextStyle(
                fontFamily: 'Roboto', fontSize: 20, color: Colors.white),
          ),
        ),
        drawer: WidgetDrawer(
          drawerType: 1,
        ),
        body: SizedBox(
          height: 500,
          child: FutureBuilder(
            future: getCompanyList(),
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
              if (data["data"] == null) {
                return const Center(
                  child: Text("Şuanda müşteriniz bulunmamaktadır."),
                );
              }
              List companyList = data["data"];
              print(companyList);
              return ListView.builder(
                itemCount: companyList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ExpansionTile(
                      title: Text(
                        companyList[index]["name"].toString(),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        const Divider(),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: companyList[index]["employees"].length,
                            itemBuilder: (BuildContext context, int index2) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Personel İsmi: ",
                                      style: TextStyle(color: crimsonColor),
                                    ),
                                    Text(companyList[index]["employees"][index2]
                                        ["nameSurname"]),
                                  ],
                                ),
                              );
                            })
                      ],
                      trailing: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: crimsonColor,
                          size: 37.61,
                        ),
                        onPressed: () {
                          removeCompany(companyList[index]["id"]);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future getCompanyList() async {
    try {
      var response = await Dio().post(AppUrl.companyList,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {
            // "search": "string"
          });
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.companyList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         // "search": "string"
          //       });
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
          //                 child: Text("Kapat"))
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
                      child: Text("Kapat"))
                ],
              );
            });
      }
    }
  }

  Future removeCompany(companyId) async {
    try {
      var response = await Dio().post(AppUrl.companyRemove,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"companyId": companyId});
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.companyRemove,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"companyId": companyId});
            return response;
          } on DioError catch (e) {
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
