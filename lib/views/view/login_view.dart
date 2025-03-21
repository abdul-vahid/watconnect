// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../models/user_model/user_model.dart';
// import '../../utils/app_color.dart' show AppColor;
// import '../../utils/app_constants.dart';
// import '../../utils/app_utils.dart' show AppUtils;
// import '../../view_models/user_list_vm.dart';
// import '../widgets/bottomnavigatonbar.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({super.key});

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _tcodeController = TextEditingController();
//   // String email = '';
//   // String password = '';
//   // String code = '';
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     _emailController.text = 'shivani.m+demo@ibirdsservices.com';
//     _passwordController.text = 'Admin@123';
//     _tcodeController.text = 'demo';
//     return Scaffold(
//       body: Center(
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/login2.png"),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: SingleChildScrollView(
//               child: Form(
//                 key: _loginFormKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 50,
//                     ),

//                     Image.asset(
//                       "assets/images/wp.png",
//                       height: 70,
//                     ),
//                     Container(
//                       height: 30,
//                     ),
//                     // Email Input Field
//                     TextFormField(
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide Email';
//                         }
//                         return null;
//                       },
//                       // onSaved: (value) => email = value!,
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: InputDecoration(
//                         hintText: "Enter your email",
//                         prefixIcon: const Icon(
//                           Icons.email,
//                           color: Color(0xFF233A73),
//                         ),
//                         filled: true,
//                         fillColor: Colors.blue[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),

//                     // Password Input Field
//                     TextFormField(
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide Password';
//                         }
//                         return null;
//                       },
//                       // onSaved: (value) => password = value!,
//                       controller: _passwordController,
//                       obscureText: _obscurePassword, // Hide password
//                       decoration: InputDecoration(
//                         hintText: "Enter your password",
//                         prefixIcon: const Icon(
//                           Icons.lock,
//                           color: Color(0xFF233A73),
//                         ),
//                         filled: true,
//                         fillColor: Colors.blue[50],
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           color: const Color(0xFF233A73),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),

//                     // T-Code Input Field
//                     TextFormField(
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide Code';
//                         }
//                         return null;
//                       },
//                       // onSaved: (value) => code = value!,
//                       controller: _tcodeController,
//                       decoration: InputDecoration(
//                         hintText: "Enter your T-Code ",
//                         prefixIcon: const Icon(
//                           Icons.code,
//                           color: Color(0xFF233A73),
//                         ),
//                         filled: true,
//                         fillColor: Colors.blue[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 150),

//                     // Submit Button
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).appBarTheme.backgroundColor,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       width: 350,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: TextButton.styleFrom(
//                           foregroundColor:
//                               const Color.fromARGB(255, 255, 255, 255),
//                           backgroundColor: const Color(0xFF233A73),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(100)),
//                         ),
//                         onPressed: onButtonPressed,
//                         child: const Text(
//                           'Submit',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _buildCircleIcon(FontAwesomeIcons.facebook),
//                         const SizedBox(width: 15),
//                         // _buildCircleIcon(FontAwesomeIcons.twitter),
//                         // SizedBox(width: 15),
//                         _buildCircleIcon(FontAwesomeIcons.instagram),
//                         const SizedBox(width: 15),
//                         _buildCircleIcon(FontAwesomeIcons.linkedin),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // void onButtonPressed() async {
//   //   if (_loginFormKey.currentState != null &&
//   //       _loginFormKey.currentState!.validate()) {
//   //     _loginFormKey.currentState!.save(); // Save form data

//   //     AppUtils.onLoading(context, "Logging You, please wait...");

//   //     UserListViewModel userListViewModel = UserListViewModel();
//   //     try {
//   //       var records = await userListViewModel.login(_emailController.text,
//   //           _passwordController.text, _tcodeController.text);

//   //       Navigator.pop(context);

//   //       if (!userListViewModel.isError && records.isNotEmpty) {
//   //         var userModel = records[0].model as UserModel;
//   //         SharedPreferences prefs = await SharedPreferences.getInstance();
//   //         prefs.setString(SharedPrefsConstants.userKey, userModel.toJson());

//   //         // Check if widget is still mounted before navigating
//   //         if (!mounted) return;

//   //         Navigator.pushAndRemoveUntil(
//   //             context,
//   //             MaterialPageRoute(builder: (_) => HomeView()),
//   //             (Route<dynamic> route) => false);
//   //       } else {
//   //         List<String> errorMessages =
//   //             AppUtils.getErrorMessages("Invalid User Name and Password!");
//   //         AppUtils.getAlert(context, errorMessages, title: "Error Alert");
//   //       }
//   //     } catch (error) {
//   //       Navigator.pop(context);
//   //       List<String> errorMessages = AppUtils.getErrorMessages(error);
//   //       AppUtils.getAlert(context, errorMessages, title: "Error Alert");
//   //     }
//   //   } else {
//   //     // Show error message if the form is not valid
//   //     AppUtils.getAlert(context, ['Form is not valid'], title: "Error Alert");
//   //   }
//   // }

//   void onButtonPressed() {
//     if (_loginFormKey.currentState!.validate()) {
//       _loginFormKey.currentState!.save();

//       AppUtils.onLoading(context, "Logging You, please wait...");
//       UserListViewModel userListViewModel = UserListViewModel();
//       userListViewModel
//           .login(_emailController.text, _passwordController.text,
//               _tcodeController.text)
//           .then((records) {
//         Navigator.pop(context);

//         if (!userListViewModel.isError && records.isNotEmpty) {
//           var userModel = records[0].model as UserModel;
//           SharedPreferences.getInstance().then((prefs) {
//             prefs.setString(SharedPrefsConstants.userKey, userModel.toJson());
//           });
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const FooterNavbarPage()),
//               (Route<dynamic> route) => false);
//         } else {
//           //Navigator.pop(context);
//           List<String> errorMessages =
//               AppUtils.getErrorMessages("Invalid User Name and Password!");
//           AppUtils.getAlert(context, errorMessages, title: "Error Alert");
//         }
//       }).catchError((error, stackTrace) {
//         Navigator.pop(context);
//         List<String> errorMessages = AppUtils.getErrorMessages(error);
//         AppUtils.getAlert(context, errorMessages, title: "Error Alert");
//       });
//     }
//   }

//   TextFormField getTextFormField(
//     String hintText, {
//     controller,
//     void Function(String?)? onSaved,
//     void Function(String)? onChanged,
//     void Function()? onTap,
//     bool obscureText = false,
//     bool readOnly = false,
//     String? initialValue,
//     int? maxLines = 1,
//     InputDecoration? decoration = const InputDecoration(),
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       keyboardType: keyboardType,
//       onSaved: onSaved,
//       onTap: onTap,
//       obscureText: obscureText,
//       controller: controller,
//       readOnly: readOnly,
//       maxLines: maxLines,
//       onChanged: onChanged,
//       initialValue: initialValue,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: AppColor.navBarIconColor),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide:
//               const BorderSide(color: Colors.grey), // Default border color
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         hintText: hintText,
//         hintStyle: GoogleFonts.montserrat(fontSize: 14),
//       ),
//       validator: validator,
//     );
//   }

//   Widget _buildCircleIcon(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: const BoxDecoration(
//         color: Color(0xFF00A1E4),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         icon,
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart' show AppColor;
import '../../utils/app_constants.dart';
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
  // String email = '';
  // String password = '';
  // String code = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    _emailController.text = 'shivani.m+demo@ibirdsservices.com';
    _passwordController.text = 'Admin@123';
    _tcodeController.text = 'demo';
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
                    Container(
                      height: 50,
                    ),

                    Image.asset(
                      "assets/images/wp.png",
                      height: 70,
                    ),
                    Container(
                      height: 30,
                    ),
                    // Email Input Field
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide Email';
                        }
                        return null;
                      },
                      // onSaved: (value) => email = value!,
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
                      // onSaved: (value) => password = value!,
                      controller: _passwordController,
                      obscureText: _obscurePassword, // Hide password
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

                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: 350,
                      height: 50,
                      child: ElevatedButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          backgroundColor: const Color(0xFF233A73),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        onPressed: onButtonPressed,
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleIcon(FontAwesomeIcons.facebook),
                        const SizedBox(width: 15),
                        // _buildCircleIcon(FontAwesomeIcons.twitter),
                        // SizedBox(width: 15),
                        _buildCircleIcon(FontAwesomeIcons.instagram),
                        const SizedBox(width: 15),
                        _buildCircleIcon(FontAwesomeIcons.linkedin),
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

  // void onButtonPressed() async {
  //   if (_loginFormKey.currentState != null &&
  //       _loginFormKey.currentState!.validate()) {
  //     _loginFormKey.currentState!.save(); // Save form data

  //     AppUtils.onLoading(context, "Logging You, please wait...");

  //     UserListViewModel userListViewModel = UserListViewModel();
  //     try {
  //       var records = await userListViewModel.login(_emailController.text,
  //           _passwordController.text, _tcodeController.text);

  //       Navigator.pop(context);

  //       if (!userListViewModel.isError && records.isNotEmpty) {
  //         var userModel = records[0].model as UserModel;
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         prefs.setString(SharedPrefsConstants.userKey, userModel.toJson());

  //         // Check if widget is still mounted before navigating
  //         if (!mounted) return;

  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(builder: (_) => HomeView()),
  //             (Route<dynamic> route) => false);
  //       } else {
  //         List<String> errorMessages =
  //             AppUtils.getErrorMessages("Invalid User Name and Password!");
  //         AppUtils.getAlert(context, errorMessages, title: "Error Alert");
  //       }
  //     } catch (error) {
  //       Navigator.pop(context);
  //       List<String> errorMessages = AppUtils.getErrorMessages(error);
  //       AppUtils.getAlert(context, errorMessages, title: "Error Alert");
  //     }
  //   } else {
  //     // Show error message if the form is not valid
  //     AppUtils.getAlert(context, ['Form is not valid'], title: "Error Alert");
  //   }
  // }

  void onButtonPressed() {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();

      UserListViewModel userListViewModel = UserListViewModel();
      userListViewModel
          .login(_emailController.text, _passwordController.text,
              _tcodeController.text)
          .then((records) {
        print("records::: ${records}   ${records.runtimeType}");
        if (records.runtimeType == String) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(records.toString()),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (records.isNotEmpty) {
          var userModel = records[0].model as UserModel;
          print("userModel::: ${userModel.success}   ${records[0].model}");
          {
            AppUtils.onLoading(context, "Logging You, please wait...");

            print("userModel::: ${userModel.success}   ${records[0].model}");

            if (!userListViewModel.isError && records.isNotEmpty) {
              var userModel = records[0].model as UserModel;
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString(
                    SharedPrefsConstants.userKey, userModel.toJson());
              });
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FooterNavbarPage()),
                  (Route<dynamic> route) => false);
            } else {
              //Navigator.pop(context);
              List<String> errorMessages =
                  AppUtils.getErrorMessages("Invalid User Name and Password!");
              AppUtils.getAlert(context, errorMessages, title: "Error Alert");
            }
          }
        }

        // }).catchError((error, stackTrace) {
        //   Navigator.pop(context);
        //   List<String> errorMessages = AppUtils.getErrorMessages(error);
        // AppUtils.getAlert(context, errorMessages, title: "Error Alert");
      });
    }
  }

  TextFormField getTextFormField(
    String hintText, {
    controller,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool obscureText = false,
    bool readOnly = false,
    String? initialValue,
    int? maxLines = 1,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      onSaved: onSaved,
      onTap: onTap,
      obscureText: obscureText,
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.navBarIconColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Colors.grey), // Default border color
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(fontSize: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF00A1E4),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
