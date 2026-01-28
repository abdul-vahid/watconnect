// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/get_user.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/get_user_vm.dart';
import 'package:whatsapp/views/view/user_add_update_view.dart';
import '../../models/lead_model.dart';
import '../../models/user_data_model/user_data_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';

import '../../view_models/lead_list_vm.dart';
import '../../view_models/user_data_list_vm.dart';
import 'lead/lead_list_view.dart';

List userData = [];
Map userMap = {};

// ignore: duplicate_ignore
// ignore: must_be_immutable
class LeadAddView extends StatefulWidget {
  LeadModel? model;
  LeadAddView({Key? key, this.model}) : super(key: key);

  @override
  State<LeadAddView> createState() => _Forms();
}

class _Forms extends State<LeadAddView> {
  var baseViewModels;

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

  final List<Map<String, String>> _countrycode = [
    {"country": "India", "country_code": "+91"},
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
  TextEditingController dobController = TextEditingController();
  TextEditingController wpNumCtrl = TextEditingController();
  String? selectedDate;
  bool hasTags = false;
  String? leadStatus;
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

    // print("Dropdown  => $countryCodeMap");
    // print("Dial Code Map=> $code");
  }

  List<TagRecord> tagsNameSet = [];

  List<Map<String, String>> selectedTagList = [];

  bool shouldHideLeadNumber = false;

  @override
  void initState() {
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    getTags();
    shouldHide();
    getWalletStatus();
    super.initState();
    final model = widget.model;
    if (model != null) {
      isEdit = true;
    }

    print("leadsource::::::::::::    $_leadsource");

    if (isEdit) {
      print(
          "widget.model?.countryCode:::: ${widget.model?.tagNames}  ${widget.model?.leadsource}");

      selectedCountry = widget.model?.countryCode;
      _whatsapnumber = widget.model?.whatsappNumber;
      dobController.text = widget.model?.dob ?? "";
      wpNumCtrl.text = formatPhoneNumber(widget.model?.whatsappNumber);
      print("wpNumCtrl::: :${wpNumCtrl.text}");
      selectedDate = widget.model?.dob ?? "";
      selectedTagList = (widget.model?.tagNames ?? [])
          .map((tag) => {
                'name': tag.name ?? '',
                'id': tag.id ?? '',
              })
          .toList();
      _leadstatus = widget.model?.leadstatus ?? "";
      _leadsource =
          widget.model!.leadsource!.isEmpty ? null : widget.model!.leadsource;
      print(
          "widget.model?.address ::::::::::: ${widget.model?.address}  $_leadsource");
      _selectedCountry = widget.model?.address ?? "";
      _asignStaff = widget.model?.ownername ?? "";
      // userId = widget.model?.ownername??"";
    } else {
      leadStatus = _leadsstatus[0];
      _leadstatus = _leadsstatus[0];
    }
    fillCountryCodeMap();
    selectedCountry = countryCodeMap.keys.first;
  }

  LeadListViewModel? _getleadData;
  String? _firstname;
  String? _lastname;
  String? description;
  String? _email;
  // String? _phone;
  // String? _company;
  // ignore: unused_field
  String? _asignStaff;
  String? _leadsource;
  String? _leadstatus;
  // String? _rating;
  // String? _salutation;
  // String? _fax;
  // ignore: unused_field
  String? _payment;
  // ignore: unused_field
  String? _paymentterm;
  // String? _industry;
  // String? _title;
  // String? _street;
  // String? _city;
  GetUserViewModel? userVm;
  String? name;
  // ignore: unused_field
  String? _amount;
  // String? _zipcode;
  String? _description;
  // String? _selectedState;
  String? _selectedCountry;
  String? _whatsapnumber;
  String? defaultSel;
  String? defaultUsrId;
  final GlobalKey<FormState> _addleadFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _getleadData = LeadListViewModel(context);
    baseViewModels = Provider.of<UserDataListViewModel>(context);
    userData.length = 0;

    for (var viewModel in baseViewModels.viewModels) {
      UserDataModel model1 = viewModel.model;
      userMap[model1.id] = model1.username;
      debug('user=====${model1.username}  ${model1.userrole}');
      if (model1.userrole == 'ADMIN') {
        defaultSel = model1.username;
        _asignStaff = defaultSel;
        defaultUsrId = model1?.id ?? "";
      }
    }

    userData = userMap.values.toList();

    userVm = Provider.of<GetUserViewModel>(context);
    for (var viewModel in userVm!.viewModels) {
      print("viewModel.model:::>>>>> ${viewModel.model}");
      GetUser model = viewModel.model;
      name = model.managername;
    }

    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
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
        margin: const EdgeInsets.all(10),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

            const SizedBox(width: 10),

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _addleadFormKey,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                        title: "Personal Information",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'First Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
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
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Last Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getTextFormField(
                              'Enter  Last Name',
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

                            const SizedBox(height: 10),

                            const Text('Date of Birth',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getTextFormField(
                              'Select Date of Birth',
                              controller: dobController,
                              onSaved: (dt) {
                                // selectedDate = dt;
                              },
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.year}";

                                  dobController.text = formattedDate;
                                  selectedDate =
                                      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";

                                  print(
                                      "selectedDate::::::::::: $selectedDate");
                                }
                              },
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const Text('Country Code',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),

                            DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: const InputDecoration(
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

                            const SizedBox(
                              height: 12,
                            ),

                            const Text('Phone',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),

                            AppUtils.getTextFormField(
                              'Enter phone number',
                              controller: wpNumCtrl,
                              obscureText:
                                  widget.model != null && shouldHideLeadNumber
                                      ? true
                                      : false,
                              readOnly:
                                  widget.model != null && shouldHideLeadNumber
                                      ? true
                                      : false,
                              onSaved: (wpnumber) {
                                // If it's masked, use the original number from the model
                                if (shouldHideLeadNumber && isEdit) {
                                  _whatsapnumber = widget.model?.whatsappNumber;
                                } else {
                                  _whatsapnumber = '$wpnumber';
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }

                                // Skip phone validation if it's masked (contains X's)
                                if (shouldHideLeadNumber &&
                                    value.contains('X')) {
                                  return null;
                                }

                                if (!isValidPhone(value.trim())) {
                                  return 'Please enter valid phone number';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),
                            // Email Field
                            const Text('Email',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getTextFormField(
                              'Enter email',
                              initialValue: widget.model?.email,
                              onSaved: (email) {
                                _email = email;
                              },
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter email';
                              //   }
                              //   return null;
                              // },
                            ),

                            const SizedBox(height: 10),
                            // Email Field
                            const Text('Lead Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getTextFormField(
                              maxLines: 2,
                              'Enter description',
                              initialValue: widget.model?.description,
                              onSaved: (desc) {
                                _description = desc;
                              },
                            ),

                            const SizedBox(height: 10),
                            const Text('Lead Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 10),
                            AppUtils.getDropdown(
                              '--Select--',
                              onChanged: (value) {
                                setState(() {
                                  _leadstatus = value;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Please Provide Status'
                                  : null,
                              data: _leadsstatus,
                              value: leadStatus ?? widget.model?.leadstatus,
                            ),
                            const SizedBox(height: 10),
                            const Text('Assigned User',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 10),
                            AppUtils.getDropdown(
                              '--Select--',
                              onChanged: (value) {
                                setState(() {
                                  print(
                                      'Dropdown selected value (name): $value');

                                  try {
                                    print("userData>>>>>>>  ${userData}");

                                    // Find the key (user ID) for the selected username
                                    final selectedUserId =
                                        userMap.keys.firstWhere(
                                      (key) => userMap[key] == value,
                                      orElse: () => '',
                                    );

                                    print('Matched user name: $value');
                                    print('Matched user id: $selectedUserId');

                                    setState(() {
                                      _asignStaff = value;
                                      defaultUsrId =
                                          selectedUserId; // Update the user ID too!
                                    });
                                    print(
                                        'Assigned staff: $_asignStaff, ID: $defaultUsrId');
                                  } catch (e) {
                                    print(
                                        'No matching user found for value: $value');
                                    print('Error: $e');
                                  }
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Please Provide User' : null,
                              data: userData,
                              value: userData.contains(widget.model?.ownername)
                                  ? widget.model?.ownername
                                  : defaultSel,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
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
                        title: "Important Information",
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            hasTags
                                ? const Text('Tags',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14))
                                : const SizedBox(),
                            hasTags
                                ? const SizedBox(height: 5)
                                : const SizedBox(),
                            hasTags
                                ? MultiSelectDialogField<TagRecord>(
                                    dialogWidth:
                                        MediaQuery.of(context).size.width * .45,
                                    dialogHeight:
                                        MediaQuery.of(context).size.height *
                                            .35,
                                    items: tagsNameSet.map((tag) {
                                      return MultiSelectItem<TagRecord>(
                                          tag, tag.name ?? "Unnamed");
                                    }).toList(),
                                    initialValue: selectedTagList.map((tagMap) {
                                      return tagsNameSet.firstWhere(
                                        (tag) => tag.id == tagMap['id'],
                                        orElse: () => TagRecord(
                                            id: tagMap['id'],
                                            name: tagMap['name']),
                                      );
                                    }).toList(),
                                    title: const Text("Select Tags"),
                                    selectedColor: Colors.blue,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    buttonText: const Text("Select Tags"),
                                    chipDisplay: MultiSelectChipDisplay.none(),
                                    onConfirm: (List<TagRecord> selectedTags) {
                                      setState(() {
                                        selectedTagList =
                                            selectedTags.map((tag) {
                                          return {
                                            'id': tag.id ?? '',
                                            'name': tag.name ?? '',
                                          };
                                        }).toList();
                                      });
                                      debugPrint(
                                          "Selected tags: $selectedTagList");
                                    },
                                  )
                                : const SizedBox(),
                            hasTags
                                ? Wrap(
                                    spacing: 8.0,
                                    children: selectedTagList.map((tagMap) {
                                      return Chip(
                                        label: Text(tagMap['name'] ?? "Tag"),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: () {
                                          setState(() {
                                            selectedTagList.removeWhere(
                                                (t) => t['id'] == tagMap['id']);
                                          });
                                        },
                                        backgroundColor:
                                            Colors.blue.withOpacity(0.2),
                                        labelStyle:
                                            const TextStyle(color: Colors.blue),
                                      );
                                    }).toList(),
                                  )
                                : const SizedBox(),
                            const Text('Lead Source',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getDropdown(
                              '--Select--',
                              onChanged: (value) {
                                setState(() {
                                  _leadsource = value;
                                });
                              },
                              data: _leadsources,
                              value: _leadsource,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailsHeading(
                        title: "Address Information",
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(
                              height: 5,
                            ),
                            AppUtils.getTextFormField(
                              'Enter Address',
                              maxLines: 2,
                              initialValue: widget.model?.address,
                              onSaved: (country) {
                                _selectedCountry = country;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onButtonPressed() {
    print("_leadstatus::: $_leadstatus    $selectedTagList");

    var userId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      // defaultUsrId = userMap.keys
      //     .firstWhere((k) => userMap[k] == _asignStaff, orElse: () => null);

      // Skip phone validation if it's masked
      if (!shouldHideLeadNumber && !isValidPhone(_whatsapnumber!.trim())) {
        EasyLoading.showToast("Please enter valid whatsapp number");
        return;
      }

      // If phone number is masked in edit mode, use the original number
      String whatsappNumberToUse = _whatsapnumber!;
      if (shouldHideLeadNumber && isEdit && _whatsapnumber!.contains('X')) {
        whatsappNumberToUse = widget.model?.whatsappNumber ?? _whatsapnumber!;
      }

      Map body = {
        "firstname": _firstname?.trim(),
        "lastname": _lastname?.trim(),
        "country_code": selectedCountry,
        "whatsapp_number":
            whatsappNumberToUse.trim(), // Use the corrected number
        "email": _email?.trim(),
        "dob": selectedDate,
        "tag_names": hasTags ? selectedTagList : [],
        "leadsource": _leadsource,
        "leadstatus": _leadstatus,
        "ownername": _asignStaff,
        "ownerid": defaultUsrId,
        "description": _description?.trim(),
        "address": _selectedCountry?.trim(),
        "blocked": false
      };

      print("addleadModel:::::::::::::::::::::::  $body");

      _getleadData?.addlead(body).then((value) {
        debug("value#### $value");
        if (value['success'] == false) {
          var error = value['errors'];
          String message;

          if (error is List) {
            message = "Something went wrong";
          } else if (error is String) {
            message = error;
          } else {
            message = "Something went wrong";
          }

          EasyLoading.showToast(message);
          return;
        }

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
      }).catchError((error, stackTrace) {
        print(
            "calling error messages: ${AppUtils.getLeadErrorMessages(error)}");
        EasyLoading.showToast(AppUtils.getLeadErrorMessages(error)[0]);
      });
    }
  }

  Future<void> updateData() async {
    print("_leadstatus:::$_leadstatus");
    var userId;
    userId = userMap.keys
        .firstWhere((k) => userMap[k] == _asignStaff, orElse: () => null);
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();

      var id = widget.model?.id;
      debug('idmodel====$id');

      // If phone number is masked, use the original number from the model
      String whatsappNumberToUse = _whatsapnumber!;
      if (shouldHideLeadNumber && isEdit && _whatsapnumber!.contains('X')) {
        whatsappNumberToUse = widget.model?.whatsappNumber ?? _whatsapnumber!;
      }

      Map body = {
        "id": widget.model?.id,
        "firstname": _firstname?.trim(),
        "lastname": _lastname?.trim(),
        "country_code": selectedCountry,
        "whatsapp_number":
            whatsappNumberToUse.trim(), // Use the corrected number
        "email": _email?.trim(),
        "dob": selectedDate,
        "tag_names": hasTags ? selectedTagList : [],
        "leadsource": _leadsource,
        "leadstatus": _leadstatus,
        "ownername": _asignStaff,
        "ownerid": userId,
        "description": _description?.trim(),
        "address": _selectedCountry?.trim(),
        "blocked": false
      };

      AppUtils.onLoading(context, "Updating, please wait...");

      print("addleadModel:::::::::::::::::::::::  $body");

      _getleadData?.updatelead(body, widget.model?.id ?? "").then((value) {
        debug("value#### $value");
        if (value.isNotEmpty) {
          debug("value#### $value");
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
        }
      }).catchError((error, stackTrace) {
        Navigator.pop(context);
        List<String> errorMessages = AppUtils.getErrorMessages(error);
        print("errorMessages:::: $errorMessages");
        AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }

  List tags = [];
  var leadlistvm;
  Future<void> getTags() async {
    await Provider.of<LeadListViewModel>(context, listen: false)
        .fetchLeadTags()
        .then((onValue) {
      tags = [];
      leadlistvm = Provider.of<LeadListViewModel>(context, listen: false);

      for (var viewModel in leadlistvm.viewModels) {
        var leadmodel = viewModel.model;
        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            tags.add(record);
            tagsNameSet.add(record);
          }
        }
      }
      setState(() {});
    });
  }

  List<String> modules = [];
  Future<void> getWalletStatus() async {
    final prefs = await SharedPreferences.getInstance();

    modules =
        prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];

    hasTags =
        modules.contains("Tag") || modules.contains("Tags") ? true : false;
    print("hasWallet::::::::::::::::::::::::    $hasTags");
    setState(() {});
  }

  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber =
        prefs.getBool(SharedPrefsConstants.shouldHideNumber) ?? false;
    setState(() {});
  }

  String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';

    if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
      int totalLength = phoneNumber.length;
      String lastFiveDigits = phoneNumber.substring(totalLength - 5);
      String maskedPart = 'X' * (totalLength - 5);
      print("masedpart::: ${maskedPart}   $lastFiveDigits");
      return '$maskedPart$lastFiveDigits';
    } else {
      return phoneNumber;
    }
  }
}

// ignore: camel_case_types
class detailsHeading extends StatelessWidget {
  String title;
  detailsHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.navBarIconColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: 40,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
