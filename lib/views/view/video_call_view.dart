// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';

// class VideoCallView extends StatefulWidget {
//   const VideoCallView({ Key? key }) : super(key: key);

//   @override
//   _VideoCallViewState createState() => _VideoCallViewState();
// }

// class _VideoCallViewState extends State<VideoCallView> {

//   @override
//  Widget build(BuildContext context) {
//   return MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: const Text('Agora Video Call'),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: _remoteVideo(),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 100,
//               height: 150,
//               child: Center(
//                 child: _localUserJoined
//                     ? AgoraVideoView(
//                         controller: VideoViewController(
//                           rtcEngine: _engine,
//                           canvas: const VideoCanvas(uid: 0),
//                         ),
//                       )
//                     : const CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );

//   }
// <<<<<<< HEAD
// }
// =======
// }
