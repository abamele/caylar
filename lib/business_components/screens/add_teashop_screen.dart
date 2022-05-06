import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AddTeaShopScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTeaShopScreen();
  }
}

class _AddTeaShopScreen extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: crimsonColor,
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: crimsonColor,
      body: Container(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Çay Ocağı Ekle",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'Roboto'),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                    margin: const EdgeInsets.only(left: 50.0, right: 35.0),
                    child: const Text(
                      "Sipariş Vermek ve Uygulamayı kullanabilmek için Çay Ocağı Ekleyiniz",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.37,
                          fontFamily: 'Roboto'),
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    child: const Text(
                      "Kod İle Ekle",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8C6F4B),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: Size(318, 71.79),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: new BorderSide(color: Color(0xFF654B2A)))),
                    onPressed: () =>
                        Navigator.pushNamed(context, "/addwithcode")),
                const SizedBox(
                  height: 12.0,
                ),
                ElevatedButton(
                    child: const Text(
                      "Kare Kod İle Ekle",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8C6F4B),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: Size(318, 71.79),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: new BorderSide(color: Color(0xFF654B2A)))),
                    onPressed: () =>
                        Navigator.pushNamed(context, "/scanneradddealer")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
