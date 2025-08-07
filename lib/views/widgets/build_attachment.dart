//   import 'package:flutter/material.dart';

// Widget _buildAttachmentWidget(String url) {
//     String fileType = url.split('.').last.toLowerCase();
//     print("printing:: file type::: $fileType");
//     switch (fileType) {
//       case 'pdf':
//         return InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ViewPdf(
//                             pdfUrl: url,
//                           )));
//             },
//             child: Image.asset("assets/images/pdf.png",
//                 height: 120, width: MediaQuery.of(context).size.width * 0.65));

//       case 'docx':
//       case 'doc':
//         return InkWell(
//             onTap: () {
//               openDocument(context, url);
//               // Navigator.push(
//               //     context,
//               //     MaterialPageRoute(
//               //         builder: (context) => OpenAllDocs(
//               //               url: url,
//               //             )));
//             },
//             child: Image.asset("assets/images/doc.png",
//                 height: 120, width: MediaQuery.of(context).size.width * 0.65));

//       case 'pptx':
//       case 'ppt':
//         return InkWell(
//             onTap: () {
//               openDocument(context, url);
//               // Navigator.push(
//               //     context,
//               //     MaterialPageRoute(
//               //         builder: (context) => OpenAllDocs(
//               //               url: url,
//               //             )));
//             },
//             child: Image.asset("assets/images/powerpoint.png",
//                 height: 120, width: MediaQuery.of(context).size.width * 0.65));

//       case 'xlsx':
//       case 'xls':
//         return InkWell(
//             onTap: () {
//               openDocument(context, url);
//             },
//             child: Image.asset("assets/images/excel.png",
//                 height: 120, width: MediaQuery.of(context).size.width * 0.65));

//       case 'mp4':
//         return InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ViewVideo(
//                             videoUrl: url,
//                           )));
//             },
//             child: _buildVideoPlaceholder());

//       case 'aac':
//         return InkWell(
//           onTap: () async {
//             showDialog(
//               context: context,
//               builder: (context) => AudioDialog(audioUrl: url),
//             );
//           },
//           child: Container(
//             height: 60,
//             width: MediaQuery.of(context).size.width * 0.5,
//             decoration: BoxDecoration(
//               color: Colors.deepOrangeAccent,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 12.0),
//                   child: Container(
//                     height: 30,
//                     width: 30,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                     ),
//                     child: Icon(
//                       _isPlaying
//                           ? Icons.spatial_audio_off_rounded
//                           : Icons.headphones,
//                       size: 20,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );

//       case 'png':
//       case 'jpg':
//       case 'jpeg':
//         return InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => PreviewImage(
//                             imgUrl: url,
//                           )));
//             },
//             child: CachedNetworkImage(
//               imageUrl: url,
//               height: 120,
//               width: MediaQuery.of(context).size.width * 0.65,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => const Center(
//                 child: CircularProgressIndicator(),
//               ),
//               errorWidget: (context, url, error) =>
//                   const Icon(Icons.broken_image),
//             )

//             //  Image.network(url,
//             //     height: 120,
//             //     width: MediaQuery.of(context).size.width * 0.65,
//             //     fit: BoxFit.cover)

//             );
//       default:
//         return InkWell(
//             onTap: () {
//               openDocument(context, url);
//             },
//             child: Image.asset("assets/images/file.png",
//                 height: 120, width: MediaQuery.of(context).size.width * 0.65));
//     }
//   }
