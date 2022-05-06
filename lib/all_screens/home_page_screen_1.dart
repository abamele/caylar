import 'package:caylar/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FirstHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FirstHome();
  }
}

class _FirstHome extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: crimsonColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              reverse: true,
              child: Material(
                elevation: 8,
                shape: CircleBorder(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  splashColor: Colors.black26,
                  onTap: () {},
                  child: Container(
                    child: Ink.image(
                      image: const AssetImage(
                        'assets/cay.png',
                      ),
                      height: 100,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              "Çaykolik",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                fontSize: 32.0,
              ),
            ),
            const SizedBox(
              height: 100.0,
            ),
            const Text(
              "Online Çayınız",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Container(
                margin: const EdgeInsets.only(left: 65.0, right: 55.0),
                child: const Text(
                  "Uygulama içinden, hızlıca sipariş verebilir, geçmiş siparişleriniz raporlayabilirsiniz",
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                )),
            const SizedBox(
              height: 85.0,
            ),
            ElevatedButton(
                child: const Text(
                  "İleri",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFFFFFF),
                  minimumSize: const Size(153.53, 43.38),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/secondhome");
                  Hive.box("caybox").put("firstUse", true);
                }),
          ],
        ),
      ),
    );
  }
}
