// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:whatsapp/utils/app_color.dart';
// import 'package:whatsapp/utils/function_lib.dart';
// import '../../view_models/campaign_count_vm.dart';
// import '../../view_models/templete_list_vm.dart';
// import '../../view_models/whatsapp_setting_vm.dart'
//     show WhatsappSettingViewModel;

// class Whtsapphone extends StatefulWidget {
//   const Whtsapphone({super.key});

//   @override
//   State<Whtsapphone> createState() => _WhtsapphoneState();
// }

// class _WhtsapphoneState extends State<Whtsapphone> {
//   WhatsappSettingViewModel? whatsAppSettingVM;
//   String? selectedWhatsAppNumber;
//   Map<String, String> itemsMap = {};

//   @override
//   void initState() {
//     super.initState();
//     fetch();
//     getPhoneNumber();
//   }

//   Future<void> getPhoneNumber() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');
//     setState(() {
//       selectedWhatsAppNumber = phoneNumber;
//     });
//     debug('Retrieved phone number: $phoneNumber');
//   }

//   void fetch() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? savedPhoneNumber = prefs.getString('phoneNumber');

//     await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();

//     if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
//         .viewModels
//         .isNotEmpty) {
//       String firstPhone =
//           Provider.of<WhatsappSettingViewModel>(context, listen: false)
//               .viewModels[0]
//               .model
//               .record[0]
//               .phone;

//       if (savedPhoneNumber == null || savedPhoneNumber.isEmpty) {
//         savedPhoneNumber = firstPhone;
//         await prefs.setString('phoneNumber', savedPhoneNumber);
//       }
//     }

//     setState(() {
//       selectedWhatsAppNumber = savedPhoneNumber;
//     });

//     debug('Selected WhatsApp Number: $selectedWhatsAppNumber');
//   }

//   void _updateItemsMap() {
//     itemsMap.clear();
//     for (var viewModel in whatsAppSettingVM!.viewModels) {
//       var nmodel = viewModel.model;
//       for (var record in nmodel?.record ?? []) {
//         itemsMap[record.phone] = "${record.name} ${record.phone}";
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);
//     _updateItemsMap();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             "Phone Selection",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             if (selectedWhatsAppNumber != null) const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: itemsMap.length,
//                 itemBuilder: (context, index) {
//                   String key = itemsMap.keys.elementAt(index);
//                   String value = itemsMap[key]!;
//                   bool isSelected = selectedWhatsAppNumber == key;

//                   return GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         selectedWhatsAppNumber = key;
//                       });

//                       Provider.of<CampaignCountViewModel>(context,
//                               listen: false)
//                           .fetchCampaignCount(number: selectedWhatsAppNumber);

//                       Provider.of<TempleteListViewModel>(context, listen: false)
//                           .templeteCountfetch(number: selectedWhatsAppNumber);

//                       final prefs = await SharedPreferences.getInstance();
//                       await prefs.setString(
//                           'phoneNumber', selectedWhatsAppNumber ?? "");

//                       debug(
//                           'selectedWhatsAppNumber == $selectedWhatsAppNumber');

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                               "Selected WhatsApp number: $selectedWhatsAppNumber"),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 8.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: isSelected ? AppColor.cardsColor : Colors.white,
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           value,
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';

// // class BottomNavigationBarView extends StatefulWidget {
// //   @override
// //   _BottomNavigationBarViewState createState() =>
// //       _BottomNavigationBarViewState();
// // }

// // class _BottomNavigationBarViewState extends State<BottomNavigationBarView> {
// //   int _selectedIndex = 0;

// //   static const List<Widget> _widgetOptions = <Widget>[
// //     Text('Home Page', style: TextStyle(fontSize: 24)),
// //     Text('Search Page', style: TextStyle(fontSize: 24)),
// //     Text('Settings Page', style: TextStyle(fontSize: 24)),
// //   ];

// //   // Function to handle tab change
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Animated Bottom Navigation Bar"),
// //       ),
// //       body: AnimatedSwitcher(
// //         duration: Duration(milliseconds: 300),
// //         child: _widgetOptions[_selectedIndex],
// //       ),
// //       bottomNavigationBar: AnimatedContainer(
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeInOut,
// //         child: BottomNavigationBar(
// //           currentIndex: _selectedIndex,
// //           onTap: _onItemTapped,
// //           items: <BottomNavigationBarItem>[
// //             BottomNavigationBarItem(
// //               icon: AnimatedSwitcher(
// //                 duration: const Duration(milliseconds: 300),
// //                 child: Icon(
// //                   Icons.home,
// //                   key: ValueKey<int>(_selectedIndex),
// //                   size: _selectedIndex == 0 ? 35.0 : 25.0,
// //                 ),
// //               ),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: AnimatedSwitcher(
// //                 duration: const Duration(milliseconds: 300),
// //                 child: Icon(
// //                   Icons.search,
// //                   key: ValueKey<int>(_selectedIndex),
// //                   size: _selectedIndex == 1 ? 35.0 : 25.0,
// //                 ),
// //               ),
// //               label: 'Search',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: AnimatedSwitcher(
// //                 duration: Duration(milliseconds: 300),
// //                 child: Icon(
// //                   Icons.settings,
// //                   key: ValueKey<int>(_selectedIndex),
// //                   size: _selectedIndex == 2 ? 35.0 : 25.0,
// //                 ),
// //               ),
// //               label: 'Settings',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:whatsapp/utils/app_color.dart';
// import '../../models/whatsapp_setting_model/whatsapp_setting_model.dart';
// import '../../view_models/agent_list_vm.dart';
// import '../../view_models/auto_response_vm.dart';
// import '../../view_models/campaign_count_vm.dart';
// import '../../view_models/chart_list_vm.dart';
// import '../../view_models/lead_count_vm.dart';
// import '../../view_models/templete_list_vm.dart';
// import '../../view_models/whatsapp_setting_vm.dart'
//     show WhatsappSettingViewModel;

// class Whtsapphone extends StatefulWidget {
//   const Whtsapphone({super.key});

//   @override
//   State<Whtsapphone> createState() => _WhtsapphoneState();
// }

// class _WhtsapphoneState extends State<Whtsapphone> {
//   WhatsappSettingViewModel? whatsAppSettingVM;
//   String? selectedWhatsAppNumber;

//   @override
//   void initState() {
//     super.initState();
//     fetch();
//     getPhoneNumber();
//   }

//   void fetch() {
//     Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch().then(
//       (value) async {
//         if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
//             .viewModels
//             .isNotEmpty) {
//           String? phoneNO =
//               Provider.of<WhatsappSettingViewModel>(context, listen: false)
//                   .viewModels[0]
//                   .model
//                   .record[0]
//                   .phone;

//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('phoneNumber', phoneNO ?? "");

//           Provider.of<TempleteListViewModel>(context, listen: false)
//               .templeteCountfetch(number: phoneNO);

//           Provider.of<CampaignCountViewModel>(context, listen: false)
//               .fetchCampaignCount(number: phoneNO);
//         }

//         Provider.of<ChartListViewModel>(context, listen: false)
//             .fetchLeadsMonth();
//         Provider.of<LeadCountViewModel>(context, listen: false).countNewLead();
//         Provider.of<AgentListViewModel>(context, listen: false)
//             .fetchCountAgent();
//         Provider.of<AutoResponseViewModel>(context, listen: false)
//             .autoResponseFetch();
//       },
//     );
//   }

//   Future<String?> getPhoneNumber() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('user_phone');
//     print('Retrieved phone number: $phoneNumber');
//     return phoneNumber;
//   }

//   @override
//   Widget build(BuildContext context) {
//     whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);
//     WhatsappSettingModel? nmodel;

//     Map<String, String> itemsMap = {};
//     for (var viewModel in whatsAppSettingVM!.viewModels) {
//       nmodel = viewModel.model;
//       selectedWhatsAppNumber = nmodel?.record?[0].phone;
//     }

//     for (var record in nmodel?.record ?? []) {
//       itemsMap[record.phone] = "${record.name} ${record.phone}";
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             "Phone Selection",
//             style: TextStyle(
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             // Display the selected phone number
//             if (selectedWhatsAppNumber != null)
//               // Text(
//               //   "Selected WhatsApp Number: $selectedWhatsAppNumber",
//               //   style: const TextStyle(
//               //     fontSize: 18,
//               //     fontWeight: FontWeight.bold,
//               //     color: Colors.green,
//               //   ),
//               // ),
//               const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: itemsMap.length,
//                 itemBuilder: (context, index) {
//                   String key = itemsMap.keys.elementAt(index);
//                   String value = itemsMap[key]!;

//                   bool isSelected = selectedWhatsAppNumber == key;

//                   return Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8.0),
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                       color: isSelected
//                           ? const Color.fromARGB(
//                               255, 0, 128, 0) // Green for selection
//                           : const Color.fromARGB(
//                               255, 255, 255, 255), // White for unselected
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         value,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black,
//                           fontWeight:
//                               isSelected ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                       onTap: () async {
//                         setState(() {
//                           selectedWhatsAppNumber = key;
//                         });

//                         // Perform actions based on the selected number
//                         Provider.of<CampaignCountViewModel>(context,
//                                 listen: false)
//                             .fetchCampaignCount(number: selectedWhatsAppNumber);

//                         Provider.of<TempleteListViewModel>(context,
//                                 listen: false)
//                             .templeteCountfetch(number: selectedWhatsAppNumber);

//                         final prefs = await SharedPreferences.getInstance();
//                         await prefs.setString(
//                           'phoneNumber',
//                           selectedWhatsAppNumber ?? "",
//                         );

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 "Selected WhatsApp number: $selectedWhatsAppNumber"),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import '../../view_models/campaign_count_vm.dart';
import '../../view_models/templete_list_vm.dart';
import '../../view_models/whatsapp_setting_vm.dart'
    show WhatsappSettingViewModel;

class Whtsapphone extends StatefulWidget {
  const Whtsapphone({super.key});

  @override
  State<Whtsapphone> createState() => _WhtsapphoneState();
}

class _WhtsapphoneState extends State<Whtsapphone> {
  WhatsappSettingViewModel? whatsAppSettingVM;
  String? selectedWhatsAppNumber;
  Map<String, String> itemsMap = {};

  @override
  void initState() {
    super.initState();
    fetch();
    getPhoneNumber();
  }

  Future<void> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    setState(() {
      selectedWhatsAppNumber = phoneNumber;
    });
    debug('Retrieved phone number: $phoneNumber');
  }

  void fetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber = prefs.getString('phoneNumber');

    await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();

    if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
        .viewModels
        .isNotEmpty) {
      String firstPhone =
          Provider.of<WhatsappSettingViewModel>(context, listen: false)
              .viewModels[0]
              .model
              .record[0]
              .phone;

      if (savedPhoneNumber == null || savedPhoneNumber.isEmpty) {
        savedPhoneNumber = firstPhone;
        await prefs.setString('phoneNumber', savedPhoneNumber);
      }
    }

    setState(() {
      selectedWhatsAppNumber = savedPhoneNumber;
    });

    debug('Selected WhatsApp Number: $selectedWhatsAppNumber');
  }

  void _updateItemsMap() {
    itemsMap.clear();
    for (var viewModel in whatsAppSettingVM!.viewModels) {
      var nmodel = viewModel.model;
      for (var record in nmodel?.record ?? []) {
        itemsMap[record.phone] = "${record.name} ${record.phone}";
      }
    }
  }

  String removeNumbers(String input) {
    return input.replaceAll(RegExp(r'\d'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);
    _updateItemsMap();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Phone Selection",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (selectedWhatsAppNumber != null) const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: itemsMap.length,
                itemBuilder: (context, index) {
                  String key = itemsMap.keys.elementAt(index);
                  String value = itemsMap[key]!;

                  bool isSelected = selectedWhatsAppNumber == key;

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedWhatsAppNumber = key;
                        print("value::: ${value}");
                        String name = removeNumbers(value);

                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString("userName", name);
                        });
                      });

                      Provider.of<CampaignCountViewModel>(context,
                              listen: false)
                          .fetchCampaignCount(number: selectedWhatsAppNumber);

                      Provider.of<TempleteListViewModel>(context, listen: false)
                          .templeteCountfetch(number: selectedWhatsAppNumber);

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'phoneNumber', selectedWhatsAppNumber ?? "");

                      debug(
                          'selectedWhatsAppNumber == $selectedWhatsAppNumber');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Selected WhatsApp number: $selectedWhatsAppNumber"),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? AppColor.cardsColor : Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
