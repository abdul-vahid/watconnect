import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import '../../view_models/campaign_count_vm.dart';
import '../../view_models/templete_list_vm.dart';
import '../../view_models/whatsapp_setting_vm.dart'
    show WhatsappSettingViewModel;

class Whtsapphone extends StatefulWidget {
  const Whtsapphone({super.key});

  @override
  State<Whtsapphone> createState() => _WhtsapphoneState();
}

class _WhtsapphoneState extends State<Whtsapphone> {
  WhatsappSettingViewModel? whatsAppSettingVM;
  String? selectedWhatsAppNumber;
  Map<String, String> itemsMap = {};

  @override
  void initState() {
    super.initState();
    fetch();
    getPhoneNumber();
  }

  Future<void> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    setState(() {
      selectedWhatsAppNumber = phoneNumber;
    });
    debug('Retrieved phone number: $phoneNumber');
  }

  void fetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber = prefs.getString('phoneNumber');

    await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();

    if (Provider.of<WhatsappSettingViewModel>(context, listen: false)
        .viewModels
        .isNotEmpty) {
      String firstPhone =
          Provider.of<WhatsappSettingViewModel>(context, listen: false)
              .viewModels[0]
              .model
              .record[0]
              .phone;

      if (savedPhoneNumber == null || savedPhoneNumber.isEmpty) {
        savedPhoneNumber = firstPhone;
        await prefs.setString('phoneNumber', savedPhoneNumber);
      }
    }

    setState(() {
      selectedWhatsAppNumber = savedPhoneNumber;
    });

    debug('Selected WhatsApp Number: $selectedWhatsAppNumber');
  }

  void _updateItemsMap() {
    itemsMap.clear();
    for (var viewModel in whatsAppSettingVM!.viewModels) {
      var nmodel = viewModel.model;
      for (var record in nmodel?.record ?? []) {
        itemsMap[record.phone] = "${record.name} ${record.phone}";
      }
    }
  }

  String removeNumbers(String input) {
    return input.replaceAll(RegExp(r'\d'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    whatsAppSettingVM = Provider.of<WhatsappSettingViewModel>(context);
    _updateItemsMap();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hides the back arrow
        title: const Center(
          child: Text(
            "Phone Selection",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (selectedWhatsAppNumber != null) const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: itemsMap.length,
                itemBuilder: (context, index) {
                  String key = itemsMap.keys.elementAt(index);
                  String value = itemsMap[key]!;

                  bool isSelected = selectedWhatsAppNumber == key;

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedWhatsAppNumber = key;
                        print("value::: ${value}");
                        String name = removeNumbers(value);

                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString("userName", name);
                        });
                      });

                      Provider.of<CampaignCountViewModel>(context,
                              listen: false)
                          .fetchCampaignCount(number: selectedWhatsAppNumber);

                      Provider.of<TempleteListViewModel>(context, listen: false)
                          .templeteCountfetch(number: selectedWhatsAppNumber);

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'phoneNumber', selectedWhatsAppNumber ?? "");

                      debug(
                          'selectedWhatsAppNumber == $selectedWhatsAppNumber');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Selected WhatsApp number: $selectedWhatsAppNumber"),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? AppColor.cardsColor : Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
