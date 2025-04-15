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

  List<Map<String, String>> _countrycode = [
    {"country": "United Arab Emirates", "country_code": "+971"},
    {"country": "Afghanistan", "country_code": "+93"},
    {"country": "Albania", "country_code": "+355"},
    {"country": "Armenia", "country_code": "+374"},
    {"country": "Angola", "country_code": "+244"},
    {"country": "Argentina", "country_code": "+54"},
    {"country": "Austria", "country_code": "+43"},
    {"country": "Australia", "country_code": "+61"},
    {"country": "Azerbaijan", "country_code": "+994"},
    {"country": "Bangladesh", "country_code": "+880"},
    {"country": "Belgium", "country_code": "+32"},
    {"country": "Burkina Faso", "country_code": "+226"},
    {"country": "Bulgaria", "country_code": "+359"},
    {"country": "Bahrain", "country_code": "+973"},
    {"country": "Burundi", "country_code": "+257"},
    {"country": "Benin", "country_code": "+229"},
    {"country": "Brunei Darussalam", "country_code": "+673"},
    {"country": "Bolivia", "country_code": "+591"},
    {"country": "Brazil", "country_code": "+55"},
    {"country": "Botswana", "country_code": "+267"},
    {"country": "Belarus", "country_code": "+375"},
    {"country": "Canada", "country_code": "+1"},
    {"country": "Congo", "country_code": "+242"},
    {"country": "Switzerland", "country_code": "+41"},
    {"country": "Ivory Coast", "country_code": "+225"},
    {"country": "Chile", "country_code": "+56"},
    {"country": "Cameroon", "country_code": "+237"},
    {"country": "China", "country_code": "+86"},
    {"country": "Colombia", "country_code": "+57"},
    {"country": "Costa Rica", "country_code": "+506"},
    {"country": "Czech Republic", "country_code": "+420"},
    {"country": "Germany", "country_code": "+49"},
    {"country": "Denmark", "country_code": "+45"},
    {"country": "Dominican Republic", "country_code": "+1"},
    {"country": "Algeria", "country_code": "+213"},
    {"country": "Ecuador", "country_code": "+593"},
    {"country": "Estonia", "country_code": "+372"},
    {"country": "Egypt", "country_code": "+20"},
    {"country": "Eritrea", "country_code": "+291"},
    {"country": "Spain", "country_code": "+34"},
    {"country": "Ethiopia", "country_code": "+251"},
    {"country": "Finland", "country_code": "+358"},
    {"country": "France", "country_code": "+33"},
    {"country": "Gabon", "country_code": "+241"},
    {"country": "United Kingdom", "country_code": "+44"},
    {"country": "Georgia", "country_code": "+995"},
    {"country": "French Guiana", "country_code": "+594"},
    {"country": "Ghana", "country_code": "+233"},
    {"country": "Gambia", "country_code": "+220"},
    {"country": "Greece", "country_code": "+30"},
    {"country": "Guatemala", "country_code": "+502"},
    {"country": "Guinea-Bissau", "country_code": "+245"},
    {"country": "Hong Kong", "country_code": "+852"},
    {"country": "Honduras", "country_code": "+504"},
    {"country": "Croatia", "country_code": "+385"},
    {"country": "Haiti", "country_code": "+509"},
    {"country": "Hungary", "country_code": "+36"},
    {"country": "Indonesia", "country_code": "+62"},
    {"country": "Ireland", "country_code": "+353"},
    {"country": "Israel", "country_code": "+972"},
    {"country": "India", "country_code": "+91"},
    {"country": "Iraq", "country_code": "+964"},
    {"country": "Italy", "country_code": "+39"},
    {"country": "Jamaica", "country_code": "+1"},
    {"country": "Jordan", "country_code": "+962"},
    {"country": "Japan", "country_code": "+81"},
    {"country": "Kenya", "country_code": "+254"},
    {"country": "Cambodia", "country_code": "+855"},
    {"country": "South Korea", "country_code": "+82"},
    {"country": "Kuwait", "country_code": "+965"},
    {"country": "Laos", "country_code": "+856"},
    {"country": "Lebanon", "country_code": "+961"},
    {"country": "Sri Lanka", "country_code": "+94"},
    {"country": "Liberia", "country_code": "+231"},
    {"country": "Lesotho", "country_code": "+266"},
    {"country": "Lithuania", "country_code": "+370"},
    {"country": "Luxembourg", "country_code": "+352"},
    {"country": "Latvia", "country_code": "+371"},
    {"country": "Libya", "country_code": "+218"},
    {"country": "Morocco", "country_code": "+212"},
    {"country": "Monaco", "country_code": "+377"},
    {"country": "Moldova", "country_code": "+373"},
    {"country": "Madagascar", "country_code": "+261"},
    {"country": "Macedonia", "country_code": "+389"},
    {"country": "Mali", "country_code": "+223"},
    {"country": "Myanmar", "country_code": "+95"},
    {"country": "Mongolia", "country_code": "+976"},
    {"country": "Mauritania", "country_code": "+222"},
    {"country": "The Republic of Malta", "country_code": "+356"},
    {"country": "Malawi", "country_code": "+265"},
    {"country": "Mexico", "country_code": "+52"},
    {"country": "Malaysia", "country_code": "+60"},
    {"country": "Mozambique", "country_code": "+258"},
    {"country": "Namibia", "country_code": "+264"},
    {"country": "Niger", "country_code": "+227"},
    {"country": "Nigeria", "country_code": "+234"},
    {"country": "Nicaragua", "country_code": "+505"},
    {"country": "Netherlands", "country_code": "+31"},
    {"country": "Norway", "country_code": "+47"},
    {"country": "Nepal", "country_code": "+977"},
    {"country": "New Zealand", "country_code": "+64"},
    {"country": "Oman", "country_code": "+968"},
    {"country": "Panama", "country_code": "+507"},
    {"country": "Peru", "country_code": "+51"},
    {"country": "Papua New Guinea", "country_code": "+675"},
    {"country": "Philippines", "country_code": "+63"},
    {"country": "Pakistan", "country_code": "+92"},
    {"country": "Poland", "country_code": "+48"},
    {"country": "Puerto Rico", "country_code": "+1"},
    {"country": "Portugal", "country_code": "+351"},
    {"country": "Paraguay", "country_code": "+595"},
    {"country": "Qatar", "country_code": "+974"},
    {"country": "Romania", "country_code": "+40"},
    {"country": "Serbia", "country_code": "+381"},
    {"country": "Russia", "country_code": "+7"},
    {"country": "Rwanda", "country_code": "+250"},
    {"country": "Saudi Arabia", "country_code": "+966"},
    {"country": "Sudan", "country_code": "+249"},
    {"country": "Sweden", "country_code": "+46"},
    {"country": "Singapore", "country_code": "+65"},
    {"country": "Slovenia", "country_code": "+386"},
    {"country": "Slovakia", "country_code": "+421"},
    {"country": "Sierra Leone", "country_code": "+232"},
    {"country": "Senegal", "country_code": "+221"},
    {"country": "Somalia", "country_code": "+252"},
    {"country": "South Sudan", "country_code": "+211"},
    {"country": "El Salvador", "country_code": "+503"},
    {"country": "Eswatini", "country_code": "+268"},
    {"country": "Chad", "country_code": "+235"},
    {"country": "Togo", "country_code": "+228"},
    {"country": "Thailand", "country_code": "+66"},
    {"country": "Tajikistan", "country_code": "+992"},
    {"country": "Turkmenistan", "country_code": "+993"},
    {"country": "Tunisia", "country_code": "+216"},
    {"country": "Taiwan", "country_code": "+886"},
    {"country": "Tanzania", "country_code": "+255"},
    {"country": "Ukraine", "country_code": "+380"},
    {"country": "Uganda", "country_code": "+256"},
    {"country": "United States", "country_code": "+1"},
    {"country": "Uruguay", "country_code": "+598"},
    {"country": "Uzbekistan", "country_code": "+998"},
    {"country": "Venezuela", "country_code": "+58"},
    {"country": "Vietnam", "country_code": "+84"},
    {"country": "Yemen", "country_code": "+967"},
    {"country": "South Africa", "country_code": "+27"},
    {"country": "Zambia", "country_code": "+26"}
  ];
  Map<String, String> countryCodeMap = {};
  Map<String, String> code = {};
  bool isEdit = false;
  String? selectedCountry;

// ---country code -----
  void fillCountryCodeMap() {
    for (var item in _countrycode) {
      final country = item['country']!;
      final countryCode = item['country_code']!;

      countryCodeMap[countryCode] = "$country ($countryCode)";

      code[countryCode] = countryCode;
    }

    if (!isEdit && countryCodeMap.isNotEmpty) {
      selectedCountry = countryCodeMap.keys.first;
    }

    print("Dropdown  => $countryCodeMap");
    print("Dial Code Map=> $code");
  }

  @override
  void initState() {
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    super.initState();
    final model = widget.model;
    if (model != null) {
      isEdit = true;
    }
    fillCountryCodeMap();
    selectedCountry = countryCodeMap.keys.first;
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Country Code'),
                              const SizedBox(height: 5),
                              // AppUtils.getDropdown(
                              //   '',
                              //   // initialValue: widget.model?.whatsapp_number,
                              //   onSaved: (wpnumber) {
                              //     _whatsapnumber = wpnumber;
                              //   },
                              //   validator: (value) {
                              //     if (value == null || value.isEmpty) {
                              //       return 'Please enter phone number';
                              //     } else if (value.length != 12) {
                              //       return 'Phone number must be 10 digits';
                              //     } else if (!RegExp(r'^[0-9]+$')
                              //         .hasMatch(value)) {
                              //       return 'Phone number must contain only digits';
                              //     }
                              //     return null;
                              //   },
                              //   data: _countrycode,
                              // ),
                              DropdownButtonFormField<String>(
                                isDense: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                value: selectedCountry,
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCountry = newValue!;
                                  });
                                },
                                items: countryCodeMap.entries
                                    .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),
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
                                  _whatsapnumber =
                                      '${code[selectedCountry]}${wpnumber}';
                                  print(
                                      "sdfdsfssdfjhsdkfjskdjfskdjsdk4${_whatsapnumber}");
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  } else if (value.length != 10) {
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Email Field
                    Column(
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
