import 'package:caylar/business_components/screens/business_login.dart';
import 'package:caylar/constants/colors.dart';
import 'package:caylar/employees/screens/employee_login.dart';
import 'package:caylar/sme_components/screens/sme_login.dart';
import 'package:flutter/material.dart';

import '../all_widgets/register_widget.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginRegisterScreen();
  }
}

class _LoginRegisterScreen extends State with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context)!.settings.arguments as Map;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: whiteColor,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: crimsonColor,
              title: userTypeTitle(arg["userType"]),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: "Giriş Yap",
                  ),
                  Tab(
                    text: "Kayıt Ol",
                  ),
                ],
                indicatorColor: Colors.white,
                indicatorWeight: 6.0,
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                userTypeLoginWidget(arg["userType"]),
                WidgetRegister(userType: arg["userType"]),
              ],
            )));
  }

  userTypeLoginWidget(int userType) {
    if (userType == 1) {
      return SmeLogin();
    } else if (userType == 2) {
      return BusinessLogin();
    } else if (userType == 3) {
      return EmployeeLogin();
    }
  }

  userTypeTitle(int userType) {
    if (userType == 1) {
      return const Text("Çay Ocağı Giriş");
    } else if (userType == 2) {
      return const Text("Firma Giriş");
    } else if (userType == 3) {
      return const Text("Personel Giriş");
    }
  }
}
