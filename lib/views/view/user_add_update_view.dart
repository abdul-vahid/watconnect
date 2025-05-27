import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:provider/provider.dart';
import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';
import 'package:whatsapp/views/view/user_list_view.dart';

import '../../models/user_data_model/user_data_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';

import '../../utils/function_lib.dart';
import '../../view_models/user_data_list_vm.dart';

List accounts = [];
Map accountsMap = {};

class UserAddView extends StatefulWidget {
  UserDataModel? model;

  UserAddView({Key? key, this.model}) : super(key: key);

  @override
  State<UserAddView> createState() => _Forms();
}

class _Forms extends State<UserAddView> {
  bool isEdit = false;
  bool? isactive;
  List<String> selectWhNumsList = [];
  @override
  WhatsappSettingViewModel? whatsAppSettingVM;
  void initState() {
    getNumbers();
    final model = widget.model;
    if (model != null) {
      isEdit = true;
    }
    if (isEdit) {
      print("model courntry::: ${widget.model?.country_code}");
      selectedCountry = widget.model?.country_code;
      // selectWhNumsList = widget.model?.whatsapp_settings ?? [];
    } else {
      selectWhNumsList = [];
    }
    fillCountryCodeMap();
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    isactive = widget.model?.isactive ?? false;
    _role = widget.model?.userrole != '' && widget.model?.userrole != null
        ? widget.model?.userrole
        : null;

    _phone = widget.model?.phone != '' && widget.model?.phone != null
        ? widget.model?.phone
        : null;

    _selectedaccountname =
        widget.model?.managername != '' && widget.model?.managername != null
            ? widget.model?.managername
            : null;

    super.initState();
    if (widget.model != null) {
      print("aya ky ");
      isCreateMode = false;
    }
  }

  final List<String> _roles = [
    "SUPER_ADMIN",
    "ADMIN",
    "USER",
  ];

  final List<String> whatsAppNums = [];

  List<Map<String, String>> _countrycode = [
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
  // bool isEdit = false;
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

    // print("Dropdown  => $countryCodeMap");
    // print("Dial Code Map=> $code");
  }

  var baseViewModels;

  UserDataListViewModel? _getcontactData;
  String? _firstname;
  String? _lastname;
  String? _email;
  String? _phone;
  String? _whatsappPhone;
  String? _role;
  String? _userType;
  String? _selectedaccountname;
  String? _password;
  bool isCreateMode = true;
  final GlobalKey<FormState> _addleadFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);

    _getcontactData = UserDataListViewModel(context);
    baseViewModels = Provider.of<UserDataListViewModel>(context);
    accounts.length = 0;

    for (var viewModel in baseViewModels.viewModels) {
      UserDataModel model1 = viewModel.model;
      accountsMap[model1.managerid] = model1.managername;
    }
    accounts = accountsMap.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        title: Text(
          isEdit ? "Edit User" : "Add New User",
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
              const Text('First Name'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter First Name',
                onSaved: (p0) {
                  _firstname = p0;
                },
                initialValue: widget.model?.firstname ?? "",
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text('Last Name'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter Last Name',
                onSaved: (p0) {
                  _lastname = p0;
                },
                initialValue: widget.model?.lastname ?? "",
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text('Email'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter Email',
                onSaved: (p0) {
                  _email = p0;
                },
                initialValue: widget.model?.email ?? "",
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10), const Text('Country Code'),
              DropdownButtonFormField<String>(
                isDense: true,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                value: selectedCountry,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                items: countryCodeMap.entries.map<DropdownMenuItem<String>>(
                  (MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              const Text('WhatsApp No'),
              const SizedBox(height: 10),
              AppUtils.getTextFormField(
                'Enter no',
                onSaved: (p0) {
                  _whatsappPhone = p0;
                },
                initialValue: widget.model?.whatsappNumber ?? "",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Phone number must contain only digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Privacy Information Section
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
                          ' Information',
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

              const SizedBox(height: 5),
              if (isEdit == false) Text('Password'),
              if (isEdit == false)
                AppUtils.getTextFormField(
                  'Enter Password',
                  onSaved: (p0) {
                    _password = p0;
                  },
                  initialValue: widget.model?.password ?? "",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 10),
              const Text('Role'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select',
                data: _roles,
                onChanged: (p0) {
                  setState(() {
                    _role = p0;
                    _userType = null;
                  });
                },
                value: _role,
                validator: (value) => value == null ? 'Role is required' : null,
              ),

              const SizedBox(height: 10),
              const Text('Select Wh Number'),
              const SizedBox(height: 5),

              MultiSelectDialogField<String>(
                items: whatsAppNums
                    .map((e) => MultiSelectItem<String>(e, e))
                    .toList(),
                title: Flexible(
                  child: const Text(
                    "Select Campaign Status",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                buttonText: const Text("Select Campaign Status"),
                searchable: true,
                dialogWidth: 300,
                dialogHeight: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                onConfirm: (List<String> selected) {
                  setState(() {
                    // Update selectleadList with the confirmed selections
                    selectWhNumsList = selected;
                  });
                },
                initialValue: [],
              ),
              SizedBox(height: 16),

              Wrap(
                spacing: 8.0,
                children: selectWhNumsList.map((selectedItem) {
                  return Chip(
                    label: Text(selectedItem),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectWhNumsList.remove(selectedItem);
                      });
                    },
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),

              // AppUtils.getDropdown(
              //   'Select',
              //   data: whatsAppNums,
              //   onChanged: (p0) {
              //     setState(() {
              //       _phone = p0;
              //       // _userType = null;
              //     });
              //   },
              //   value: _phone,
              //   validator: (value) => value == null ? 'Role is required' : null,
              // ),

              const SizedBox(height: 10),
              const Text('Manager'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                '--Select--',
                data: accounts,
                onChanged: (p0) {
                  _selectedaccountname = p0;
                },
                value: _selectedaccountname,
                validator: (value) =>
                    value == null ? 'Manager is required' : null,
              ),
              const SizedBox(height: 10),
              const Text('Active'),
              const SizedBox(height: 5),
              Checkbox(
                checkColor: Colors.white,
                activeColor: AppColor.navBarIconColor,
                value: isactive,
                onChanged: (bool? value) {
                  setState(() {
                    isactive = value!;
                  });
                },
              ),

              const SizedBox(height: 10),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void onButtonPressed() {
    var accountId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();

      accountId = accountsMap.keys.firstWhere(
          (k) => accountsMap[k] == _selectedaccountname,
          orElse: () => null);
      UserDataModel adduserModel = UserDataModel(
          firstname: _firstname?.trim(),
          lastname: _lastname?.trim(),
          email: _email?.trim(),
          password: _password?.trim(),
          whatsappNumber: _whatsappPhone?.trim(),
          userrole: _role,
          isactive: isactive,
          managername: _selectedaccountname,
          country_code: selectedCountry,
          phone: _phone?.trim(),
          // whatsapp_settings: selectWhNumsList,
          managerid: accountId);
      AppUtils.onLoading(context, "Saving, please wait...");
      _getcontactData?.addUser(adduserModel).then((value) {
        debug('message my data $value');
        Navigator.pop(context);

        if (value.isNotEmpty) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (_) => UserDataListViewModel(context))
                      ],
                      child: const UserListView(),
                    )),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record has been created.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        } else {}
      }).catchError((error, stackTrace) {
        Navigator.pop(context);
        List<String> errorMessages = AppUtils.getErrorMessages(error);
        AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }

  Future<void> updateData() async {
    print("country_code:::: ${selectedCountry}");
    var accountId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      accountId = accountsMap.keys.firstWhere(
          (k) => accountsMap[k] == _selectedaccountname,
          orElse: () => null);
      var id = widget.model?.id;
      debug('userId====>$id');

      UserDataModel contactModel = UserDataModel(
          id: id,
          firstname: _firstname?.trim(),
          lastname: _lastname?.trim(),
          email: _email?.trim(),
          userrole: _role,
          managerid: accountId,
          managername: _selectedaccountname,
          isactive: isactive,
          whatsappNumber: _whatsappPhone?.trim(),
          // whatsapp_settings: selectWhNumsList,
          country_code: selectedCountry);

      AppUtils.onLoading(context, "Updating, please wait...");
      Provider.of<UserDataListViewModel>(context, listen: false)
          .updateUser(id, contactModel)
          .then((value) {
        debug('userUpdate==$value');
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (_) => UserDataListViewModel(context))
                    ],
                    child: const UserListView(),
                  )),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your record has been updated.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  Future<void> getNumbers() async {
    await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();
    print("whatsAppSettingVM ::: ${whatsAppSettingVM}");
    for (var viewModel in whatsAppSettingVM!.viewModels) {
      var nmodel = viewModel.model;
      for (var record in nmodel?.record ?? []) {
        whatsAppNums.add(record.phone);
        // itemsMap[record.phone] = "${record.name} ${record.phone}";
      }
    }
    setState(() {});
  }
}
