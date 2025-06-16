import 'package:flutter/material.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_utils.dart';

class TagAddUpdateView extends StatefulWidget {
  const TagAddUpdateView({super.key});

  @override
  State<TagAddUpdateView> createState() => _TagAddUpdateViewState();
}

class _TagAddUpdateViewState extends State<TagAddUpdateView> {
  final GlobalKey<FormState> _addTagFormKey = GlobalKey<FormState>();

  TextEditingController tagNameController = new TextEditingController();
  bool firstMsg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 2,
        title: const Text(
          "Add New Tag",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _pageBody(),
    );
  }

  _pageBody() {
    return SingleChildScrollView(
      child: Form(
          key: _addTagFormKey,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tag Name'),
                const SizedBox(height: 5),
                AppUtils.getTextFormField(
                  'Enter Tag Name',
                  controller: tagNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please provide tag name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "First Message",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              "Allows auto tagging if users' first message matches")
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          inactiveThumbColor: Colors.grey.withOpacity(0.8),
                          activeTrackColor:
                              AppColor.navBarIconColor.withOpacity(0.4),
                          activeColor: AppColor.navBarIconColor,
                          value: firstMsg,
                          onChanged: (value) {
                            setState(() {
                              firstMsg = value;
                            });
                            print("Latest Movies: $value");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
