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
  final List<String> _city = [
    "Ajmer",
    "Alwar",
    "Bikaner",
    "Barmer",
    "Bundi",
    "Chittorgarh",
    "Dholpur",
    "Dungarpur",
    "Hanumangarh",
    "Jaipur",
    "Jaisalmer",
    "Jalor",
    "Jhunjhunu",
    "Jodhpur",
    "Karauli"
        "Kota",
    "Nagaur",
    "Pali",
    "Pratapgarh",
    "Rajsamand",
    "Sawai Madhopur",
    "Sikar",
    "Sri Ganganagar",
    "Tonk",
    "Udaipur",
    "Bhilwara",
    "Sirohi",
    "Jalore",
    "Churu",
    "Ratangarh",
    "Rajasthan",
  ];
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
    for (var viewModel in userlistvm.viewModels) {
      UserDataModel productmodel = viewModel.model;
      _paymentterms.add(productmodel.userrole ?? "");
      if (selectedRole == null) {
        allUsers.add(productmodel);
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
          print(
              "Checking user: ${user.firstname}, Result: ${firstName.contains(selectedUser)}");
          return firstName.contains(selectedUser);
        }).toList();
      }
    }
    setState(() {});
    print("all users:: ${allUsers.length}");
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColor.navBarIconColor,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.add,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserAddView(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        title: const Text(
          'Users',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _filterLeads,
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: AppColor.textoriconColor.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.filter_list,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 20,
                            ),
                            onPressed: () {
                              _showFilterBottomSheet(context);
                            },
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ]),
          ),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: AppUtils.getAppBody(userlistvm!, _pageBody)),
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
          print(
              "Checking user: ${user.firstname}, Result: ${firstName.contains(searchLead)}");
          return firstName.contains(searchLead);
        }).toList();
      }

      print("Filtered User List: $userlistvm");
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
        return Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
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
                            borderRadius: BorderRadius.circular(08)),
                        height: 40,
                        width: 350,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: const Center(
                            child: Text(
                              'Apply Filters',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black,
                  //     width: 0.2,
                  //   ),
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButton<String>(
                        isDense: true,
                        hint: Text(
                          selectedRole ?? 'Select Role',
                          style: const TextStyle(color: Colors.black),
                        ),
                        items: uniqUserRoles.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (selectedValue) {
                          setState(() {
                            selectedRole = selectedValue;
                            print("selectedRole:: $selectedRole");
                          });
                        },
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        // underline: SizedBox(),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        allUsers.clear();
                        for (var viewModel in userlistvm.viewModels) {
                          UserDataModel productmodel = viewModel.model;
                          if (selectedRole == null) {
                            allUsers.add(productmodel);
                          } else {
                            if (productmodel.userrole?.toLowerCase() ==
                                selectedRole?.toLowerCase()) {
                              allUsers.add(productmodel);
                              setState(() {});
                            }
                          }
                        }
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cardsColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        Expanded(
          child: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 0.1, horizontal: 7),
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
                                        model: allUsers[index],
                                      )));
                        },
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${allUsers[index].firstname} ${allUsers[index].lastname}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                allUsers[index].userrole ?? "",
                                style:
                                    const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          //     child: ListView(
          //   children: getLeadWidgets(),
          // )
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
