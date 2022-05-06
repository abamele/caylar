import 'package:caylar/all_screens/new_pasword_code.dart';
import 'package:caylar/business_components/screens/add_employee_screen.dart';
import 'package:caylar/business_components/screens/scanner_add_employee.dart';
import 'package:caylar/business_components/screens/scanneradddealer.dart';
import 'package:caylar/business_components/screens/add_teashop_screen.dart';
import 'package:caylar/business_components/screens/business_add_employee.dart';
import 'package:caylar/business_components/screens/business_employee_screen.dart';
import 'package:caylar/business_components/screens/business_login.dart';
import 'package:caylar/business_components/screens/business_menu_screen.dart';
import 'package:caylar/business_components/screens/business_order_dealer_list.dart';
import 'package:caylar/business_components/screens/business_get_employelist.dart';
import 'package:caylar/business_components/screens/business_report_filtre.dart';
import 'package:caylar/all_screens/home_page_screen_1.dart';
import 'package:caylar/all_screens/home_page_screen_2.dart';
import 'package:caylar/business_components/screens/teashop_pass.dart';
import 'package:caylar/all_screens/await_and_cancel_orders.dart';
import 'package:caylar/employees/screens/employee_login.dart';
import 'package:caylar/employees/screens/employee_menu_screen.dart';
import 'package:caylar/employees/screens/employee_order_dealer_list.dart';
import 'package:caylar/employees/screens/employee_report_filtre.dart';
import 'package:caylar/employees/screens/employee_qr.dart';
import 'package:caylar/sme_components/screens/sme_payment_take_filtre.dart';
import 'package:caylar/sme_components/screens/products/add_product_screen.dart';
import 'package:caylar/sme_components/screens/products/product_photos_screen.dart';
import 'package:caylar/sme_components/screens/products/sme_product_edit_screen.dart';
import 'package:caylar/sme_components/screens/code_shared..dart';
import 'package:caylar/sme_components/screens/reports/sme_report_filtre.dart';
import 'package:caylar/sme_components/screens/sme_login.dart';
import 'package:caylar/sme_components/screens/order_screen.dart';
import 'package:caylar/sme_components/screens/mycostumer_screen.dart';
import 'package:caylar/all_screens/forgot_password_screen.dart';
import 'package:caylar/sme_components/screens/sme_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'all_screens/activation/activation_page.dart';
import 'all_screens/activation/confirm_page.dart';
import 'all_screens/all_login_register_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  await Hive.initFlutter("localdatabase");
  await Hive.openBox("caybox");
  await Hive.openBox("userbox");
  await Hive.openBox("rememberbox");
  if (Hive.box("caybox").length == 0) {
    await Hive.box("caybox").put("firstUse", false);
  }

  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("7ae97121-f5c9-4d3a-8f8e-432720924dc5");

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  // Hive.box("caybox").clear();
  // Hive.box("rememberbox").clear();
  // Hive.box("userbox").clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        //all route
        "/home": (BuildContext context) => SecondHome(),
        "/tanitim": ((context) => FirstHome()),
        // "/createqr":(BuildContext context) =>CreateQrScreen(),
        "/secondhome": (BuildContext context) => SecondHome(),
        "/login_register": (BuildContext context) => LoginRegisterScreen(),
        "/confirm": (BuildContext context) => ConfirmPage(),
        "/activation": (BuildContext context) => ActivationPage(),
        "/forgotpassword": (BuildContext context) => ForgotPassword(),
        "/newpasscode": (context) => NewPassCode(),

        // Çay Ocağı Giriş

        "/smeqr": (BuildContext context) => QrScreen(),
        "/smelogin": (context) => SmeLogin(),
        "/smeproductphotos": (BuildContext context) => ProductPhoto(),
        "/smeaddproduct": (BuildContext context) => AddProduct(),
        "/smemenu": (BuildContext context) => SmeMenuScreen(),
        "/smeorders": (BuildContext context) =>
            const WaitedAndCompletedScreen(),
        "/smereports": (BuildContext context) => const SmeReportFiltre(),
        "/smecostumers": (BuildContext context) => MyCostumer(),
        "/product_edit": (BuildContext context) => EditSmeProduct(),
        "/smepaymenttake": (BuildContext context) =>
            const SmePaymentTakeFiltre(),

        //Firma Giriş
        "/scanneradddealer": (BuildContext context) => const ScannerAddDealer(),
        "/scanneraddemployee": (BuildContext context) =>
            const ScannerAddEmployee(),
        "/businesslogin": (BuildContext context) => BusinessLogin(),
        "/businessmenu": (BuildContext context) => BusinessMenuScreen(),
        "/addtea": (BuildContext context) => AddTeaShopScreen(),
        "/addwithcode": (BuildContext context) => TeaShopPasswordScreen(),
        "/addwithcodeemployee": (BuildContext context) =>
            const BusinessAddEmployee(),
        "/businessorders": (BuildContext context) =>
            const BusinessOrderDealerList(),
        "/businessreports": (BuildContext context) =>
            const BusinessReportFiltre(),
        "/businessemployees": (BuildContext context) =>
            BusinessEmployeeScreen(),
        "/businessaddemployee": (BuildContext context) => AddEmployeeScreen(),
        "/businessbalance": (BuildContext context) =>
            BusinessGetEmployeeList(isBalancePage: true),
        "/businesspayreport": (BuildContext context) =>
            BusinessGetEmployeeList(isBalancePage: false),
        "/businessawaitandcancel": (BuildContext context) =>
            AwaitAndCancelOrders(UserType: 2),

        //Personel Giriş
        "/employeelogin": (context) => EmployeeLogin(),
        "/employeemenu": (BuildContext context) => EmployeeMenuScreen(),
        "/employeeorder": (BuildContext context) =>
            const EmployeeOrderDealerList(),
        "/employeereports": (BuildContext context) =>
            const EmployeeReportFiltre(),
        "/employeeqr": (BuildContext context) => EmployeeQrScreen(),
        "/employeeawaitandcancel": (BuildContext context) =>
            AwaitAndCancelOrders(UserType: 3),
      },
      initialRoute: isLogin(Hive.box("userbox").get("token"),
          Hive.box("userbox").get("userType")),
    );
  }

  isLogin(token, userType) {
    print("1-------------   ${Hive.box("userbox").get("token")}");
    print("2-------------   ${Hive.box("userbox").get("userType")}");
    print("2-------------   ${Hive.box("userbox").get("kod")}");
    print(
        "aaaaaaaaaaaaaaaaaaa-------------   ${Hive.box("userbox").get("dealerOfPerson")}");
    if (token != null && userType == 1) {
      return "/smemenu";
    } else if (token != null && userType == 2) {
      return "/businessmenu";
    } else if (token != null && userType == 3) {
      return "/employeemenu";
    } else if (token == null) {
      return "/home";
    }
  }
}
