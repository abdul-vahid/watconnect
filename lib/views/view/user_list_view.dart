// ignore_for_file: avoid_print, deprecated_member_use, prefer_typing_uninitialized_variables

import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:whatsapp/views/view/user_detail_view.dart';
import '../../models/user_data_model/user_data_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/user_data_list_vm.dart';
import 'user_add_update_view.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});
  @override
  State<UserListView> createState() => _UserListView();
}

class _UserListView extends State<UserListView> {
  List<UserDataModel> usermodel = [];
  List allUsers = [];

  final List<String> _paymentterms = [];
  // final List<String> _city = [
  //   "Ajmer",
  //   "Alwar",
  //   "Bikaner",
  //   "Barmer",
  //   "Bundi",
  //   "Chittorgarh",
  //   "Dholpur",
  //   "Dungarpur",
  //   "Hanumangarh",
  //   "Jaipur",
  //   "Jaisalmer",
  //   "Jalor",
  //   "Jhunjhunu",
  //   "Jodhpur",
  //   "Karauli"
  //       "Kota",
  //   "Nagaur",
  //   "Pali",
  //   "Pratapgarh",
  //   "Rajsamand",
  //   "Sawai Madhopur",
  //   "Sikar",
  //   "Sri Ganganagar",
  //   "Tonk",
  //   "Udaipur",
  //   "Bhilwara",
  //   "Sirohi",
  //   "Jalore",
  //   "Churu",
  //   "Ratangarh",
  //   "Rajasthan",
  // ];
  TextEditingController textController = TextEditingController();
  var userlistvm;
  UserDataListViewModel? products;
  bool isRefresh = false;
  String? selectedRole;
  String selectedUser = "";
  @override
  void initState() {
    super.initState();
    selectedUser = "";
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    userlistvm = Provider.of<UserDataListViewModel>(context);
    allUsers.clear();
    print("selectedRole:::::::::::  $selectedRole");
    print(
        "selectedUser:::::::::    $selectedUser      ${userlistvm.viewModels}");
    for (var viewModel in userlistvm.viewModels) {
      UserDataModel productmodel = viewModel.model;
      print("productmodel:::::::::::   $productmodel");
      _paymentterms.add(productmodel.userrole ?? "");
      if (selectedRole == null) {
        allUsers.add(productmodel);
        print(
            "adding element in the list:::::::::::::::::::::::::::::::::::::");
      } else {
        if (productmodel.userrole?.toLowerCase() ==
            selectedRole?.toLowerCase()) {
          allUsers.add(productmodel);
        }
      }

      if (selectedUser.isNotEmpty) {
        List tempUsers = allUsers;
        allUsers = [];
        allUsers = tempUsers.where((user) {
          var firstName = user.firstname?.toLowerCase() ?? '';
          var lastName = user.lastname?.toLowerCase() ?? '';

          // print(
          //     "Checking user: ${user.firstname}, Result: ${firstName.contains(selectedUser)}");
          return firstName.contains(selectedUser) ||
              lastName.contains(selectedUser);
        }).toList();
      }
    }
    setState(() {});
    print("all users:: ${allUsers.length}");
    return FocusDetector(
      onFocusGained: () {
        Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
      },
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          actions: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: CircleAvatar(
            //     backgroundColor: AppColor.navBarIconColor,
            //     child: IconButton(
            //       icon: const Icon(
            //         FontAwesomeIcons.add,
            //         size: 25,
            //         color: Colors.white,
            //       ),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => UserAddView(),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
          title: const Text(
            'Users',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: AppUtils.getAppBody(userlistvm!, _pageBody)),
      ),
    );
  }

  dynamic _filterLeads(String searchLead) {
    setState(() {
      searchLead = searchLead.trim().toLowerCase();
      selectedUser = searchLead;
      print("Search Query: $searchLead");

      print("User Model: $usermodel");

      if (searchLead.isEmpty) {
        userlistvm = List.from(usermodel);
      } else {
        print("Filtering the list...");
        List tempUsers = allUsers;
        allUsers = [];
        allUsers = tempUsers.where((user) {
          var firstName = user.firstname?.toLowerCase() ?? '';
          var lastName = user.lastname?.toLowerCase() ?? '';

          print(
              "Checking user first name : ${user.firstname}, Result first name: ${firstName.contains(searchLead)}");

          print(
              "Checking user last name : ${user.lastname}, Result last name: ${lastName.contains(searchLead)}");
          return firstName.contains(searchLead) ||
              lastName.contains(searchLead);
        }).toList();
      }

      print("Filtered User List: $userlistvm     ${allUsers.length}");
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      builder: (BuildContext context) {
        List<String> uniqUserRoles = _paymentterms.toSet().toList();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.navBarIconColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 40,
                            child: const Center(
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              isDense: true,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              hint: const Text(
                                'Select Role',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              items: uniqUserRoles.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRole = newValue;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            allUsers.clear();
                            selectedRole = null;
                            for (var viewModel in userlistvm.viewModels) {
                              UserDataModel productmodel = viewModel.model;
                              allUsers.add(productmodel);
                            }
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            allUsers.clear();
                            for (var viewModel in userlistvm.viewModels) {
                              UserDataModel productmodel = viewModel.model;
                              if (selectedRole == null ||
                                  productmodel.userrole?.toLowerCase() ==
                                      selectedRole?.toLowerCase()) {
                                allUsers.add(productmodel);
                              }
                            }
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pullRefresh() async {
    products?.viewModels.clear();
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    products = Provider.of<UserDataListViewModel>(context, listen: false);
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  Widget _pageBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    _showFilterBottomSheet(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          spreadRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                      color: Colors.white,
                      border: Border.all(color: AppColor.backgroundGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.filter_list,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 9,
                child: TextField(
                  onChanged: _filterLeads,
                  cursorColor: AppColor.navBarIconColor,
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: AppColor.textoriconColor.withOpacity(0.6),
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColor.navBarIconColor,
                        width: 1.5,
                      ),
                    ),
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(10),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.backgroundGrey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.backgroundGrey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        allUsers.isEmpty
            ? const Center(
                child: Text(
                  "No Users Available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            : Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "${allUsers.length} Users",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 22.0, bottom: 5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 3,
                              offset: const Offset(2, 4),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: allUsers.length,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemBuilder: (context, index) {
                            final user = allUsers[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDetailView(model: user),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: const Border(
                                        left: BorderSide(
                                          color: AppColor.navBarIconColor,
                                          width: 5,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          spreadRadius: 2,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                AppColor.navBarIconColor,
                                            child: Text(
                                              user.firstname != null &&
                                                      user.firstname!.isNotEmpty
                                                  ? user.firstname![0]
                                                      .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${user.firstname ?? ''} ${user.lastname ?? ''}",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  user.userrole ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    height: 1.5,
                                                    color: Colors.black54,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                              Icons.arrow_circle_right_outlined)
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  List<Widget> getLeadWidgets() {
    List<Widget> widgets = [];

    for (var viewModel in userlistvm.viewModels) {
      UserDataModel productmodel = viewModel.model;

      widgets.add(leadRecordList(productmodel));
    }
    return widgets;
  }

  Widget leadRecordList(UserDataModel model) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.1, horizontal: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              color: AppColor.navBarIconColor,
              width: 5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserDetailView(
                            model: model,
                          )));
            },
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${model.firstname} ${model.lastname}",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    model.userrole ?? "",
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
