import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/views/view/edit_profile_view.dart';

import '../../models/get_user.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/get_user_vm.dart';
import '../../view_models/user_data_list_vm.dart' show UserDataListViewModel;
import '../../view_models/user_list_vm.dart';

class ProfileView extends StatefulWidget {
  GetUser? user;
  ProfileView({super.key, this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // late NotchBottomBarController _controller;
  String? profileUrl;
  UserModel? userModel;
  GetUser? user;
  GetUserViewModel? userVm;
  bool isRefresh = false;
  File? selectedImage;
  String base64Image = "";
  String? fName;
  String? lName;
  String? email;
  String? phone;
  String? id;
  String? countrycode;

  String? contactName;
  String? userRole;

  Future<File?> chooseImage(type) async {
    print("working this functio first line");
    XFile? image;
    if (type == "camera") {
      image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 10);
    } else {
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 25);
    }

    if (image != null) {
      setState(() {
        selectedImage = File(image!.path);
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
      });
    }

    return selectedImage;
  }

  // void getProfileData() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   MessageController msgController =
  //       Provider.of<MessageController>(context, listen: false);

  //   setState(() {
  //     userModel = AppUtils.getSessionUser(prefs);
  //     msgController.setUsrProfile(
  //         "https://sandbox.watconnect.com/public/demo/users/${userModel?.id}");
  //     print("logourl::: ${userModel?.logourl ?? ""}");
  //   });
  // }
  void getProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    MessageController msgController =
        Provider.of<MessageController>(context, listen: false);

    UserModel? tempModel = AppUtils.getSessionUser(prefs);

    if (tempModel != null) {
      setState(() {
        userModel = tempModel;
      });

      final prefs = await SharedPreferences.getInstance();
      String tenatCode =
          prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
      msgController.setUsrProfile(
          "${AppConstants.baseImgUrl}public/$tenatCode/users/${tempModel.id}");
      print("logourl::: ${tempModel.logourl ?? ""}");
    } else {
      debugPrint("No user session found in getProfileData.");
      // You can show a message or keep userModel null silently
    }
  }

  @override
  // void initState() {
  //   // _controller = NotchBottomBarController();
  //   Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
  //   SharedPreferences.getInstance().then((prefs) {
  //     var userModel = AppUtils.getSessionUser(prefs);
  //     userModel ?? AppUtils.logout(context);
  //   });

  //   getProfileData();
  //   super.initState();
  // }
  @override
  void initState() {
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
    SharedPreferences.getInstance().then((prefs) {
      var tempUserModel = AppUtils.getSessionUser(prefs);
      if (tempUserModel == null) {
        debugPrint("User session is null, but not logging out.");
      } else {
        print("hi this is sisiisis");
        setState(() {
          userModel = tempUserModel;
        });
      }
    });
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userVm = Provider.of<GetUserViewModel>(context);
    for (var viewModel in userVm!.viewModels) {
      print("viewModel.model:::>>>>> ${viewModel.model}");
      GetUser model = viewModel.model;
      user = model;
      id = model.id ?? "";
      fName = model.firstname ?? "";
      lName = model.lastname ?? "";
      email = model.email ?? "";
      phone = model.phone ?? "";
      countrycode = model.countrycode ?? "";
    }

    AppUtils.currentContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 23, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                print("phone===>Phone==>Pjp${user!.whatsapp_number}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileView(
                        id: id,
                        user: user,
                        firstName: fName,
                        lastName: lName,
                        email: email,
                        phone: user!.whatsapp_number,
                        countrycode: countrycode),
                  ),
                ).then((value) =>
                    Provider.of<GetUserViewModel>(context, listen: false)
                        .fetchUser());
              }
              // else if (value == 'delete') {
              //   _showDeleteDialog();
              // }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                // const PopupMenuItem<String>(
                //   value: 'delete',
                //   child: Text('Delete'),
                // ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(userVm!, _getBody),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    userVm?.viewModels.clear();
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
    userVm = Provider.of<GetUserViewModel>(context, listen: false);
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  Widget _getBody() {
    String fullPhone = "${user!.countrycode} ${user!.whatsapp_number}";
    String fullname = "${fName!} ${lName!}";
    String role = user?.userrole ?? "";
    print("sandbox.watconnect.com/${userModel?.id}',");

    return SingleChildScrollView(
      child: Column(
        children: [
          ClipPath(
            clipper: CustomShape(),
            child: Container(
              height: 140,
              width: double.infinity,
              color: AppColor.pageBgGrey,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, top: 10),
                child: Stack(
                  children: [
                    Consumer<MessageController>(
                        builder: (context, mssss, child) {
                      print("ms>>>> ${mssss.userProfile}");
                      return Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColor.navBarIconColor, width: 3),
                            borderRadius: BorderRadius.circular(60)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              '${mssss.userProfile}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                              key: ValueKey(mssss.userProfile),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/profile-image.png",
                                );
                              },
                            )),
                      );
                    }),
                    Positioned(
                      // bottom: 0,
                      left: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: AppColor.navBarIconColor,
                        ),
                        child: InkWell(
                          onTap: () {
                            uploadImage();
                          },
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: AppColor.navBarIconColor,
          //     borderRadius: const BorderRadius.vertical(
          //       bottom: Radius.circular(70),
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         spreadRadius: 8,
          //         blurRadius: 7,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   height: 250,
          //   child: Column(
          //     children: [
          //       const SizedBox(height: 20),
          //       const SizedBox(height: 20),
          //       Center(
          //         child: Text(
          //           // userModel?.username ?? "",
          //           fullname,
          //           style: const TextStyle(
          //               fontSize: 20,
          //               color: Color.fromARGB(255, 255, 255, 255)),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 43),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getRow("First Name", fName),
                    const Divider(),
                    getRow("Last Name", lName),
                    const Divider(),
                    getRow("Email", email),
                    const Divider(),
                    getRow("Phone", fullPhone),
                    const Divider(),
                    getRow("Role", role),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Background color of the dialog
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15), // Rounded corners for the dialog
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min, // Let the content size fit
            children: [
              const Text(
                'Are you sure you want to delete this campaign?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              // Optional: Custom button text styling
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor:
                          Colors.grey[200], // Button background color for 'No'
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColor.navBarIconColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      _deleteUser();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteUser() {
    // Implement the delete functionality here
    String? userId;
    UserDataListViewModel(context).deleteUser(userId).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the previous screen after delete
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting user.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Padding getRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          // Spacer(),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value ?? '-',
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void uploadImage() async {
    var userMap = user?.toJson();
    print("userLLL >>> ${userMap}");
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();

    var selectedImage = await chooseImage("Gallery");
    print("select mage=>$selectedImage");
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    if (selectedImage != null) {
      var url = "${AppConstants.baseUrl}/api/auth/${user?.id ?? ""}/profile";

      UserListViewModel()
          .uploadFile(selectedImage, userMap.toString(), url)
          .then((value) async {
        await AppUtils.getToken();
        getProfileData();
        MessageController msgController =
            Provider.of<MessageController>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        String tenatCode =
            prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
        msgController.setUsrProfile(
            "${AppConstants.baseImgUrl}public/$tenatCode/users/${userModel?.id}");
      }).catchError((error) {
        print("Error uploading file: $error");
      });
    } else {
      // Navigator.pop(context);
    }
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    double yOffset = 30;
    Path path = Path();
    path.moveTo(0, yOffset); // Start lower
    path.quadraticBezierTo(
      width * 0.02,
      height * 1.5 + yOffset,
      width,
      yOffset,
    );
    path.lineTo(width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
