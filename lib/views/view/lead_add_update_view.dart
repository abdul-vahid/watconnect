import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../models/lead_model.dart';
import '../../models/user_data_model/user_data_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';

import '../../view_models/lead_list_vm.dart';
import '../../view_models/user_data_list_vm.dart';
import 'lead_list_view.dart';

List userData = [];
Map userMap = {};

class LeadAddView extends StatefulWidget {
  LeadModel? model;
  LeadAddView({Key? key, this.model}) : super(key: key);

  @override
  State<LeadAddView> createState() => _Forms();
}

class _Forms extends State<LeadAddView> {
  var baseViewModels;
  final List<String> _salutations = [
    "Mr",
    "Mrs",
    "Ms",
    "Dr",
    "Prof",
  ];
  final List<String> _titles = [
    "CEO",
    "Director",
    "Manager",
    "Owner",
    "Partner",
    "Executive",
  ];

  final List<String> _leadsources = [
    "Phone",
    "Partner Referral",
    "BNI",
    "Purchase List",
    "Web",
    "Email",
    "WhatsApp",
    "Facebook",
    "Instagram",
    "Other"
  ];
  final List<String> _leadsstatus = [
    "Open - Not Contacted",
    "Working - Contacted",
    "Proposal Stage",
    "Closed - Converted",
    "Closed - Not Converted",
  ];

  final List<String> _industries = [
    "Agriculture",
    "Apparel",
    "Banking",
    "Bio Technology",
    "Chemical",
    "Communications",
    "Construction",
    "Consulting",
    "Education",
    "Electronics",
    "Energy",
    "Engineering",
    "EnterTainment",
    "Finance",
    "Food and Beverage",
    "Goverment",
    "Healthcare",
    "Hospitality",
    "Insurance",
    "Legal",
    "Machinary",
    "Manufacturing",
    "Media",
    "Non Profit(NGO)",
    "Recreation",
    "Retail",
    "Shipping",
    "Technology",
    "Telecommunications",
    "Transportaion",
    "Utilities",
    "Other",
  ];
  final List<String> _payments = [
    "Subscription",
    "One Time",
  ];
  final List<String> _paymentterms = [
    "12",
    "24 Month",
    "One Time",
    "One Time with Yearly Renewal"
  ];
  bool isEdit = false;
  @override
  void initState() {
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    super.initState();
    final model = widget.model;
    if (model != null) {
      isEdit = true;
    }
  }

  LeadListViewModel? _getleadData;
  String? _firstname;
  String? _lastname;
  String? _email;
  String? _phone;
  String? _company;
  // ignore: unused_field
  String? _asignStaff;
  String? _leadsource;
  String? _leadstatus;
  // String? _rating;
  String? _salutation;
  // String? _fax;
  // ignore: unused_field
  String? _payment;
  // ignore: unused_field
  String? _paymentterm;
  String? _industry;
  String? _title;
  String? _street;
  String? _city;
  // ignore: unused_field
  String? _amount;
  String? _zipcode;
  String? _description;
  String? _selectedState;
  String? _selectedCountry;
  String? _whatsapnumber;
  final GlobalKey<FormState> _addleadFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _getleadData = LeadListViewModel(context);
    baseViewModels = Provider.of<UserDataListViewModel>(context);
    userData.length = 0;

    for (var viewModel in baseViewModels.viewModels) {
      UserDataModel model1 = viewModel.model;
      userMap[model1.id] = model1.username;
      debug('user=====${model1.id}');
    }

    userData = userMap.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 2,
        title: Text(
          isEdit ? "Edit Lead" : "Add New Lead",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _pageBody(),
      bottomNavigationBar: Container(
        // decoration: InputDecoration(border: Border.all(12)),
        height: 49,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // First button (Submit/Update)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cardsColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: isEdit ? updateData : onButtonPressed,
                child: Text(
                  isEdit ? "Update" : "Submit",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10), // Space between buttons

            // Second button (Cancel)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(
                    width: 1.0,
                    color: Colors.black,
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageBody() {
    return SingleChildScrollView(
      child: Form(
        key: _addleadFormKey,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 23),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // First Name Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('First Name'),
                              const SizedBox(height: 5),
                              AppUtils.getTextFormField(
                                'Enter First Name',
                                initialValue: widget.model?.firstname,
                                onSaved: (fName) {
                                  _firstname = fName;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please provide first name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Last Name Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Name'),
                              const SizedBox(height: 5),
                              AppUtils.getTextFormField(
                                'Enter your Last Name',
                                initialValue: widget.model?.lastname,
                                onSaved: (lName) {
                                  _lastname = lName;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter last name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Phone Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Phone'),
                              const SizedBox(height: 5),
                              AppUtils.getTextFormField(
                                'Enter your phone number',
                                initialValue: widget.model?.whatsapp_number,
                                onSaved: (wpnumber) {
                                  _whatsapnumber = wpnumber;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  } else if (value.length != 12) {
                                    return 'Phone number must be 10 digits';
                                  } else if (!RegExp(r'^[0-9]+$')
                                      .hasMatch(value)) {
                                    return 'Phone number must contain only digits';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Email Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email'),
                              const SizedBox(height: 5),
                              AppUtils.getTextFormField(
                                'Enter your email',
                                initialValue: widget.model?.email,
                                onSaved: (email) {
                                  _email = email;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // const SizedBox(height: 10),
                    const Text('Lead Status'),
                    const SizedBox(height: 5),
                    AppUtils.getDropdown(
                      '--Select--',
                      onChanged: (value) {
                        setState(() {
                          _leadstatus = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please Provide Status' : null,
                      data: _leadsstatus,
                      value: widget.model?.leadstatus,
                    ),
                    const Text('Assigned User'),
                    const SizedBox(height: 5),
                    AppUtils.getDropdown(
                      '--Select--',
                      onChanged: (value) {
                        setState(() {
                          _asignStaff = value;
                        });
                      },

                      validator: (value) =>
                          value == null ? 'Please Provide User' : null,
                      data: userData,
                      value: userData.contains(widget.model?.ownername)
                          ? widget.model?.ownername
                          : null, // Fix here
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColor.navBarIconColor,
                          // color: AppColor.appBarColor,
                          borderRadius: BorderRadius.circular(08)),
                      height: 40,
                      width: 350,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Important Information',
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
              Row(
                children: [
                  // First column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Title'),
                        const SizedBox(height: 5),
                        AppUtils.getDropdown(
                          '--Select--',
                          onSaved: (newValue) {
                            _title = newValue;
                          },
                          onChanged: (value) {
                            setState(() {
                              _title = value;
                            });
                          },
                          data: _titles,
                          value: widget.model?.title,
                        ),
                        const SizedBox(height: 10),
                        const Text('Lead Source'),
                        const SizedBox(height: 5),
                        AppUtils.getDropdown(
                          '--Select--',
                          onChanged: (value) {
                            setState(() {
                              _leadsource = value;
                            });
                          },
                          data: _leadsources,
                          value: widget.model?.leadsource,
                        ),
                        const SizedBox(height: 10),
                        // const Text('Lead Status'),
                        // const SizedBox(height: 5),
                        // AppUtils.getDropdown(
                        //   '--Select--',
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _leadstatus = value;
                        //     });
                        //   },
                        //   validator: (value) =>
                        //       value == null ? 'Required' : null,
                        //   data: _leadsstatus,
                        //   value: widget.model?.leadstatus,
                        // ),
                        const SizedBox(height: 10),
                        const Text('Industry'),
                        const SizedBox(height: 5),
                        AppUtils.getDropdown(
                          '--Select--',
                          onChanged: (value) {
                            setState(() {
                              _industry = value;
                            });
                          },
                          data: _industries,
                          value: widget.model?.industry,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10), // Space between the columns

                  // Second column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Model'),
                        const SizedBox(height: 5),
                        AppUtils.getDropdown(
                          '--Select--',
                          onChanged: (value) {
                            setState(() {
                              _payment = value;
                            });
                          },
                          data: _payments,
                          value: widget.model?.paymentmodel,
                        ),
                        const SizedBox(height: 10),
                        const Text('Payment Terms'),
                        const SizedBox(height: 5),
                        AppUtils.getDropdown(
                          '--Select--',
                          onChanged: (value) {
                            setState(() {
                              _paymentterm = value;
                            });
                          },
                          data: _paymentterms,
                          value: widget.model?.paymentterms,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        const Text('Expected Amount (\u{20B9})'),
                        const SizedBox(height: 5),
                        AppUtils.getTextFormField(
                          'Enter Expected Amount',
                          initialValue: widget.model?.amount,
                          onSaved: (amount) {
                            _amount = amount;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColor.navBarIconColor,
                          // color: AppColor.appBarColor,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Street'),
                        const SizedBox(
                          height: 5,
                        ),
                        AppUtils.getTextFormField(
                          'Enter your street',
                          initialValue: widget.model?.street,
                          onSaved: (street) {
                            _street = street;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 05,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('City'),
                        const SizedBox(
                          height: 5,
                        ),
                        AppUtils.getTextFormField(
                          'Enter your City',
                          initialValue: widget.model?.city,
                          onSaved: (value) {
                            _city = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('State'),
                        const SizedBox(
                          height: 5,
                        ),
                        AppUtils.getTextFormField(
                          'Enter your State',
                          initialValue: widget.model?.state,
                          onSaved: (value) {
                            _selectedState = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 05,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Zip/Postal code'),
                        const SizedBox(
                          height: 5,
                        ),
                        AppUtils.getTextFormField(
                          'Enter your zip code',
                          initialValue: widget.model?.zipcode,
                          onSaved: (value) {
                            _zipcode = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              const Text('Country'),
              const SizedBox(
                height: 5,
              ),
              AppUtils.getTextFormField(
                'Enter Your Country',
                initialValue: "India",
                onSaved: (country) {
                  _selectedCountry = country;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Description'),
              const SizedBox(
                height: 5,
              ),
              AppUtils.getTextFormField(
                'Enter description',
                initialValue: widget.model?.description,
                onSaved: (description) {
                  _description = description;
                },
              ),
              const SizedBox(
                height: 15,
              ),

              //----------This Code Use of Cancel and Submit Button Showing Start Here---------------

              //----------End Code of Cancel and Submit Button Showing Start Here---------------
            ],
          ),
        ),
      ),
    );
  }

  void onButtonPressed() {
    // ignore: prefer_typing_uninitialized_variables
    var userId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      userId = userMap.keys
          .firstWhere((k) => userMap[k] == _asignStaff, orElse: () => null);
      LeadModel addleadModel = LeadModel(
        firstname: _firstname,
        lastname: _lastname,
        email: _email,
        whatsapp_number: _whatsapnumber,
        city: _city,
        company: _company,
        leadsource: _leadsource,
        leadstatus: _leadstatus,
        salutation: _salutation,
        ownerid: userId,
        industry: _industry,
        title: _title,
        street: _street,
        state: _selectedState,
        country: _selectedCountry,
        zipcode: _zipcode,
        description: _description,
        ownername: _asignStaff,
        // ownerid: "c3c74964-d091-4fa3-8d9e-fa041d9c0d40",
        paymentterms: _paymentterm,
        paymentmodel: _payment,
        amount: _amount,
      );
      AppUtils.onLoading(context, "Saving, please wait...");

      _getleadData?.addlead(addleadModel).then((value) {
        debug("value#### $value");
        Navigator.pop(context);
        Navigator.pop(context);
        if (value.isNotEmpty) {
          debug("value#### $value");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (_) => LeadListViewModel(context))
                      ],
                      child: const LeadListView(),
                    )),
          );
        } else {}
        // }).catchError((error, stackTrace) {
        //   Navigator.pop(context);
        //   List<String> errorMessages = AppUtils.getErrorMessages(error);
        //   AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }

  // Future<void> updateData() async {
  //   if (_addleadFormKey.currentState!.validate()) {
  //     _addleadFormKey.currentState!.save();

  //     var id = widget.model?.id;
  //     debug('idmodel====$id');
  //     LeadModel leadModel = LeadModel(
  //       id: id,
  //       firstname: _firstname,
  //       lastname: _lastname,
  //       email: _email,
  //       whatsapp_number: _whatsapnumber,
  //       city: _city,
  //       company: _company,
  //       leadsource: _leadsource,
  //       leadstatus: _leadstatus,
  //       salutation: _salutation,
  //       industry: _industry,
  //       title: _title,
  //       ownername: _asignStaff,
  //       // ownerid: "c3c74964-d091-4fa3-8d9e-fa041d9c0d40",
  //       paymentmodel: _payment,
  //       paymentterms: _paymentterm,
  //       street: _street,
  //       state: _selectedState,
  //       country: _selectedCountry,
  //       zipcode: _zipcode,
  //       description: _description,
  //       // amount: _amount,
  //     );
  //     print("lelelelelel;eelelle=>>>${leadModel.toMap()}");
  //     AppUtils.onLoading(context, "Updating, please wait...");
  //     Provider.of<LeadListViewModel>(context, listen: false)
  //         .update(id, leadModel);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => MultiProvider(
  //                 providers: [
  //                   ChangeNotifierProvider(
  //                       create: (_) => LeadListViewModel(context))
  //                 ],
  //                 child: const LeadListView(),
  //               )),
  //     );
  //   }
  // }

  Future<void> updateData() async {
    var userId;
    userId = userMap.keys
        .firstWhere((k) => userMap[k] == _asignStaff, orElse: () => null);
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();

      var id = widget.model?.id;
      debug('idmodel====$id');
      LeadModel leadModel = LeadModel(
        id: id,
        firstname: _firstname,
        lastname: _lastname,
        email: _email,
        whatsapp_number: _whatsapnumber,
        city: _city,
        company: _company,
        leadsource: _leadsource,
        leadstatus: _leadstatus,
        salutation: _salutation,
        industry: _industry,
        title: _title,
        ownername: _asignStaff,
        ownerid: userId,
        paymentmodel: _payment,
        paymentterms: _paymentterm,
        street: _street,
        state: _selectedState,
        country: _selectedCountry,
        zipcode: _zipcode,
        description: _description,
        // amount: _amount,
      );
      print("lelelelelel;eelelle=>>>${leadModel.toMap()}");
      AppUtils.onLoading(context, "Updating, please wait...");
      Provider.of<LeadListViewModel>(context, listen: false)
          .update(id, leadModel)
          .then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (_) => LeadListViewModel(context))
                    ],
                    child: const LeadListView(),
                  )),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Your record has been updated.'),
        //     duration: Duration(seconds: 3),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }).catchError((error, stackTrace) {
        List<String> errorMessages = AppUtils.getErrorMessages(error);
        Navigator.pop(context);

        AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }
}
