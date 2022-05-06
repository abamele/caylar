import 'package:caylar/all_widgets/drawer.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/employees/screens/employee_order_screen.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeeOrderDealerList extends StatefulWidget {
  const EmployeeOrderDealerList({Key? key}) : super(key: key);

  @override
  State<EmployeeOrderDealerList> createState() =>
      _EmployeeOrderDealerListState();
}

class _EmployeeOrderDealerListState extends State<EmployeeOrderDealerList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDealerList(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Text('Bir şeyler yanlış gitti'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> data = snapshot.data.data as Map<String, dynamic>;
        print("datatatta $data");
        if (data["data"] == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Sipariş Ver"),
              backgroundColor: crimsonColor,
            ),
            drawer: WidgetDrawer(drawerType: 3),
            body: Center(
              child: Text(data["message"]),
            ),
          );
        }
        List dealerList = data["data"];
        return Scaffold(
          body: EmployeeOrderScreen(
            dealerList: dealerList,
          ),
        );
      },
    );
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
            "companyId": Hive.box("userbox").get("personId").toString(),
          });
      return response;
    } on DioError catch (e) {
      if (e.response!.data["errorCode"] == 2023) {
        tokenUpdate(context).then((value) async {
          Hive.box("userbox").put("token", value.data["data"]).then((value) {
            setState(() {});
          });
          // try {
          //   var response = await Dio().post(AppUrl.dealerList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "companyId": Hive.box("userbox").get("personId").toString(),
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
}
