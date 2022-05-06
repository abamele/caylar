import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/employees/screens/employee_report_screen.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeeReportFiltre extends StatefulWidget {
  const EmployeeReportFiltre({Key? key}) : super(key: key);

  @override
  State<EmployeeReportFiltre> createState() => _EmployeeReportFiltreState();
}

class _EmployeeReportFiltreState extends State<EmployeeReportFiltre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getDealerList(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir şeyler yanlış gitti.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> data1 = snapshot.data.data as Map<String, dynamic>;
        if (data1["data"] == null) {
          return Text("$data1['message']");
        }
        List dealerList = data1["data"];
        return EmployeeReportScreen(
          dealerList: dealerList,
        );
      },
    ));
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
          // try {
          //   var response = await Dio().post(AppUrl.dealerList,
          //       options: Options(headers: {
          //         "Authorization":
          //             "Bearer ${Hive.box("userbox").get("token").toString()}",
          //         "Content-Type": "application/json"
          //       }),
          //       data: {
          //         "companyId": Hive.box("userbox").get("companyId").toString(),
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
