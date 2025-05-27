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
  String? countrycode;

  EditProfileView(
      {super.key,
      this.id,
      this.user,
      this.firstName,
      this.email,
      this.lastName,
      this.phone,
      this.countrycode});

  @override
  State<EditProfileView> createState() => _EditProfileView();
}

class _EditProfileView extends State<EditProfileView> {
  String? selectedCountry;
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
  // ignore: unused_field
  GetUserViewModel? _getUserData;

  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? countrycode;

  get model => widget.user;
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  bool isEdit = false;
  @override
  void initState() {
    Provider.of<GetUserViewModel>(context, listen: false).fetchUser();
    super.initState();
    // final model = widget.model;
    if (model != null) {
      isEdit = true;
    }
    fillCountryCodeMap();
    selectedCountry = countryCodeMap.keys.first;
    if (isEdit) {
      print("widget.model?.countryCode----- ${model?.countrycode}");
      selectedCountry = model.countrycode;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    print("selectedCounssssssstry${selectedCountry}");
    print("phone==widget>${widget.phone}");
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
                  height: 05,
                ),
                const Text(
                  'County Code',
                ),
                const SizedBox(
                  height: 05,
                ),
                // DropdownButtonFormField<String>(
                //   isDense: true,
                //   decoration: InputDecoration(
                //     contentPadding:
                //         EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(8)),
                //     ),
                //   ),
                //   value: selectedCountry,
                //   isExpanded: true,
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       selectedCountry = newValue!;
                //     });
                //   },
                //   items: countryCodeMap.entries.map<DropdownMenuItem<String>>(
                //     (MapEntry<String, String> entry) {
                //       return DropdownMenuItem<String>(
                //         value: entry.key,
                //         child: Text(entry.value),
                //       );
                //     },
                //   ).toList(),
                // ),

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
                const Text(
                  'Phone',
                ),
                const SizedBox(
                  height: 05,
                ),
                TextFormField(
                  onSaved: (newValue) {
                    phone = newValue;
                  },
                  initialValue: widget.phone,
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
    print("selectedCountry::: ${selectedCountry}");
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();
      // AppUtils.onLoading(context, "Updating, please wait...");
      var id = widget.id;
      //debug('userid=====$id');
      GetUser updateUser = GetUser(
        firstname: firstName?.trim(),
        lastname: lastName?.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        id: widget.id,
        countrycode: selectedCountry,
      );

      print("aahahah=>${updateUser.toJson()}");
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
