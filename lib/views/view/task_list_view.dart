// // ignore_for_file: non_constant_identifier_names, constant_identifier_names
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';

// //import 'package:indi_crm/view_models/lead_list_vm.dart';

// // import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_color.dart';
// import '../../utils/app_utils.dart';
// import '../../utils/function_lib.dart';

// import 'task_detail_view.dart';

// // ignore: must_be_immutable
// class TaskListView extends StatefulWidget {
//   // PaymentModel? model;
//   String? id;
//   // String? contactid;
//   TaskListView({super.key, this.id});

//   @override
//   State<TaskListView> createState() => _TaskListView();
// }

// class _TaskListView extends State<TaskListView> {
//   TextEditingController textController = TextEditingController();
//   // ignore: prefer_typing_uninitialized_variables
//   String? dateformat;
//   TaskListViewModel? taskVm;
//   bool isRefresh = false;
//   // ignore: prefer_typing_uninitialized_variables
//   var parsedDate;

//   @override
//   void initState() {
//     var id = widget.id;
//     Provider.of<TaskListViewModel>(context, listen: false).fetchTask(id);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     taskVm = Provider.of<TaskListViewModel>(context);
//     debug('taskParentid===${widget.id}');

//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: AppColor.textoriconColor),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text(
//             'Tasks',
//             style: GoogleFonts.montserrat(color: AppColor.textoriconColor),
//           ),
//           // This Code Use Of Search Bar Start Here
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: AppColor.navBarIconColor,

//           automaticallyImplyLeading: true,
//           //---------This Code Use of Title And Add Button Start Here---------------
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(70.0),
//             child: Container(
//               height: 70,
//               width: MediaQuery.of(context).size.width,
//               decoration: const BoxDecoration(
//                 color: AppColor.navBarIconColor,
//                 boxShadow: [],
//                 border: Border(
//                   bottom: BorderSide(
//                     width: 1.8,
//                     color: Colors.redAccent,
//                   ),
//                 ),
//               ),
//               padding: const EdgeInsets.only(
//                   top: 12, bottom: 12, left: 10, right: 10),
//               child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Add Tasks',
//                       style: GoogleFonts.montserrat(
//                           fontSize: 18, fontWeight: FontWeight.w600),
//                     ),
//                     SizedBox.fromSize(
//                       size: const Size(45, 50), // button width and height
//                       child: ClipOval(
//                         child: Material(
//                           color: AppColor.navBarIconColor,
//                           // button color
//                           child: InkWell(
//                             // splash color
//                             onTap: () {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => AddTaskView(
//                                         id: widget.id,
//                                       )));
//                             }, // button pressed
//                             child: const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: <Widget>[
//                                 Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                 ), // icon
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ]),
//             ),
//           ),

//           //------------End Code of Title And Add Button--------------------
//         ),
//         body: RefreshIndicator(
//             onRefresh: _pullRefresh,
//             child: AppUtils.getAppBody(taskVm!, _pageBody)));
//   }

//   Future<void> _pullRefresh() async {
//     taskVm?.viewModels.clear();

//     // AppUtils.onLoading(context, "Refreshing");
//     var id = widget.id;
//     Provider.of<TaskListViewModel>(context, listen: false).fetchTask(id);

//     taskVm = Provider.of<TaskListViewModel>(context, listen: false);

//     isRefresh = true;
//     return Future<void>.delayed(const Duration(seconds: 2));
//   }

//   Widget _pageBody() {
//     //debug("paymentVm!.viewModels.isNotEmpty ${paymentVm!.viewModels.length}");
//     // ignore: unnecessary_null_comparison
//     return Column(
//       children: [
//         //----------This Code Use of All Record List Showing Start Here--------------------
//         Expanded(
//             child: ListView(
//           children: getPaymentWidgets(),
//         )),
//         //----------End Code of All Record List Showing--------------------
//       ],
//     );
//   }

//   List<Widget> getPaymentWidgets() {
//     List<Widget> widgets = [];

//     // debug("paymentVm!.viewModels.length  ${fileVm!.viewModels.length}");
//     debug('task length ${taskVm!.viewModels.length}');
//     for (var viewModel in taskVm!.viewModels) {
//       TaskModel model = viewModel.model;
//       if (model.id != null) {
//         widgets.add(leadRecordList(model));
//       }
//     }

//     return widgets;
//   }

//   // -----------------This Code Use of Record List Method Start Here-------------------------

//   Card leadRecordList(TaskModel model) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8, bottom: 8),
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => TaskDetailView(
//                           model: model,
//                         )));
//           },
//           child: ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   model.title ?? "",
//                   style: GoogleFonts.montserrat(
//                       fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 // Text(
//                 //   model.documenttype ?? "",
//                 //   style: GoogleFonts.montserrat(
//                 //       fontSize: 15, fontWeight: FontWeight.bold),
//                 // ),
//                 Text(
//                   model.type ?? "",
//                   style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
//                 ),
//                 Text(
//                   model.priority ?? "",
//                   style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
//                 ),

//                 Text(
//                   model.status ?? "",
//                   // model.paymentdate.toString(),
//                   style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // -----------------End Code of Record List Method-------------------------
