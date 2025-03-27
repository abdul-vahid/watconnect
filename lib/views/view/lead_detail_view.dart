import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/views/view/lead_add_update_view.dart';
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
      String? userId = widget.model?.id;

      if (userId != null) {
        // _deleteUser(userId, refreshToken);
      } else {
        print("User ID is missing.");
      }
    });

    var createdDate = widget.model?.createddate;

    var parsedDate = DateTime.parse(createdDate.toString());
    amount = widget.model?.amount ?? "";
    dateformat = DateFormat('dd-MM-yyyy').format(parsedDate);
    return Scaffold(
      backgroundColor: Colors.white,
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
    print("widget.model?.whatsapp_number${widget.model?.whatsapp_number}");
    // print("widget.model?.createdbyname${widget.model?.ownername}");

    print("model$model");
    return Container(
      color: Colors.white38,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                // width: 340,
                // height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
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
                                    child: Text(
                                      'Personal Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          recordRow("First Name", widget.model?.firstname),
                          const Divider(),
                          recordRow("Last Name", widget.model?.lastname),
                          const Divider(),
                          recordRow("Email", widget.model?.email),
                          const Divider(),
                          recordRow("Phone", widget.model?.whatsapp_number),
                          const Divider(),
                          recordRow("Expected Amount", widget.model?.amount),
                          const Divider(),
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
                                    child: Text(
                                      'Leads Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          recordRow(
                              "Payment Terms", widget.model?.paymentterms),
                          const Divider(),
                          recordRow("Assigned User", widget.model?.ownername),
                          const Divider(),
                          recordRow("Company", widget.model?.company),
                          const Divider(),
                          recordRow("Lead Source", widget.model?.leadsource),
                          const Divider(),
                          recordRow(
                              "Payment Model", widget.model?.paymentmodel),
                          const Divider(),
                          recordRow("Status", widget.model?.convertedcontactid),
                          const Divider(),
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
                                    child: Text(
                                      'Address Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          recordRow("Description", widget.model?.description),
                          const Divider(),
                          recordRow("city", widget.model?.city),
                          const Divider(),
                          recordRow("country", widget.model?.country),
                          const Divider(),
                          recordRow("zipcode", widget.model?.zipcode),
                          const Divider(),
                          recordRow("street", widget.model?.street),
                          const Divider(),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Optional Edit and Delete Options Menu
            ],
          ),
        ),
      ),
    );
  }

  Widget recordRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
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
            value ?? "",
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
                'Are you sure you want to delete this campaign?',
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
    String leadidd = model?.id;
    print("leadddid=>$leadidd");
    LeadListViewModel(context).deleteById(leadidd).then((value) {
      print("working enter");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting campaign.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _navigateToEdit() {
    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadAddView(model: widget.model),
            ))
        .then((value) =>
            Provider.of<LeadListViewModel>(context, listen: false).fetch());
  }
}
