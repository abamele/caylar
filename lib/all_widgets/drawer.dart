import 'package:caylar/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WidgetDrawer extends StatefulWidget {
  late int drawerType;
  WidgetDrawer({Key? key, required this.drawerType}) : super(key: key);

  @override
  _WidgetDrawerState createState() => _WidgetDrawerState();
}

class _WidgetDrawerState extends State<WidgetDrawer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        // backgroundColor: crimsonColor,
        child: SingleChildScrollView(
            child: Container(
          height: MediaQuery.of(context).size.height - 33,
          child: Column(
            children: [
              myDrawerHeader(widget.drawerType),
              // Divider(
              //   color: whiteColor,
              //   height: 20,
              // ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage("assets/backgroudimage.png"),
                          alignment: Alignment.bottomCenter),
                      color: crimsonColor),
                  child: drowerType(widget.drawerType),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget myDrawerHeader(userType) {
    if (userType == 1) {
      return DrawerHeader(
        child: Center(
          child: Text(
            Hive.box("userbox").get("dealerName").toString(),
            style:
                TextStyle(fontFamily: 'Roboto', fontSize: 25, color: exColor),
          ),
        ),
      );
    } else if (userType == 2) {
      return DrawerHeader(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              Hive.box("userbox").get("companyName").toString(),
              style:
                  TextStyle(fontFamily: 'Roboto', fontSize: 25, color: exColor),
            ),
            Text(
              Hive.box("userbox").get("officialName").toString(),
              style:
                  TextStyle(fontFamily: 'Roboto', fontSize: 25, color: exColor),
            ),
          ],
        ),
      );
    } else {
      return DrawerHeader(
        child: Center(
          child: Text(
            Hive.box("userbox").get("personName").toString(),
            style:
                TextStyle(fontFamily: 'Roboto', fontSize: 25, color: exColor),
          ),
        ),
      );
    }
  }

  Widget myDrawerItem(String title, String routeName) {
    return Container(
      child: ListTile(
          title: Center(
              child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontFamily: 'Roboto',
            ),
          )),
          onTap: () {
            //eger başka sayfaya gidiş-dönüş yapıp menu kapanmıyorsa aşağıdadi yöntem kullanın
            //scaffoldKey.currentState!.openEndDrawer();
            int userType = Hive.box("userbox").get("userType");
            if (title == "Çıkış") {
              Hive.box("userbox").clear();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  "/home", (Route<dynamic> route) => false);
            } else if (userType == 1) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  routeName, ModalRoute.withName("/smemenu"));
            } else if (userType == 2) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  routeName, ModalRoute.withName("/businessmenu"));
            } else if (userType == 3) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  routeName, ModalRoute.withName("/employeemenu"));
            }
          }),
    );
  }

  drowerType(int drawerType) {
    if (drawerType == 1) {
      return Column(
        children: [
          myDrawerItem("Siparişler", "/smeorders"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Kod Oluştur", "/smeqr"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Kendi Ürününü Ekle", "/smeaddproduct"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Sabit Ürünlerden Ekle", "/smeproductphotos"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Menü", "/product_edit"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Raporlar", "/smereports"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Tahsilat", "/smepaymenttake"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Müşteriler", "/smecostumers"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Çıkış", "/home"),
        ],
      );
    } else if (drawerType == 2) {
      return Column(
        children: [
          myDrawerItem("Çay Ocağı Ekle", "/addtea"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Sipariş Ver", "/businessorders"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Siparişlerim", "/businessawaitandcancel"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Raporlar", "/businessreports"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Tahsilatlar", "/businesspayreport"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Bakiye Tanımlama", "/businessbalance"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Personeller", "/businessemployees"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Çıkış", "/home"),
        ],
      );
    } else {
      return Column(
        children: [
          myDrawerItem("Sipariş Ver", "/employeeorder"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Kod Paylaş", "/employeeqr"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Siparişlerim", "/employeeawaitandcancel"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Raporlar", "/employeereports"),
          Divider(
            color: whiteColor,
            height: 20,
          ),
          myDrawerItem("Çıkış", "/home"),
        ],
      );
    }
  }
}
