// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class WidgetEmployeeRegister extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return _WidgetEmployeeRegister();
//   }

// }

// class _WidgetEmployeeRegister extends State{
//   late String usernameOrPhoneNumber;
//   late String password;
//   late String repeatPassword;
//   late String email;
//   late String smeName;
//   late String nameSurname;
//   late bool value = false;
//   final formkey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Color(0xFFEFEFEF),
//       child:SingleChildScrollView (
//         scrollDirection: Axis.vertical,
//         child:Container(
//           child: Form(
//             key: formkey,
//             child: Padding(
//               padding: EdgeInsets.all(15.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "Kullanıcı Adı veya Telefon Numaranız",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "Şifre",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "Şifre Tekrar",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "E-Posta",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "Firma Kodunuz",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFFEB0029))),
//                       labelText: "Adınız Soyadınız",
//                       labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Roboto'),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   CheckboxListTile(
//                       controlAffinity: ListTileControlAffinity.leading,
//                       title: Text(
//                         "Kullanıcı Sözleşmesini Okudum ve Kabul Ediyorum",
//                         style: TextStyle(fontSize: 12.50),
//                       ),
//                       value: value,
//                       onChanged: (value) =>
//                           setState(() => this.value = value!)),
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   ElevatedButton(
//                     child: Text(
//                       "Kayıt Ol",
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.white,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       primary: Color(0xFFEB0029),
//                       minimumSize: Size(318, 43.38),
//                     ),
//                     onPressed: () =>
//                         Navigator.pushNamed(context, "/activation"),
//                   ),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       MaterialButton(
//                           child: Text("Zaten hesabınız var mı?"),
//                           onPressed: () {}),
//                       MaterialButton(
//                           child: Text("Giriş Yap"), onPressed: () =>Navigator.pushNamed(context, "/login"))
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),

//       ),
//     );
//   }
// }