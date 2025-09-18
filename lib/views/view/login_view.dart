// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/views/view/login_salesforce.dart';

import '../../utils/app_utils.dart' show AppUtils;
import '../../view_models/user_list_vm.dart';
import '../widgets/bottomnavigatonbar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tcodeController = TextEditingController();
  bool _obscurePassword = true;
  @override
  void initState() {
    // _emailController.text = 'shivani.m+demo@ibirdsservices.com';
    // _passwordController.text = 'Admin@123';
    // _tcodeController.text = 'demo';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColor.backgroundGrey,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;
                final imageHeight = totalHeight * 0.35;
                final formHeight = totalHeight - imageHeight;

                return Column(
                  children: [
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: AppColor.backgroundGrey,
                      child: Image.asset(
                        "assets/images/login_image.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      height: formHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 3,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _loginFormKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _tcodeController,
                                validator: (value) => value!.isEmpty
                                    ? 'Please provide Code'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Enter Company Code",
                                  prefixIcon: const Icon(Icons.code,
                                      color: Color(0xFF233A73)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) => value!.isEmpty
                                    ? 'Please provide Email'
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Enter your email",
                                  prefixIcon: const Icon(Icons.email,
                                      color: Color(0xFF233A73)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: (value) => value!.isEmpty
                                    ? 'Please provide Password'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Color(0xFF233A73)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xFF233A73),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: onButtonPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF233A73),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: const Text("Login",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.cloud,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const WebViewPage(
                                                  url:
                                                      "https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9dAEux2v1sLvMShd1QqukhBR6uzZfjJuCm2Jind0stiCXF_X4sJrrVuyO9mz6e2efAESPs532ydpDE_nZ&redirect_uri=https://login.salesforce.com/services/oauth2/success")
                                              // "https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9PwZx9R6_UreQjtbTa_HQIRT0vGO9oKRm1vvYigaXJdMOt0xNGJzv6nfaXazvy6sTACP1WoZ2144f0ZDK&redirect_uri=https://login.salesforce.com/services/oauth2/success"
                                              // "https://test.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9HDaKRUgW3VrsUI_RKn2LNBUcxtribjudS7kOePtrSPn9mK.aWox_5gvqxOTD50qyOmRcRWV6jp3jwTOs&redirect_uri=https://test.salesforce.com/services/oauth2/success&scope=&state=random123"),
                                              ),
                                        );
                                      },
                                      label: const Text("Salesforce",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF233A73),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => launchUrl(Uri.parse(
                                        "https://www.facebook.com/profile.php?id=61573568597186")),
                                    child: _buildCircleIcon(
                                      "assets/images/fb_icon.png",
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  InkWell(
                                    onTap: () => launchUrl(Uri.parse(
                                        "https://www.instagram.com/watconnect/")),
                                    child: _buildCircleIcon(
                                      "assets/images/insta_icon.png",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  void onButtonPressed() {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();

      UserListViewModel userListViewModel = UserListViewModel();

      userListViewModel
          .makeLoginRequest(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _tcodeController.text.trim(),
      )
          .then((records) async {
        if (records) {
          await AppUtils.getToken().then((onValue) {
            Navigator.pop(context);
            DashBoardController dashBoardController =
                Provider.of(context, listen: false);
            dashBoardController.setLoginType(false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FooterNavbarPage(),
              ),
              (Route<dynamic> route) => false,
            );
          });
        }
      });
    }
  }

  Widget _buildCircleIcon(String icon) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              spreadRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
          color: AppColor.backgroundGrey,
          shape: BoxShape.circle,
        ),
        child: Image.asset(icon));
  }
}
