import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:whatsapp/view_models/lead_count_vm.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/views/view/lead_add_update_view.dart';
import 'package:whatsapp/views/view/lead_list_view.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_constants.dart';

// ignore: must_be_immutable
class LeadDetailView extends StatefulWidget {
  LeadModel? model;

  LeadDetailView({super.key, this.model});

  @override
  State<LeadDetailView> createState() => _LeadDetailViewState();
}

class _LeadDetailViewState extends State<LeadDetailView> {
  final bool _isLoading = true; // Track loading state

  String? dateformat;
  get model => widget.model;
  String? amount;

  @override
  void initState() {
    print("tag list::: ${widget.model?.tagNames ?? []}");
    // bottomnavigationbar animated
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? refreshToken =
          prefs.getString(SharedPrefsConstants.refreshTokenKey);

      if (refreshToken == null) {
        // Handle the missing refresh token case (e.g., prompt the user to login again)
        print("Refresh token is missing.");
        return;
      }

      // Proceed to make API call for user deletion
      // String? userId = widget.model?.id;

      // _deleteUser(userId, refreshToken);
    });

    var createdDate = widget.model?.createddate;

    var parsedDate = DateTime.parse(createdDate.toString());
    // amount = widget.model?. ?? "";
    dateformat = DateFormat('dd-MM-yyyy').format(parsedDate);
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEdit();
              } else if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('delete'),
                ),
              ];
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,

        title: const Text(
          'Lead Details',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
        //-----------This Code Use of Icon Bar Showing Start Here------------

        //-----------End Code of Icon Bar Showing-------------
      ),
      body: _pageBody(model),
    );
  }

  Widget _pageBody(model) {
    print("widget.model?.whatsapp_number${widget.model?.whatsappNumber}");
    // print("widget.model?.createdbyname${widget.model?.ownername}");

    print("model$model");
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      detailsHeading(
                        title: "Personal Information",
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          recordRow("First Name", widget.model?.firstname),
                          const Divider(),
                          recordRow("Last Name", widget.model?.lastname),
                          const Divider(),
                          recordRow("Date of Birth", widget.model?.dob),
                          const Divider(),
                          recordRow("Email", widget.model?.email),
                          const Divider(),
                          recordRow("Phone",
                              "${widget.model?.countryCode} ${widget.model?.whatsappNumber}"),
                          const Divider(),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // recordRow("Expected Amount", widget.model?.amount),
                // const Divider(),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      detailsHeading(
                        title: "Lead Information",
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          // const Divider(),
                          recordRow("Assigned User", widget.model?.ownername),
                          const Divider(),
                          recordRow("Lead Source", widget.model?.leadsource),

                          const Divider(),
                          recordRow(
                              "Lead Description", widget.model?.description),
                          const Divider(),
                          recordRow("Status", widget.model?.leadstatus),
                          const Divider(),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      detailsHeading(
                        title: "Address Information",
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          recordRow("Address", widget.model?.address),
                          // const Divider(),
                          // recordRow("city", widget.model?.city),
                          // const Divider(),
                          // recordRow("country", widget.model?.country),
                          // const Divider(),
                          // recordRow("zipcode", widget.model?.zipcode),
                          // const Divider(),
                          // recordRow("street", widget.model?.street),
                          const Divider(),
                          const SizedBox(height: 15),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailsHeading(
                        title: "Tags Information",
                      ),
                      widget.model!.tagNames!.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18.0),
                              child: Center(
                                  child: Text(
                                "No Tags Available...",
                                style: TextStyle(color: Colors.black54),
                              )),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    (widget.model?.tagNames ?? []).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE6E6E6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(tag.name ?? ""),
                                  );
                                }).toList(),
                              ),
                            )
                    ],
                  ),
                )

                //  Wrap(
                //     spacing: 10,
                //   children: widget.model.tagNames.map(tag){
                //     return Container(
                //       child: Text(tag.name),
                //     );
                //   },
                //  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget recordRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value!.isEmpty ? "-" : value ?? "-",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete this lead?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColor.navBarIconColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      _deleteUser();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteUser() {
    String? leadidd = model?.id;

    if (leadidd == null || leadidd.isEmpty) {
      print("Error: leadidd is null or empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Lead ID is invalid.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure it's a well-formed UTF-16 string
    try {
      leadidd = leadidd.trim(); // Remove extra spaces
      print("Lead ID: $leadidd");
    } catch (e) {
      print("Invalid UTF-16 string: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid lead ID format.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    LeadListViewModel(context).deleteById(leadidd).then((value) {
      print("working enter");

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Lead deleted successfully.'),
      //     backgroundColor: Colors.green,
      //   ),
      // );

      EasyLoading.showToast("Deleted Succeffuly");

      Provider.of<LeadListViewModel>(context, listen: false).fetch();
      Provider.of<LeadCountViewModel>(context, listen: false).countNewLead();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => LeadListViewModel(context),
              ),
            ],
            child: const LeadListView(),
          ),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting campaign.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> _navigateToEdit() async {
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    final result = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeadAddView(model: widget.model),
        ));

    if (result == true) {
      print("result on detailesss:::: ");
      Navigator.pop(context, true);
    }
  }
}
