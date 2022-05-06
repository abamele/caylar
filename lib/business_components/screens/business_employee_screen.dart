import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/colors.dart';

class BusinessEmployeeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BusinessEmployeeScreen();
  }
}

class _BusinessEmployeeScreen extends State {
  final ValueNotifier<Map> _delEmployeeLoading =
      ValueNotifier<Map>({"state": 0, "message": ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: const Center(
                child: Text(
              "Personel Ekle",
              style: TextStyle(fontSize: 17),
            ))),
        onPressed: () {
          Navigator.pushNamed(context, "/businessaddemployee");
        },
        // shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: crimsonColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
        title: const Text(
          "Personellerim",
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: WidgetDrawer(drawerType: 2),
      body: FutureBuilder(
        future: getEmployeeList(),
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
          if (data["errorCode"] == 2107) {
            return Container(
              child: Center(child: Text(data["message"].toString())),
            );
          }
          List employeeList = data["data"];
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: employeeList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == employeeList.length) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      );
                    }
                    if (employeeList[index]["iscompany"]) {
                      return Container();
                    }
                    return Card(
                      child: ListTile(
                        title: Text(
                          employeeList[index]["nameSurname"].toString(),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: crimsonColor,
                            size: 37.61,
                          ),
                          onPressed: () {
                            delEmployee(employeeList[index]["id"]);
                            showDelEmployeeDialog();
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                )
              ],
            ),
          );
        },
      ),
    );
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
            // "name": "string"
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
          //   var response = await Dio().post(AppUrl.employeeList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         // "name": "string"
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

  Future delEmployee(employeeId) async {
    try {
      var response = await Dio().post(AppUrl.employeeRemove,
          options: Options(headers: {
            "Authorization":
                "Bearer ${Hive.box("userbox").get("token").toString()}",
            "Content-Type": "application/json"
          }),
          data: {"employeeId": employeeId}).then((value) {
        _delEmployeeLoading.value = {
          "state": 1,
          "message": "Personel Silindi."
        };
      });
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]);
          try {
            var response = await Dio().post(AppUrl.employeeRemove,
                options: Options(headers: {
                  "Authorization":
                      "Bearer ${Hive.box("userbox").get("token").toString()}",
                  "Content-Type": "application/json"
                }),
                data: {"employeeId": employeeId}).then((value) {
              _delEmployeeLoading.value = {
                "state": 1,
                "message": "Personel Silindi."
              };
            });
          } on DioError catch (e) {
            _delEmployeeLoading.value = {
              "state": 2,
              "message": "${e.response!.data["message"]}"
            };
          }
        });
      } else {
        _delEmployeeLoading.value = {
          "state": 2,
          "message": "${e.response!.data["message"]}"
        };
      }
    }
  }

  showDelEmployeeDialog() {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _delEmployeeLoading,
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
                                setState(() {});
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
            (value) => _delEmployeeLoading.value = {"state": 0, "message": ""});
  }
}
