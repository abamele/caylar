
// import 'package:flutter/material.dart';
// import 'package:line_icons/line_icons.dart';

// import '../../../all_widgets/drawer.dart';

// class ProductList extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _ProductListState();
//   }
// }

// class _ProductListState extends State {


//   @override
//   void initState() {
//     //getProduct();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0.0,
//           backgroundColor: Color(0xFFEB0029),
//           title: const Text(
//             "Ürünlerim",
//             style: TextStyle(
//                 color: Colors.white, fontSize: 20, fontFamily: 'Roboto'),
//           ),
          
//         ),
//         drawer: WidgetDrawer(drawerType: 1,),
//         body: SafeArea(
//           child: Container(
//             margin: EdgeInsets.only(top: 20.0),
//             child: ListView.builder(
//               itemCount: products.length,
//               itemBuilder:(BuildContext context, int position){
//                 return ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Material(
//                             elevation: 8,
//                             child: Container(
//                               height: 50.0,
//                               width: 380,
//                               child: const TextField(
//                                 decoration: InputDecoration(
//                                   focusedBorder: OutlineInputBorder(
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   border: OutlineInputBorder(borderSide: BorderSide.none),
//                                   hintText: 'Search',
//                                   hintStyle: TextStyle(color: Color(0xFF8C6F4B),),
//                                   suffixIcon: Icon(LineIcons.search, color: Color(0xFF8C6F4B),),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: 160,
//                               width: MediaQuery.of(context).size.width,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                     top: 8.0, bottom: 8.0, left: 10.0, right: 10.0),

//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.vertical,
//                                   child: Column(
//                                     children: [
//                                       buildProductList(products[position]),


//                                     ],
//                                   ),
//                                 ),

//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 20.0,
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 20.0),
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     primary: Color(0xFFEB0029),
//                                     minimumSize: Size(318, 43.38),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(16.0))),
//                                 child: const Text(
//                                   "Ürün Ekle",
//                                   style: TextStyle(fontSize: 13.33, fontFamily: 'Roboto'),
//                                 ),
//                                 onPressed: () {}),
//                           ),
//                         ]),
//                   ],
//                 );
//               } ,
//             ),
//           ),
//         ),
//       ),
//     );
//   }


//   Widget buildProductList(Product product) {
//     return Card(
//       child: Row(
//         children: [
//           SizedBox(
//             height: 100,
//             width: 100,
//             child: Material(
//               elevation: 3,
//               child: Container(
//                 child: Image.asset(product.imageUrl),
//               ),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(top: 5.0, left: 40.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(product.productName,
//                     style: const TextStyle(
//                         color: Color(0xFF654B2A),
//                         fontSize: 16.67,
//                         fontFamily: 'Roboto')),
//                 const SizedBox(
//                   height: 22,
//                 ),
//                 Text(
//                   product.productPrice,
//                   style: const TextStyle(
//                       color: Color(0xFF654B2A),
//                       fontSize: 16.67,
//                       fontFamily: 'Roboto'),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  

// }
