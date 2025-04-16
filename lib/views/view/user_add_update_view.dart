import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
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
  @override
  void initState() {
    Provider.of<UserDataListViewModel>(context, listen: false).fetchUser();
    isactive = widget.model?.isactive ?? false;
    _role = widget.model?.userrole != '' && widget.model?.userrole != null
        ? widget.model?.userrole
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

    final model = widget.model;
    if (model != null) {
      isEdit = true;
    }
  }

  final List<String> _roles = [
    "SUPER_ADMIN",
    "ADMIN",
    "USER",
  ];

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

              const SizedBox(height: 10),
              const Text('WhatsApp No'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter no',
                onSaved: (p0) {
                  _whatsappPhone = p0;
                },
                initialValue: widget.model?.whatsappNumber ?? "",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  } else if (value.length != 12) {
                    return 'Phone number must be 12(included+91) digits';
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
          firstname: _firstname,
          lastname: _lastname,
          email: _email,
          password: _password,
          whatsappNumber: _whatsappPhone,
          userrole: _role,
          isactive: isactive,
          managername: _selectedaccountname,
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
        firstname: _firstname,
        lastname: _lastname,
        email: _email,
        userrole: _role,
        managerid: accountId,
        managername: _selectedaccountname,
        isactive: isactive,
        whatsappNumber: _whatsappPhone,
      );

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
}
