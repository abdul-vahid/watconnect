import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(height: 50),

                    Image.asset("assets/images/wp.png", height: 70),
                    Container(height: 30),
                    // Email Input Field
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide Email';
                        }
                        return null;
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF233A73),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Password Input Field
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide Password';
                        }
                        return null;
                      },
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF233A73),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          color: const Color(0xFF233A73),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // T-Code Input Field
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide Code';
                        }
                        return null;
                      },
                      // onSaved: (value) => code = value!,
                      controller: _tcodeController,
                      decoration: InputDecoration(
                        hintText: "Enter your T-Code ",
                        prefixIcon: const Icon(
                          Icons.code,
                          color: Color(0xFF233A73),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            child: ElevatedButton.icon(
                              // icon: const Icon(Icons.code),
                              label: const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF233A73),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: onButtonPressed,
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: Container(
                        //     margin: const EdgeInsets.symmetric(horizontal: 10),
                        //     height: 50,
                        //     child: ElevatedButton.icon(
                        //       icon: const Icon(Icons.cloud),
                        //       label: const Text(
                        //         'Salesforce',
                        //         style: TextStyle(fontSize: 16),
                        //       ),
                        //       style: ElevatedButton.styleFrom(
                        //         foregroundColor: Colors.white,
                        //         backgroundColor: const Color(0xFF233A73),
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(30),
                        //         ),
                        //       ),
                        //       onPressed: () => {
                        //         SalesforceAuth.loginWithSalesforce(context),
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // // Submit Button
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).appBarTheme.backgroundColor,
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   width: 350,
                    //   height: 50,
                    //   child: ElevatedButton(
                    //     style: TextButton.styleFrom(
                    //       foregroundColor:
                    //           const Color.fromARGB(255, 255, 255, 255),
                    //       backgroundColor: const Color(0xFF233A73),
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(100)),
                    //     ),
                    //     onPressed: onButtonPressed,
                    //     child: const Text(
                    //       'Login with Node Js',
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 40),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).appBarTheme.backgroundColor,
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   width: 350,
                    //   height: 50,
                    //   child: ElevatedButton(
                    //     style: TextButton.styleFrom(
                    //       foregroundColor:
                    //           const Color.fromARGB(255, 255, 255, 255),
                    //       backgroundColor: const Color(0xFF233A73),
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(100)),
                    //     ),
                    //     onPressed: onButtonPressed,
                    //     child: const Text(
                    //       'Login with Salesforce',
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () async {
                              String url =
                                  "https://www.facebook.com/profile.php?id=61573568597186";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: _buildCircleIcon(FontAwesomeIcons.facebook)),
                        const SizedBox(width: 15),

                        InkWell(
                            onTap: () async {
                              String url =
                                  "https://www.instagram.com/watconnect/";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child:
                                _buildCircleIcon(FontAwesomeIcons.instagram)),
                        // const SizedBox(width: 15),
                        // _buildCircleIcon(FontAwesomeIcons.linkedin),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onButtonPressed() {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();

      UserListViewModel userListViewModel = UserListViewModel();
      // userListViewModel.makeLoginRequest(
      //   _emailController.text.trim(),
      //   _passwordController.text.trim(),
      //   _tcodeController.text.trim(),
      // );
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FooterNavbarPage(),
              ),
              (Route<dynamic> route) => false,
            );
          });
        }

        // print("records::: ${records}   ${records.runtimeType}");
        // if (records.runtimeType == String) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(records.toString()),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        // }
        // if (records.isNotEmpty) {
        //   var userModel = records[0].model as UserModel;
        //   {
        //     AppUtils.onLoading(context, "Logging You, please wait...");
        //     // print(
        //     //   "userModel::: ${userModel.success}   ${records[0].model}",
        //     // );
        //     if (!userListViewModel.isError && records.isNotEmpty) {
        //       var userModel = records[0].model as UserModel;

        //       SharedPreferences.getInstance().then((prefs) async {
        //         await prefs.setString(
        //           SharedPrefsConstants.userKey,
        //           userModel.toJson(),
        //         );
        //         await prefs.setString(
        //           SharedPrefsConstants.refreshTokenKey,
        //           userModel.refreshToken ?? '',
        //         );
        //         await prefs.setString(
        //           SharedPrefsConstants.accessTokenKey,
        //           userModel.authToken ?? '',
        //         );
        //       });

        //       await AppUtils.getToken().then((onValue) {
        //         Navigator.pop(context);
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const FooterNavbarPage(),
        //           ),
        //           (Route<dynamic> route) => false,
        //         );
        //       });
        //     } else {
        //       List<String> errorMessages = AppUtils.getErrorMessages(
        //         "Invalid User Name and Password!",
        //       );
        //       AppUtils.getAlert(
        //         context,
        //         errorMessages,
        //         title: "Error Alert",
        //       );
        //     }
        //   }
        // }
      });
    }
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF00A1E4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
