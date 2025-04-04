import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/views/view/changepassword_view.dart';
import 'package:whatsapp/views/view/user_add_update_view.dart';
import 'package:whatsapp/views/view/user_list_view.dart';

import '../../models/user_data_model/user_data_model.dart';
import '../../utils/app_utils.dart';
import '../../view_models/user_data_list_vm.dart';

class UserDetailView extends StatefulWidget {
  UserDataModel? model;
  UserDetailView({super.key, this.model});

  @override
  State<UserDetailView> createState() => _UserDetailView();
}

class _UserDetailView extends State<UserDetailView> {
  late NotchBottomBarController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  get model => widget.model;
  String? userId;
  bool _obscurePassword = true;

  Future<void> _showSimpleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        bool _obscurePassword1 = true;
        bool _obscurePassword2 = true;
        _passwordController.clear();
        _confirmPasswordController.clear();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SimpleDialog(
              backgroundColor: AppColor.navBarIconColor,
              title: const Text(
                'Change Password',
                style: TextStyle(color: Colors.white),
              ),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        // New Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "New Password",
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF233A73)),
                            filled: true,
                            fillColor: Colors.blue[50],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword1
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              color: const Color(0xFF233A73),
                              onPressed: () {
                                setDialogState(() {
                                  _obscurePassword1 = !_obscurePassword1;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF233A73)),
                            filled: true,
                            fillColor: Colors.blue[50],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword2
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              color: const Color(0xFF233A73),
                              onPressed: () {
                                setDialogState(() {
                                  _obscurePassword2 = !_obscurePassword2;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                onButtonPressed();
                              },
                              child: Text("ok", style: TextStyle(fontSize: 13)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("cancel",
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onButtonPressed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var id = userId;
      Map<String, dynamic> data = {
        'id': id,
        'password': _confirmPasswordController.text,
      };
      AppUtils.onLoading(context, "Updating, please wait...");
      Provider.of<UserDataListViewModel>(context, listen: false)
          .updatePassword(id, data)
          .then((dynamic value) {
        debug('userpass==>$value');
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
              content: Text('Password has been changed.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );

          //  Navigator.push(context, MaterialPageRoute(builder: (context) => UserAddView(),));
        } else {}
      }).catchError((error, stackTrace) {
        Navigator.pop(context);
        List<String> errorMessages = AppUtils.getErrorMessages(error);
        AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }

  @override
  void initState() {
    // _showSimpleDialog();
    userId = widget.model?.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Details',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEdit();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _pageBody(model),
    );
  }

  Widget _pageBody(model) {
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          getRow('Email', widget.model?.email ?? ''),
                          const Divider(),
                          getRow('Username', widget.model?.username ?? ''),
                          const Divider(),
                          getRow('Phone', widget.model?.whatsappNumber ?? ''),
                          const Divider(),
                          getRow('First Name', widget.model?.firstname ?? ''),
                          const Divider(),
                          getRow('Last Name', widget.model?.lastname ?? ''),
                          const Divider(),
                          getRow('Manager', widget.model?.managername ?? ''),
                          const Divider(),
                          getRow('User Role', widget.model?.userrole ?? ''),
                          const Divider(),
                          const Text("Active"),
                          Checkbox(
                            activeColor: widget.model!.isactive == true
                                ? AppColor.navBarIconColor
                                : Colors.white,
                            value: widget.model!.isactive,
                            onChanged: (bool? newValue) {
                              setState(() {
                                widget.model!.isactive = newValue!;
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(
                                        widget.model?.username ?? "",
                                        widget.model?.whatsappNumber ?? ""
                                        // '', // Ensure it's not null
                                        // _obscurePassword1,
                                        // _passwordController,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.cardsColor,
                              ),
                              child: const Text(
                                "Change Password",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding getRow(String lable, String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              lable,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                name,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() {
    if (widget.model != null) {
      print("widget.model: ${widget.model?.email}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserAddView(model: widget.model),
        ),
      );
    } else {
      print("Model is null!");
    }
  }
}
