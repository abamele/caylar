//Bu sayfa Login ve Register işlemlerinin yapıldığı sayfadır. Ancak ugulamada 3 farklı login ve register işlemi olduğu için bu safya pushName yoluyla userType isimli değişken gönderilir.
//userType=1 ise cay ocagı
//userType=2 ise firma
//userType=3 ise personel

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/colors.dart';

class SecondHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SecondHome();
  }
}

class _SecondHome extends State {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (Hive.box("caybox").get("firstUse") == false) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            "/tanitim", (Route<dynamic> route) => false);
      } else {
        null;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: SingleChildScrollView(
                reverse: true,
                child: Material(
                  elevation: 8,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    splashColor: Colors.black26,
                    onTap: () {},
                    child: Ink.image(
                      image: const AssetImage('assets/cay.png'),
                      height: 90,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Çaykolik",
              style: TextStyle(
                color: Color(0xFF8C6F4B),
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                fontSize: 32.0,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Lütfen kayıt/giriş tipi seçiniz...",
              style: TextStyle(color: Color(0xFF8C6F4B), fontSize: 19.98),
            ),
            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                child: const Text(
                  "Çay Ocağı",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C6F4B),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: const Size(318, 71.79),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color(0xFF654B2A)))),
                onPressed: () => Navigator.pushNamed(context, "/login_register",
                    arguments: {"userType": 1})),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
                child: const Text(
                  "Firma",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C6F4B),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: const Size(318, 71.79),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color(0xFF654B2A)))),
                onPressed: () => Navigator.pushNamed(context, "/login_register",
                    arguments: {"userType": 2})),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
                child: const Text(
                  "Personel",
                  style: TextStyle(fontSize: 14, color: Color(0xFF8C6F4B)),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: const Size(318, 71.79),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color(0xFF654B2A)))),
                onPressed: () => Navigator.pushNamed(context, "/login_register",
                    arguments: {"userType": 3})),
            // ElevatedButton(
            //     onPressed: () async {
            //       Navigator.pushNamed(context, "/confirm");
            //     },
            //     child: Text("aasdasada"))
            // ElevatedButton(
            //     onPressed: () async {
            //       AndroidDeviceInfo androidInfo =
            //           await deviceInfoPlugin.androidInfo;
            //       print(androidInfo.androidId);
            //       print(androidInfo.device);
            //       print(androidInfo.model);
            //       print(androidInfo.id);
            //       print(androidInfo.version);
            //       print(androidInfo.board);
            //       print(androidInfo.bootloader);
            //       print(androidInfo.brand);
            //       Navigator.pushNamed(context, "/newpasscode",arguments: {"phone":"05398461416"});
            //     },
            //     child: Text("aasdasada"))
          ],
        ),
      ),
    );
  }
}
