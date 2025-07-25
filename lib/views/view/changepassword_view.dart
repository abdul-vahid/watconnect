// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/view_models/user_data_list_vm.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String username;
  final String phone;
  final String userId;
  // final bool obscurePassword;
  // final TextEditingController passwordController;

  const ChangePasswordScreen(this.username, this.phone, this.userId, {Key? key})
      : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // bool _isObscured1 = true;
  bool _isObscured2 = true;
  bool _isObscured3 = true;
  // final TextEditingController _currentPasswordController =
  //     TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: AppColor.navBarIconColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Container(
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
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person,
                        size: 60, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.username,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.phone,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                      "New Password", _newPasswordController, _isObscured2, () {
                    setState(() => _isObscured2 = !_isObscured2);
                  }),
                  const SizedBox(height: 20),
                  _buildPasswordField("Confirm Password",
                      _confirmPasswordController, _isObscured3, () {
                    setState(() => _isObscured3 = !_isObscured3);
                  }),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_confirmPasswordController.text.trim().isEmpty ||
                            _newPasswordController.text.trim().isEmpty) {
                          EasyLoading.showToast(
                              "Please enter password and confirm password",
                              toastPosition: EasyLoadingToastPosition.bottom);
                        } else if (_confirmPasswordController.text.trim() !=
                            _newPasswordController.text.trim()) {
                          EasyLoading.showToast(
                              "Password and confirm password must match.",
                              toastPosition: EasyLoadingToastPosition.bottom);
                        } else if (_newPasswordController.text.trim().length !=
                            6) {
                          EasyLoading.showToast(
                              "Your password should have 6 characters.",
                              toastPosition: EasyLoadingToastPosition.bottom);
                        } else {
                          var id = widget.userId;
                          Map<String, dynamic> data = {
                            'id': id,
                            'password': _confirmPasswordController.text,
                          };
                          AppUtils.onLoading(
                              context, "Updating, please wait...");
                          Provider.of<UserDataListViewModel>(context,
                                  listen: false)
                              .updatePassword(id, data)
                              .then((dynamic onValue) {
                            print(
                                'userpass==>$onValue    ${onValue.runtimeType} ');
                            if (onValue['success']) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              EasyLoading.showToast(onValue['message'],
                                  toastPosition:
                                      EasyLoadingToastPosition.bottom);
                            } else {
                              EasyLoading.showToast(onValue['message'],
                                  toastPosition:
                                      EasyLoadingToastPosition.bottom);
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColor.navBarIconColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Save & Continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isObscured, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        focusColor: AppColor.navBarIconColor,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
