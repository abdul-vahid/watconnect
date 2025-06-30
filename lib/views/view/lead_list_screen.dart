import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/views/view/lead_add_update_view.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColor.navBarIconColor,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.add,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadAddView(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const FooterNavbarPage()),
              //   (route) => false, // remove all previous routes
              // );
            }),
        automaticallyImplyLeading: false,
        title: const Text(
          'Leads',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: textController,
              // onChanged: _filterLeads,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: AppColor.textoriconColor.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color.fromARGB(255, 0, 0, 0),
                          size: 20,
                        ),
                        onPressed: () {
                          // _showFilterBottomSheet(context);
                        },
                      ),
                      // selectleadList.isEmpty
                      //     ? const SizedBox()
                      //     : Container(
                      //         decoration: const BoxDecoration(
                      //             color: AppColor.navBarIconColor,
                      //             shape: BoxShape.circle),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Text(
                      //             "${selectleadList.length}",
                      //             style: const TextStyle(color: Colors.white),
                      //           ),
                      //         ),
                      //       )
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
