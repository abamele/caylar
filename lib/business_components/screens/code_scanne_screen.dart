
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// import '../widgets/button_widget.dart';

// class QrScanner extends StatefulWidget {
//   const QrScanner({ Key? key }) : super(key: key);

//   @override
//   _QrScannerState createState() => _QrScannerState();
// }

// class _QrScannerState extends State<QrScanner> {
//     String qrCode = 'Unknown';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
         
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'Scan Result',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white54,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 '$qrCode',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 72),
//               ButtonWidget(
//                 text: "Qr oku",
//                 onClicked: () => scanQRCode(),
//               ),
//             ],
//           ),
//         ),
//       );
//   }

  
//   Future<void> scanQRCode() async {
//     try {
//       final qrCode = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.QR,
//       );

//       if (!mounted) return;

//       setState(() {
//         this.qrCode = qrCode;
//       });
//     } on Exception{
//       qrCode = 'Failed to get platform version.';
//     }
//   }
// }