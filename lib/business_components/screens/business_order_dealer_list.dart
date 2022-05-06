import 'package:caylar/business_components/screens/business_order_screen.dart';
import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/services/update_token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessOrderDealerList extends StatefulWidget {
  const BusinessOrderDealerList({Key? key}) : super(key: key);

  @override
  State<BusinessOrderDealerList> createState() =>
      _BusinessOrderDealerListState();
}

class _BusinessOrderDealerListState extends State<BusinessOrderDealerList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getDealerList(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: const Text('Bir şeyler yanlış gitti.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> data = snapshot.data.data as Map<String, dynamic>;
        if (data["data"] == null) {
          return const Center(
            child: Text("Bağlantıda olduğunuz bir çay ocağı bulunmamaktadır."),
          );
        }
        List dealerList = data["data"];
        return BusinessOrderScreen(
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
