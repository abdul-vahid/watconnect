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
  bool _isObscured1 = true;
  bool _isObscured2 = true;
  bool _isObscured3 = true;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: AppColor.navBarIconColor
              // gradient: LinearGradient(
              //   colors: [AppColor.navBarIconColor],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 60, color: Colors.black54),
              ),
              SizedBox(height: 10),
              Text(widget.username,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(widget.phone, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              _buildPasswordField(
                  "New Password", _newPasswordController, _isObscured2, () {
                setState(() => _isObscured2 = !_isObscured2);
              }),
              SizedBox(height: 20),
              _buildPasswordField(
                  "Confirm Password", _confirmPasswordController, _isObscured3,
                  () {
                setState(() => _isObscured3 = !_isObscured3);
              }),
              SizedBox(height: 40),
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
                    } else if (_newPasswordController.text.trim().length != 6) {
                      EasyLoading.showToast(
                          "Your password should have 6 characters.",
                          toastPosition: EasyLoadingToastPosition.bottom);
                    } else {
                      var id = widget.userId;
                      Map<String, dynamic> data = {
                        'id': id,
                        'password': _confirmPasswordController.text,
                      };
                      AppUtils.onLoading(context, "Updating, please wait...");
                      Provider.of<UserDataListViewModel>(context, listen: false)
                          .updatePassword(id, data)
                          .then((dynamic onValue) {
                        print('userpass==>$onValue    ${onValue.runtimeType} ');
                        if (onValue['success']) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          EasyLoading.showToast(onValue['message'],
                              toastPosition: EasyLoadingToastPosition.bottom);
                        } else {
                          EasyLoading.showToast(onValue['message'],
                              toastPosition: EasyLoadingToastPosition.bottom);
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: AppColor.navBarIconColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Save & Continue",
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
