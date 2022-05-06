import 'package:caylar/constants/colors.dart';
import 'package:flutter/material.dart';

class ConfirmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConfirmePage();
  }
}

class _ConfirmePage extends State {
  @override
  Widget build(BuildContext context) {
    // Map arg= ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 106.3,
                color: Colors.brown,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Kayıt İşleminiz Başarılı",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.06,
                    fontFamily: 'Roboto'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Text(
                "Kayıt işleminiz gerçekleşmiştir",
                style: TextStyle(
                    fontSize: 13.37,
                    fontFamily: 'Roboto',
                    color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(
                height: 100.0,
              ),
              Container(
                margin: const EdgeInsets.only(top: 70),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: whiteColor, minimumSize: const Size(350, 40)),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/home"),
                    child: Text(
                      "Devam",
                      style: TextStyle(color: exColor),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
