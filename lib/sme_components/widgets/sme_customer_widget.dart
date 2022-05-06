// import 'package:flutter/material.dart';

// class SmeCustomerListWidget extends StatefulWidget {

//   @override
//   State<StatefulWidget> createState() {
//     return _SmeCustomerListWidget();
//   }
// }

// class _SmeCustomerListWidget extends State<SmeCustomerListWidget> {
  
//   @override
//   Widget build(BuildContext context) {
//     return buildProductList(context);
//   }

//   Widget buildProductList(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: 500,
//           child: ListView.builder(
//             itemCount: widget._customer.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 child: ListTile(
//                   title: Text(
//                     widget._customer[index].firstName +
//                         " " +
//                         widget._customer[index].lastName,
//                     style: TextStyle(fontFamily: 'Roboto', fontSize: 16,),
//                   ),
//                   trailing: IconButton(icon: Icon(Icons.cancel, color: Color(0xFFEB0029),size: 37.61,), onPressed: () {
//                   },),
//                 ),

//               );
//             },

//           ),
//         ),
//       ],
//     );
//   }
// }
