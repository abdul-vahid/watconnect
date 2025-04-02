// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/lead_model.dart';
// import '../../utils/app_color.dart';
// import '../../utils/app_utils.dart';
// import '../../view_models/lead_list_vm.dart';
// import 'lead_add_update_view.dart';
// import 'lead_detail_view.dart';
// import 'dart:math';

// class WhatsappChatListView extends StatefulWidget {
//   const WhatsappChatListView({super.key});
//   @override
//   State<WhatsappChatListView> createState() => _WhatsappChatListViewState();
// }

// class _WhatsappChatListViewState extends State<WhatsappChatListView> {
//   String? selectedCity;
//   String? types;
//   TextEditingController textController = TextEditingController();
//   var baseViewModels;
//   List<LeadModel> leadModelList = [];
//   List<LeadModel> tempLeadModelList = [];
//   LeadListViewModel? leads;
//   bool isRefresh = false;
//   final List<String> _paymentterms = [
//     "Lead",
//     "User",
//     "Groups",
//     "Recently Message"
//   ];
//   final List<String> _city = [
//     "Ajmer",
//     "Alwar",
//     "Bikaner",
//     "Barmer",
//     "Bundi",
//     "Chittorgarh",
//     "Dholpur",
//     "Dungarpur",
//     "Hanumangarh",
//     "Jaipur",
//     "Jaisalmer",
//     "Jalor",
//     "Jhunjhunu",
//     "Jodhpur",
//     "Karauli",
//     "Kota",
//     "Nagaur",
//     "Pali",
//     "Pratapgarh",
//     "Rajsamand",
//     "Sawai Madhopur",
//     "Sikar",
//     "Sri Ganganagar",
//     "Tonk",
//     "Udaipur",
//     "Bhilwara",
//     "Sirohi",
//     "Jalore",
//     "Churu",
//     "Ratangarh",
//     "Rajasthan",
//   ];

//   // String? types;

//   @override
//   void initState() {
//     tempLeadModelList = leadModelList;
//     super.initState();
//     Provider.of<LeadListViewModel>(context, listen: false).fetch();
//   }

//   selectedAction(BuildContext context, int item, model) async {
//     if (item == 0) {
//     } else if (item == 1) {
//     } else if (item == 2) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => LeadAddView(
//                     model: model,
//                   )));
//     } else if (item == 3) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => LeadDetailView(
//                     model: model,
//                   )));
//     }
//   }

//   void _filterLeads(String searchLead) {
//     setState(() {
//       if (searchLead.isEmpty) {
//         print("working");
//         leadModelList = List.from(tempLeadModelList);
//         print("leadmodellist$leadModelList");
//       } else {
//         print("else Part Working...");
//         leadModelList = tempLeadModelList.where((leadModel) {
//           print("nested else Part Working...");

//           var leadstatus = leadModel.leadstatus ?? "";
//           return leadModel.firstname!
//                   .toLowerCase()
//                   .contains(searchLead.toLowerCase()) ||
//               leadModel.lastname!
//                   .toLowerCase()
//                   .contains(searchLead.toLowerCase()) ||
//               leadstatus.toLowerCase().contains(searchLead.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   void _showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       useSafeArea: true,
//       isScrollControlled: true,
//       enableDrag: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               height: 280,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Apply Filters',
//                       style: GoogleFonts.montserrat(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButton<String>(
//                       value: types,
//                       hint: const Text('Select Payment'),
//                       items: _paymentterms.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (selectedValue) {
//                         setState(() {
//                           types = selectedValue;
//                         });
//                       },
//                       isExpanded: true,
//                       icon: const Icon(Icons.arrow_drop_down,
//                           color: Colors.black),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButton<String>(
//                       value: selectedCity,
//                       hint: const Text('Select City'),
//                       items: _city.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (selectedCityValue) {
//                         setState(() {
//                           selectedCity = selectedCityValue;
//                         });
//                       },
//                       isExpanded: true,
//                       icon:
//                           const Icon(Icons.location_city, color: Colors.black),
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () {
//                         _applyFilters();
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 15, horizontal: 32),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: const Text(
//                         'Apply Filters',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _applyFilters() {
//     print("apply filter function..");

//     setState(() {
//       leadModelList = tempLeadModelList.where((leadModel) {
//         bool matchesPaymentTerms = true;
//         bool matchesCity = true;
//         if (types != null && types!.isNotEmpty) {
//           print("Selected payment terms: $types");
//           print("leadModel.paymentterms: ${leadModel.paymentterms}");
//           String paymentTerms = leadModel.paymentterms ?? "";
//           matchesPaymentTerms =
//               paymentTerms.trim().toLowerCase() == types!.trim().toLowerCase();
//           print("Matching payment terms: $matchesPaymentTerms");
//         }
//         if (selectedCity != null && selectedCity!.isNotEmpty) {
//           print("Selected city: $selectedCity");
//           print("leadModel.city city: ${leadModel.city}");
//           matchesCity = leadModel.city == selectedCity;
//           print("Matching city: $matchesCity");
//         }
//         return matchesPaymentTerms && matchesCity;
//       }).toList();

//       print("Filtered Leads: $leadModelList");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     baseViewModels = Provider.of<LeadListViewModel>(context);

//     if (baseViewModels != null) {
//       for (var viewModel in baseViewModels!.viewModels) {
//         if (viewModel.model is LeadModel) {
//           tempLeadModelList.add(viewModel.model);
//         } else {}
//       }
//     }
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back,
//               color: Color.fromARGB(255, 255, 255, 255)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Whatsapp',
//           style: GoogleFonts.montserrat(
//               color: const Color.fromARGB(255, 255, 255, 255)),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         automaticallyImplyLeading: true,
//         actions: const [],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50.0),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//             child: TextField(
//               controller: textController,
//               onChanged: _filterLeads,
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 hintStyle: TextStyle(
//                   color: AppColor.textoriconColor.withOpacity(0.6),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.all(10),
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 prefixIcon: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.filter_list,
//                       color: Color.fromARGB(255, 0, 0, 0),
//                       size: 20,
//                     ),
//                     onPressed: () {
//                       _showFilterBottomSheet(context);
//                     },
//                   ),
//                 ),
//                 prefixIconConstraints: const BoxConstraints(minWidth: 40),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//           onRefresh: _pullRefresh,
//           child: AppUtils.getAppBody(baseViewModels!, _pageBody)),
//       // bottomNavigationBar: AppUtils.buildAnimatedNotchBottomBar(
//       //   context,
//       // ),
//     );
//   }

//   Future<void> _pullRefresh() async {
//     leads?.viewModels.clear();

//     Provider.of<LeadListViewModel>(context, listen: false).fetch();

//     leads = Provider.of<LeadListViewModel>(context, listen: false);

//     isRefresh = true;
//     return Future<void>.delayed(const Duration(seconds: 2));
//   }

//   Widget _pageBody() {
//     return Column(
//       children: [
//         Expanded(
//             child: ListView(
//           children: getLeadWidgets(),
//         )),
//       ],
//     );
//   }

//   List<Widget> getLeadWidgets() {
//     List<Widget> widgets = [];

//     Set<String> uniqueIds = {};
//     for (var viewModel in leadModelList) {
//       LeadModel model = viewModel;

//       if (!uniqueIds.contains(model.id)) {
//         uniqueIds.add(model.id!);
//         widgets.add(leadRecordList(model));
//       }
//     }
//     return widgets;
//   }

//   Color getRandomColor() {
//     final random = Random();
//     return Color.fromARGB(random.nextInt(256), random.nextInt(256),
//         random.nextInt(256), random.nextInt(256));
//   }

//   Widget leadRecordList(LeadModel model) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border(
//           left: BorderSide(
//             // color: AppColor.navBarIconColor,
//             color: getRandomColor(),
//             width: 5,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 2,
//             spreadRadius: 2,
//             offset: const Offset(2, 4),
//           ),
//         ],
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 1, bottom: 1),
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => LeadDetailView(
//                           model: model,
//                         )));
//           },
//           child: ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 15),
//                     Container(
//                       width: 37,
//                       height: 37,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: getRandomColor(),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${model.firstname?[0]}',
//                           style: GoogleFonts.montserrat(
//                             fontSize: 16,
//                             color: const Color.fromARGB(255, 0, 0, 0),
//                             fontWeight: FontWeight.w400,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 12,
//                     ),
//                     Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text:
//                                 "${model.firstname ?? ""} ${model.lastname ?? ""}",
//                             style: GoogleFonts.montserrat(
//                                 fontSize: 15, fontWeight: FontWeight.bold),
//                           ),
//                           if (model.whatsapp_number != null)
//                             TextSpan(
//                               text: " (${model.whatsapp_number ?? ""})",
//                               style: GoogleFonts.montserrat(
//                                   fontSize: 10, fontWeight: FontWeight.normal),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
