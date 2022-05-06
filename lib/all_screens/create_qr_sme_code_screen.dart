// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class CreateQrScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _CreateQrScreen();
//   }
// }

// class _CreateQrScreen extends State {
//   TextEditingController _editingController = TextEditingController(text: '');
//   String data = "CAYCIABA";

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xFFF8F8F8),
//         body: ListView(
//           children: [
//             Center(
//               child: Padding(
//                 padding: EdgeInsets.only(top: 80.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Kodunuz: $data",
//                       style: const TextStyle(fontSize: 20, fontFamily: "Roboto"),
//                     ),
//                     const SizedBox(
//                       height: 20.0,
//                     ),
//                     Center(
//                       child: QrImage(
//                         data: data,
//                         version: QrVersions.auto,
//                         size: 300.0,
//                       ),
//                     ),

//                     const SizedBox(
//                       height: 100.0,
//                     ),
//                     Center(
//                       child: Container(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const SizedBox(
//                               width: 10.0,
//                             ),
//                             ElevatedButton(
//                                 child: const Text(
//                                   "Paylaş",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: Color(0xFFFFFFFF),
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   primary: const Color(0xFFEB0029),
//                                   minimumSize: const Size(153.53, 43.38),
//                                 ),
//                                 onPressed: () {}),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// extension HexColor on Color {
//   /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
//   static Color fromHex(String hexString) {
//     final buffer = StringBuffer();
//     if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
//     buffer.write(hexString.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }
// }
