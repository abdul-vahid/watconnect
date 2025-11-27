// // ignore_for_file: prefer_const_constructors, avoid_print

// import 'package:flutter/material.dart';
// import 'package:whatsapp/views/view/show_pdf.dart';
// import 'package:whatsapp/views/view/show_video.dart';
// import 'package:whatsapp/views/view/view_fullscreen_img.dart';
// import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_attachment_widget.dart';

// Widget buildHeaderMedia(
//     String header, String headerBody, BuildContext context) {
//   switch (header) {
//     case "IMAGE":
//       return InkWell(
//         onTap: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => PreviewImage(
//                         imgUrl: headerBody,
//                       )));
//         },
//         child: Image.network(headerBody,
//             height: 120,
//             width: MediaQuery.of(context).size.width * 0.65,
//             fit: BoxFit.cover),
//       );
//     case "VIDEO":
//       return InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => ViewVideo(
//                           videoUrl: headerBody,
//                         )));
//           },
//           child: buildVideoPlaceholder(context));

//     case "DOCUMENT":
//       return InkWell(
//         onTap: () {
//           try {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => ViewPdf(
//                           pdfUrl: headerBody,
//                         )));
//           } catch (e) {
//             print("erorore opening file>>> $e");
//           }
//         },
//         child: Image.asset(
//           "assets/images/doc.png",
//           height: 120,
//           width: 120,
//         ),
//       );
//     default:
//       return SizedBox.shrink();
//   }
// }

// buildVideoPlaceholder(BuildContext context) {
// }
