// // ignore_for_file: deprecated_member_use

// import 'dart:io';


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';


// class DashBoard extends StatefulWidget {
//   const DashBoard({super.key});

//   @override
//   State<DashBoard> createState() => _DashBoardState();
// }

// class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const ScheduleListingScreen(),
//     // const AllResultScreen(),
//     ProfileScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//     // final isDark = Theme.of(context).brightness == Brightness.dark;

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: SafeArea(
//         bottom: true,
//         top: false,
//         child: Scaffold(
//           backgroundColor: Theme.of(context).colorScheme.background,
//           body: _screens[_selectedIndex],
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerFloat,
//           floatingActionButton: _selectedIndex == 0
//               ? ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                   onPressed: () {
//                     _makingPhoneCall();
//                   },
//                   icon: Icon(Icons.call,
//                       color: Theme.of(context).colorScheme.onPrimary),
//                   label: Text(
//                     "${localizations?.helpNo}. 8070277777",
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.onPrimary,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 )
//               : const SizedBox.shrink(),
//           bottomNavigationBar: BottomNavigationBar(
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             currentIndex: _selectedIndex,
//             onTap: (index) {
//               setState(() => _selectedIndex = index);
//             },
//             selectedItemColor: Theme.of(context).colorScheme.primary,
//             unselectedItemColor:
//                 Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//             selectedLabelStyle: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.normal,
//             ),
//             type: BottomNavigationBarType.fixed,
//             items: [
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.home), label: "${localizations?.home}"),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.assignment),
//                   label: "${localizations?.examShedule}"),
//               // BottomNavigationBarItem(
//               //     icon: Icon(
//               //       FontAwesomeIcons.medal,
//               //     ),
//               //     label: "${localizations?.resultOverview}"),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.person), label: "${localizations?.profile}"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _makingPhoneCall() async {
//     var url = Uri.parse("tel: 8070277777");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   Future<bool> _onWillPop() async {
//     // final isDark = Theme.of(context).brightness == Brightness.dark;

//     return (await showCupertinoDialog(
//           context: context,
//           builder: (BuildContext context) => CupertinoAlertDialog(
//             title: Text(
//               'Are you sure?',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//             content: Text(
//               'Do you want to exit the app?',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text(
//                   'No',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => exit(0),
//                 child: Text(
//                   'Yes',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }
// }