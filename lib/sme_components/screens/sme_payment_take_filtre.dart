import 'package:caylar/constants/apihttp.dart';
import 'package:caylar/services/update_token.dart';
import 'package:caylar/sme_components/screens/sme_payment_take.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SmePaymentTakeFiltre extends StatefulWidget {
  const SmePaymentTakeFiltre({Key? key}) : super(key: key);

  @override
  State<SmePaymentTakeFiltre> createState() => _SmePaymentTakeFiltreState();
}

class _SmePaymentTakeFiltreState extends State<SmePaymentTakeFiltre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getCompanyList(),
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
        Map<String, dynamic> data = snapshot.data.data as Map<String, dynamic>;
        if (data["data"] == null) {
          return const Center(
              child: Text(
                  "Şuan Herhangi bir firma ile bağlantınız bulunmamaktadır."));
        }
        List companyAndEmployeeList = data["data"];
        print(companyAndEmployeeList.toString());
        return SmePaymentTake(
          companyAndEmployeeList: companyAndEmployeeList,
        );
      },
    ));
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
          //   var response = await Dio().post(AppUrl.companyList,
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
