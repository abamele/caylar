import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../all_widgets/drawer.dart';
import '../../constants/colors.dart';

class QrScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QrScreen();
  }
}

class _QrScreen extends State {
  final TextEditingController _editingController =
      TextEditingController(text: '');
  String data = Hive.box("userbox").get("kod").toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: const Center(
                child: Text(
              "Paylaş",
              style: TextStyle(fontSize: 17),
            ))),
        onPressed: () async {
          await Share.share(data);
        },
        // shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: crimsonColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: crimsonColor,
      ),
      drawer: WidgetDrawer(
        drawerType: 1,
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Kodunuz: $data",
                    style: const TextStyle(fontSize: 20, fontFamily: "Roboto"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: QrImage(
                      data: data,
                      version: QrVersions.auto,
                      size: 300.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
