// import 'package:caylar/business_components/models/employee.dart';
// import 'package:flutter/material.dart';

// class EmployeeListWidget extends StatefulWidget {
//   List<Employee> _employee = <Employee>[];
//   EmployeeListWidget(List<Employee> employee) {
//     this._employee = employee;
//   }

//   @override
//   State<StatefulWidget> createState() {
//     return _EmployeeListWidget();
//   }
// }

// class _EmployeeListWidget extends State<EmployeeListWidget> {
  
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
//             itemCount: widget._employee.length,
//             itemBuilder: (context, index) {
//               return Card(
//                   child: ListTile(
//                       title: Text(
//                 widget._employee[index].firstName +
//                     " " +
//                     widget._employee[index].lastName,
//                 style: TextStyle(fontFamily: 'Roboto', fontSize: 16,),
//               ),
//                   trailing: IconButton(icon: Icon(Icons.cancel, color: Color(0xFFEB0029),size: 37.61,), onPressed: () {
//                   },),
//                   ),

//               );
//             },

//           ),
//         ),
//       ],
//     );
//   }
// }
