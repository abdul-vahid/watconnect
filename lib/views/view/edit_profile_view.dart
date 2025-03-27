import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/get_user.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/get_user_vm.dart';

class EditProfileView extends StatefulWidget {
  GetUser? user;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? id;

  EditProfileView(
      {super.key,
      this.id,
      this.user,
      this.firstName,
      this.email,
      this.lastName,
      this.phone});

  @override
  State<EditProfileView> createState() => _EditProfileView();
}

class _EditProfileView extends State<EditProfileView> {
  // ignore: unused_field
  GetUserViewModel? _getUserData;

  String? firstName;
  String? lastName;
  String? email;
  String? phone;

  get model => widget.user;
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  bool isEdit = false;
  @override
  void initState() {
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
    super.initState();
    isEdit = true;
    // final model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    _getUserData = GetUserViewModel(context);
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
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          'Update Profile',
          style: TextStyle(
              fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Form(
            key: _profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'First Name',
                ),
                const SizedBox(
                  height: 05,
                ),
                TextFormField(
                  onSaved: (newValue) {
                    firstName = newValue;
                  },
                  initialValue: widget.firstName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(08)),
                    // hintText: 'Enter title',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Last Name',
                ),
                const SizedBox(
                  height: 05,
                ),
                TextFormField(
                  onSaved: (newValue) {
                    lastName = newValue;
                  },
                  initialValue: widget.lastName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(08)),
                    // hintText: 'Enter title',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Email',
                ),
                const SizedBox(
                  height: 05,
                ),
                TextFormField(
                  onSaved: (newValue) {
                    email = newValue;
                  },
                  initialValue: widget.email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(08)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Text(
                //   'Phone',
                // ),
                // const SizedBox(
                //   height: 05,
                // ),
                // TextFormField(
                //   onSaved: (newValue) {
                //     phone = newValue;
                //   },
                //   initialValue: widget.phone,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(08)),
                //     // hintText: 'Enter title',
                //   ),
                // ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        side: const BorderSide(
                          width: 1.0,
                          color: AppColor.navBarIconColor,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 8, 8, 8)),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.navBarIconColor,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                      ),
                      onPressed: updateData,
                      child: const Text(
                        "Update",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateData() async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();
      // AppUtils.onLoading(context, "Updating, please wait...");
      var id = widget.id;
      //debug('userid=====$id');
      GetUser updateUser = GetUser(
        firstname: firstName,
        lastname: lastName,
        email: email,
        phone: phone,
        id: widget.id,
        //id: id
        // accountname: _selectedaccountname,
      );
      print("aahahah=>${updateUser}");
      AppUtils.onLoading(context, "Updating, please wait...");

      Provider.of<GetUserViewModel>(context, listen: false)
          .updateProfile(id, updateUser)
          .then((value) {
        Navigator.pop(context);
        Navigator.pop(context);
        // Navigator.pop(context);
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (_) => ProfileView()));
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Your Profile has been update please pull to refresh '),
      //     duration: Duration(seconds: 3),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    }
  }
}
