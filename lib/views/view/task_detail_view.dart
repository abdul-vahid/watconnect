// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// import '../../models/task_model.dart';
// import '../../utils/app_color.dart';

// // ignore: must_be_immutable
// class TaskDetailView extends StatefulWidget {
//   TaskModel? model;

//   TaskDetailView({super.key, this.model});

//   @override
//   State<TaskDetailView> createState() => _TaskDetailView();
// }

// class _TaskDetailView extends State<TaskDetailView> {
//   String? dateformat;
//   get model => widget.model;

//   @override
//   void initState() {
//     super.initState();
//     // final model = widget.model;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var createdDate = widget.model?.targetdate;

//     var parsedDate = DateTime.parse(createdDate.toString());
//     dateformat = DateFormat('dd-MM-yyyy ').format(parsedDate);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColor.textoriconColor),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: AppColor.navBarIconColor,
//         title: Text(
//           'Details',
//           style: GoogleFonts.montserrat(
//               fontSize: 20, color: AppColor.textoriconColor),
//         ),
//         //-----------This Code Use of Icon Bar Showing Start Here------------
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(70.0),
//           child: Container(
//             decoration: const BoxDecoration(
//               color: AppColor.navBarIconColor,
//               border: Border(
//                 bottom: BorderSide(
//                   width: 1.8,
//                   color: Colors.redAccent,
//                 ),
//               ),
//             ),
//             padding: const EdgeInsets.only(top: 12, bottom: 15),
//             child: const Row(children: [
//               // Icon First
//               // MaterialButton(
//               //   shape: const CircleBorder(),
//               //   color: AppColor.navBarIconColor,
//               //   padding: const EdgeInsets.all(15),
//               //   onPressed: () {
//               //     Navigator.push(
//               //         context,
//               //         MaterialPageRoute(
//               //             builder: (context) => PropertyAddView(
//               //                   model: model,
//               //                 )));
//               //   },
//               //   child: const Icon(
//               //     Icons.create_sharp,
//               //     size: 25,
//               //     color: Colors.white,
//               //   ),
//               // ),

//               // //Icon Second
//               // MaterialButton(
//               //   shape: const CircleBorder(),
//               //   color: AppColor.navBarIconColor,
//               //   padding: const EdgeInsets.all(15),
//               //   onPressed: () {},
//               //   child: const Icon(
//               //     Icons.delete_outline,
//               //     size: 25,
//               //     color: Colors.white,
//               //   ),
//               // ),

//               // Icon Third

//               // Icon Fourth
//             ]),
//           ),
//         ),
//         //-----------End Code of Icon Bar Showing-------------
//       ),
//       body: _pageBody(model),
//     );
//   }

//   Widget _pageBody(model) {
//     return Column(children: [
//       //-----------This Code Use of Record All Details Showing Start Here------------
//       Expanded(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                         flex: 7,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               recordDetails('Title', widget.model?.title),
//                             ],
//                           ),
//                         )),
//                     Expanded(
//                         flex: 5,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               recordDetails('Type', widget.model?.type),
//                             ],
//                           ),
//                         )),
//                   ],
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.only(top: 8, bottom: 8),
//                   child: Divider(
//                     color: Colors.black,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                         flex: 7,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               recordDetails('Priority', widget.model?.priority),
//                             ],
//                           ),
//                         )),
//                     Expanded(
//                         flex: 5,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               recordDetails(
//                                   'Created Date',
//                                   widget.model?.targetdate != null
//                                       ? dateformat ?? ""
//                                       : ""),
//                             ],
//                           ),
//                         )),
//                   ],
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.only(top: 8, bottom: 8),
//                   child: Divider(
//                     color: Colors.black,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                         flex: 7,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             recordDetails(
//                                 'Assigned To', widget.model?.ownername),
//                           ],
//                         )),
//                     Expanded(
//                         flex: 5,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               recordDetails(
//                                   'Description', widget.model?.description),
//                             ],
//                           ),
//                         )),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       //-----------End Code of Record All Details Showing------------------
//     ]);
//   }

// //-----------This Code Use of Record All Details Showing Method Start Here------------
//   Row recordDetails(String label, String? name) {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.montserrat(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 0, 0, 0),
//                 ),
//               ),
//               Text(
//                 name ?? '',
//                 style: GoogleFonts.montserrat(
//                   fontSize: 14,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
// //-----------End Code of Record All Details Showing Method-------------------
